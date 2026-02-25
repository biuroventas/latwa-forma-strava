import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/subscription_provider.dart';
import '../../../shared/services/openai_service.dart';
import '../../../core/utils/error_handler.dart';

const _keyAiAdviceDate = 'ai_advice_date';
const _keyAiAdviceCount = 'ai_advice_count';
const _keyAiAdvicePremiumDate = 'ai_advice_premium_date';
const _keyAiAdvicePremiumCount = 'ai_advice_premium_count';

class AiAdviceScreen extends ConsumerStatefulWidget {
  const AiAdviceScreen({super.key});

  @override
  ConsumerState<AiAdviceScreen> createState() => _AiAdviceScreenState();
}

class _AiAdviceScreenState extends ConsumerState<AiAdviceScreen> {
  final OpenAIService _aiService = OpenAIService();
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  String? _lastResponse;
  int _remainingFree = AppConstants.aiAdviceDailyLimit;
  int _remainingPremium = AppConstants.aiAdvicePremiumDailyLimit;

  @override
  void initState() {
    super.initState();
    _loadRemainingCount();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRemainingCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final savedDate = prefs.getString(_keyAiAdviceDate);
    final count = prefs.getInt(_keyAiAdviceCount) ?? 0;
    final freeRemaining = savedDate != today
        ? AppConstants.aiAdviceDailyLimit
        : (AppConstants.aiAdviceDailyLimit - count).clamp(0, AppConstants.aiAdviceDailyLimit);

    final premiumSavedDate = prefs.getString(_keyAiAdvicePremiumDate);
    final premiumCount = prefs.getInt(_keyAiAdvicePremiumCount) ?? 0;
    final premiumRemaining = premiumSavedDate != today
        ? AppConstants.aiAdvicePremiumDailyLimit
        : (AppConstants.aiAdvicePremiumDailyLimit - premiumCount).clamp(0, AppConstants.aiAdvicePremiumDailyLimit);

    if (!mounted) return;
    setState(() {
      _remainingFree = freeRemaining;
      _remainingPremium = premiumRemaining;
    });
  }

  Future<void> _recordQuery() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_keyAiAdviceDate);
    final count = prefs.getInt(_keyAiAdviceCount) ?? 0;

    if (savedDate != today) {
      await prefs.setString(_keyAiAdviceDate, today);
      await prefs.setInt(_keyAiAdviceCount, 1);
    } else {
      await prefs.setInt(_keyAiAdviceCount, count + 1);
    }
    await _loadRemainingCount();
  }

  Future<void> _recordPremiumQuery() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_keyAiAdvicePremiumDate);
    final count = prefs.getInt(_keyAiAdvicePremiumCount) ?? 0;

    if (savedDate != today) {
      await prefs.setString(_keyAiAdvicePremiumDate, today);
      await prefs.setInt(_keyAiAdvicePremiumCount, 1);
    } else {
      await prefs.setInt(_keyAiAdvicePremiumCount, count + 1);
    }
    await _loadRemainingCount();
  }

  Future<void> _askAi() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;
    final hasAccess = ref.read(hasPremiumAccessProvider);
    final remaining = hasAccess ? _remainingPremium : _remainingFree;
    final limit = hasAccess ? AppConstants.aiAdvicePremiumDailyLimit : AppConstants.aiAdviceDailyLimit;
    if (remaining <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasAccess
                  ? 'Wykorzystałeś dzisiejszy limit ($limit zapytań). Spróbuj jutro.'
                  : 'Wykorzystałeś dzisiejszy limit ($limit zapytań). Spróbuj jutro lub przejdź na Premium.',
            ),
          ),
        );
      }
      return;
    }
    final useEdgeFunction = SupabaseConfig.isInitialized;
    if (!useEdgeFunction && (OpenAIService.apiKey == null || OpenAIService.apiKey!.isEmpty)) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, error: 'Porada AI wymaga połączenia z aplikacją (Supabase) lub klucza OpenAI w konfiguracji.');
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });

    try {
      final response = await _aiService.getAdvice(question);
      if (mounted) {
        if (response != null && response.isNotEmpty) {
          if (ref.read(hasPremiumAccessProvider)) {
            await _recordPremiumQuery();
          } else {
            await _recordQuery();
          }
          setState(() {
            _lastResponse = response;
            _isLoading = false;
          });
          _questionController.clear();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        } else {
          setState(() => _isLoading = false);
          ErrorHandler.showSnackBar(context, error: 'Nie udało się uzyskać odpowiedzi. Spróbuj ponownie.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final message = e is Exception ? e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '') : null;
        ErrorHandler.showSnackBar(context, error: e, fallback: message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAccess = ref.watch(hasPremiumAccessProvider);
    final remaining = hasAccess ? _remainingPremium : _remainingFree;
    final limit = hasAccess ? AppConstants.aiAdvicePremiumDailyLimit : AppConstants.aiAdviceDailyLimit;
    final canAsk = remaining > 0 && !_isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Porada AI'),
      ),
      body: Column(
        children: [
          // Info o limicie
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pozostało zapytań dziś: $remaining / $limit${hasAccess ? ' (Premium)' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Zapytaj o poradę w zakresie diety, odżywiania lub aktywności fizycznej.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Focus(
                      onKeyEvent: (_, KeyEvent event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.enter &&
                            !HardwareKeyboard.instance.isShiftPressed &&
                            canAsk) {
                          _askAi();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: TextField(
                        controller: _questionController,
                        decoration: InputDecoration(
                          hintText: 'np. Ile białka potrzebuję przy treningu siłowym?',
                          border: const OutlineInputBorder(),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            icon: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                : Icon(
                                    Icons.send,
                                    color: canAsk
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  ),
                            onPressed: canAsk ? _askAi : null,
                          ),
                        ),
                        maxLines: 3,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: canAsk ? (_) => _askAi() : null,
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (_lastResponse != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Odpowiedź',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _lastResponse!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
