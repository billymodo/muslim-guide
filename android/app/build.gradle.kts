plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

abstract class GenerateAdhanNotificationSound : DefaultTask() {
    @get:InputFile
    abstract val sourceFile: RegularFileProperty

    @get:OutputDirectory
    abstract val outputDirectory: DirectoryProperty

    @TaskAction
    fun generate() {
        val rawDirectory = outputDirectory.get().asFile.resolve("raw")
        rawDirectory.mkdirs()
        sourceFile.get().asFile.copyTo(
            rawDirectory.resolve("adhan_placeholder.wav"),
            overwrite = true,
        )
    }
}

val copyAdhanNotificationSound =
    tasks.register<GenerateAdhanNotificationSound>("copyAdhanNotificationSound") {
        sourceFile.set(layout.projectDirectory.file("../../assets/audio/adhan_placeholder.wav"))
        outputDirectory.set(layout.buildDirectory.dir("generated/res/adhanNotificationSound"))
    }

android {
    namespace = "com.muslimguide.app.muslim_guide"
    compileSdk = 36 // DEC-0015, amended by CR-0007
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // DEC-0015: applicationId مُعتمد بشريًا (2026-10-05).
        applicationId = "com.muslimguide.app"
        // DEC-0015 (معدّل بـ CR-0003 — APPROVED 2026-10-06): minSdk 24.
        // Flutter 3.47.5 يفرض 24 كحد أدنى فعلي (FlutterExtension.kt).
        minSdk = 24
        targetSdk = 34
        multiDexEnabled = true
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

androidComponents {
    onVariants(selector().all()) { variant ->
        variant.sources.res?.addGeneratedSourceDirectory(
            copyAdhanNotificationSound,
        ) { task ->
            task.outputDirectory
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
