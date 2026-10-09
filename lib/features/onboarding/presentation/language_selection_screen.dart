import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muslim_guide/app/providers/bootstrap_provider.dart';
import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Lets the user choose the application language during onboarding.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  /// Creates the language selection screen.
  const new({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String? _selectedLanguage;
  bool _isSaving = false;

  Future<void> _continue() async {
    final language = _selectedLanguage;
    if (language == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final settings = ref.read(settingsRepositoryProvider);
      await settings.setLanguage(language);
      ref.read(appLocaleProvider.notifier).state = Locale(language);
      await settings.setOnboardingCompleted(true);
      if (!mounted) return;
      context.go('/home');
    } on Exception catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'onboarding',
          context: ErrorDescription('while saving the language selection'),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.onboarding_save_error),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      localizations.onboarding_choose_language,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _LanguageCard(
                      label: localizations.language_arabic,
                      semanticLabel:
                          localizations.language_arabic_semantics,
                      selected: _selectedLanguage == 'ar',
                      onTap: () => setState(() => _selectedLanguage = 'ar'),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _LanguageCard(
                      label: localizations.language_english,
                      semanticLabel:
                          localizations.language_english_semantics,
                      selected: _selectedLanguage == 'en',
                      onTap: () => setState(() => _selectedLanguage = 'en'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    FilledButton(
                      onPressed: _selectedLanguage != null && !_isSaving
                          ? _continue
                          : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator()
                          : Text(localizations.onboarding_continue),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const new({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: semanticLabel,
      selected: selected,
      child: Card(
        color: selected ? colorScheme.primaryContainer : colorScheme.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.m),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.m),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
