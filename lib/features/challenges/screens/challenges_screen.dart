import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import '../../../core/config/supabase_config.dart';
import '../../../shared/models/goal_challenge.dart';
import '../../../shared/services/supabase_service.dart';

final challengesProvider = FutureProvider.autoDispose<List<GoalChallenge>>((ref) async {
  final userId = SupabaseConfig.auth.currentUser?.id;
  if (userId == null) throw Exception('User not logged in');

  final service = SupabaseService();
  return await service.getGoalChallenges(userId);
});

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final challengesAsync = ref.watch(challengesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moreChallengesTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddChallengeDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: challengesAsync.when(
        data: (challenges) {
          if (challenges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.moreNoChallenges,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.moreNoChallengesHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(challengesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: challenges.map((challenge) => _buildChallengeCard(context, ref, challenge)).toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.moreErrorWithDetails(error: error.toString())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(challengesProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, WidgetRef ref, GoalChallenge challenge) {
    final l10n = context.l10n;
    final progress = challenge.progress;
    final isOverdue = challenge.endDate != null && 
                      challenge.endDate!.isBefore(DateTime.now()) && 
                      !challenge.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: challenge.isCompleted 
          ? Colors.green.shade50 
          : isOverdue 
              ? Colors.red.shade50 
              : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (challenge.isCompleted)
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          if (isOverdue)
                            const Icon(Icons.warning, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              challenge.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: challenge.isCompleted 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (challenge.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          challenge.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteChallenge(context, ref, challenge),
                ),
              ],
            ),
            if (challenge.targetValue != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.moreProgressPercent(
                      percent: (progress * 100).toStringAsFixed(0),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (challenge.currentValue != null && challenge.targetValue != null)
                    Text(
                      '${challenge.currentValue!.toStringAsFixed(1)} / ${challenge.targetValue!.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                minHeight: 8,
                color: challenge.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  l10n.moreStartDate(date: _formatDate(challenge.startDate)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (challenge.endDate != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.event, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    l10n.moreEndDate(date: _formatDate(challenge.endDate!)),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddChallengeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddChallengeDialog(
        onChallengeAdded: () {
          ref.invalidate(challengesProvider);
        },
      ),
    );
  }

  Future<void> _deleteChallenge(BuildContext context, WidgetRef ref, GoalChallenge challenge) async {
    if (challenge.id == null) return;
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.moreDeleteChallengeTitle),
        content: Text(l10n.moreDeleteChallengeConfirm(title: challenge.title)),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = SupabaseService();
        await service.deleteGoalChallenge(challenge.id!);
        if (context.mounted) {
          ref.invalidate(challengesProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.moreChallengeDeleted)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.moreErrorWithDetails(error: e.toString()))),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

class _AddChallengeDialog extends StatefulWidget {
  final VoidCallback onChallengeAdded;

  const _AddChallengeDialog({required this.onChallengeAdded});

  @override
  State<_AddChallengeDialog> createState() => _AddChallengeDialogState();
}

class _AddChallengeDialogState extends State<_AddChallengeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetValueController;
  String _selectedType = 'weight_loss';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _hasEndDate = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _targetValueController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final l10n = context.l10n;
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      helpText: l10n.morePickStartDate,
      cancelText: l10n.commonCancel,
      confirmText: l10n.morePick,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final l10n = context.l10n;
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      helpText: l10n.morePickEndDate,
      cancelText: l10n.commonCancel,
      confirmText: l10n.morePick,
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _saveChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final challenge = GoalChallenge(
        userId: userId,
        type: _selectedType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetValue: _targetValueController.text.isNotEmpty
            ? double.tryParse(_targetValueController.text)
            : null,
        currentValue: 0,
        startDate: _startDate,
        endDate: _hasEndDate ? _endDate : null,
      );

      final service = SupabaseService();
      await service.createGoalChallenge(challenge);

      if (mounted) {
        context.pop();
        widget.onChallengeAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.moreChallengeAdded)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.moreErrorWithDetails(error: e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _getTargetValueLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'weight_loss':
        return l10n.moreTargetWeightKg;
      case 'calorie_deficit':
        return l10n.moreCalorieDeficitKcal;
      case 'water':
        return l10n.moreWaterAmountMl;
      case 'exercise':
        return l10n.moreWorkoutCount;
      case 'streak':
        return l10n.moreStreakLengthDays;
      default:
        return l10n.moreTargetValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.moreAddChallenge,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: l10n.moreChallengeType,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'weight_loss', child: Text(l10n.moreGoalWeightLoss)),
                    DropdownMenuItem(value: 'calorie_deficit', child: Text(l10n.moreCalorieDeficit)),
                    DropdownMenuItem(value: 'water', child: Text(l10n.moreWater)),
                    DropdownMenuItem(value: 'exercise', child: Text(l10n.moreExercise)),
                    DropdownMenuItem(value: 'streak', child: Text(l10n.moreStreak)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.moreChallengeTitleLabel,
                    border: const OutlineInputBorder(),
                    hintText: l10n.moreChallengeTitleHint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.moreChallengeTitleRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.moreDescriptionOptional,
                    border: const OutlineInputBorder(),
                    hintText: l10n.moreChallengeDescHint,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _targetValueController,
                  decoration: InputDecoration(
                    labelText: _getTargetValueLabel(l10n, _selectedType),
                    border: const OutlineInputBorder(),
                    hintText: l10n.moreOptional,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectStartDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.moreStartDateLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_startDate.day}.${_startDate.month}.${_startDate.year}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _hasEndDate,
                      onChanged: (value) {
                        setState(() {
                          _hasEndDate = value ?? false;
                          if (!_hasEndDate) {
                            _endDate = null;
                          } else {
                            _endDate ??= _startDate.add(const Duration(days: 30));
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Text(l10n.moreSetEndDate),
                    ),
                  ],
                ),
                if (_hasEndDate) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectEndDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.moreEndDateLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.event),
                      ),
                      child: Text(
                        _endDate != null
                            ? '${_endDate!.day}.${_endDate!.month}.${_endDate!.year}'
                            : l10n.morePickDate,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: Text(l10n.commonCancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveChallenge,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.moreAdd),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
