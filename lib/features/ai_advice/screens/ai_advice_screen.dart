import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/subscription_provider.dart';
import '../../../shared/services/openai_service.dart';
import '../../../core/utils/error_handler.dart';

const _keyAiAdviceDate = 'ai_advice_date';
const _keyAiAdviceCount = 'ai_advice_count';

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
  int _remainingToday = AppConstants.aiAdviceDailyLimit;

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

    if (!mounted) return;
    if (savedDate != today) {
      setState(() => _remainingToday = AppConstants.aiAdviceDailyLimit);
      return;
    }
    if (!mounted) return;
    setState(() => _remainingToday = (AppConstants.aiAdviceDailyLimit - count).clamp(0, AppConstants.aiAdviceDailyLimit));
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

  Future<void> _askAi() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;
    final hasAccess = ref.read(hasPremiumAccessProvider);
    if (!hasAccess && _remainingToday <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Wykorzystałeś dzisiejszy limit (${AppConstants.aiAdviceDailyLimit} zapytań). Spróbuj jutro lub przejdź na Premium.',
            ),
          ),
        );
      }
      return;
    }
    if (OpenAIService.apiKey == null || OpenAIService.apiKey!.isEmpty) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, error: 'Klucz OpenAI nie jest skonfigurowany.');
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
          if (!ref.read(hasPremiumAccessProvider)) await _recordQuery();
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
        ErrorHandler.showSnackBar(context, error: e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAccess = ref.watch(hasPremiumAccessProvider);
    final canAsk = (hasAccess || _remainingToday > 0) && !_isLoading;

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
                  hasAccess
                      ? 'Premium – nieograniczona liczba zapytań'
                      : 'Pozostało zapytań dziś: $_remainingToday / ${AppConstants.aiAdviceDailyLimit}',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Zapytaj o poradę w zakresie diety, odżywiania lub aktywności fizycznej.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'np. Ile białka potrzebuję przy treningu siłowym?',
                      border: const OutlineInputBorder(),
                      filled: true,
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
                    onSubmitted: canAsk ? (_) => _askAi() : null,
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
        ],
      ),
    );
  }
}
