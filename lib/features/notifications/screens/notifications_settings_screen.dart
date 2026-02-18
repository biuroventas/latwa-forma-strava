import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/services/notification_service.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  static const _keyWaterReminders = 'notification_water_reminders';
  static const _keyMealReminders = 'notification_meal_reminders';

  List<_WaterReminder> _waterReminders = [
    _WaterReminder(enabled: false, hour: 9, minute: 0),
  ];
  List<_MealReminder> _mealReminders = [
    _MealReminder(label: 'Śniadanie', enabled: false, hour: 8, minute: 0),
    _MealReminder(label: 'Obiad', enabled: false, hour: 13, minute: 0),
    _MealReminder(label: 'Kolacja', enabled: false, hour: 19, minute: 0),
    _MealReminder(label: 'Przekąska', enabled: false, hour: 16, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final waterJson = prefs.getString(_keyWaterReminders);
    final mealJson = prefs.getString(_keyMealReminders);

    if (waterJson != null) {
      try {
        final list = jsonDecode(waterJson) as List;
        setState(() {
          _waterReminders = list
              .map((e) => _WaterReminder(
                    enabled: e['enabled'] as bool? ?? false,
                    hour: e['hour'] as int? ?? 9,
                    minute: e['minute'] as int? ?? 0,
                  ))
              .toList();
        });
      } catch (_) {}
    }
    if (mealJson != null) {
      try {
        final list = jsonDecode(mealJson) as List;
        setState(() {
          _mealReminders = list
              .map((e) => _MealReminder(
                    label: e['label'] as String? ?? 'Posiłek',
                    enabled: e['enabled'] as bool? ?? false,
                    hour: e['hour'] as int? ?? 12,
                    minute: e['minute'] as int? ?? 0,
                  ))
              .toList();
        });
      } catch (_) {}
    }
    _rescheduleAll();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyWaterReminders,
      jsonEncode(_waterReminders.map((r) => r.toJson()).toList()),
    );
    await prefs.setString(
      _keyMealReminders,
      jsonEncode(_mealReminders.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> _rescheduleAll() async {
    await NotificationService.cancelAllWaterReminders();
    await NotificationService.cancelAllMealReminders();
    for (var i = 0; i < _waterReminders.length; i++) {
      if (_waterReminders[i].enabled) {
        await NotificationService.scheduleWaterReminder(
          id: i,
          hour: _waterReminders[i].hour,
          minute: _waterReminders[i].minute,
        );
      }
    }
    for (var i = 0; i < _mealReminders.length; i++) {
      if (_mealReminders[i].enabled) {
        await NotificationService.scheduleMealReminder(
          id: i,
          label: _mealReminders[i].label,
          hour: _mealReminders[i].hour,
          minute: _mealReminders[i].minute,
        );
      }
    }
  }

  Future<void> _updateWaterReminder(int index, _WaterReminder updated) async {
    setState(() {
      _waterReminders[index] = updated;
    });
    await _saveToPrefs();
    await NotificationService.cancelWaterReminder(index);
    if (updated.enabled) {
      await NotificationService.scheduleWaterReminder(
        id: index,
        hour: updated.hour,
        minute: updated.minute,
      );
    }
  }

  Future<void> _updateMealReminder(int index, _MealReminder updated) async {
    setState(() {
      _mealReminders[index] = updated;
    });
    await _saveToPrefs();
    await NotificationService.cancelMealReminder(index);
    if (updated.enabled) {
      await NotificationService.scheduleMealReminder(
        id: index,
        label: updated.label,
        hour: updated.hour,
        minute: updated.minute,
      );
    }
  }

  Future<void> _addWaterReminder() async {
    if (_waterReminders.length >= 50) return;
    setState(() {
      _waterReminders.add(_WaterReminder(enabled: true, hour: 9, minute: 0));
    });
    await _saveToPrefs();
    await _rescheduleAll();
  }

  Future<void> _removeWaterReminder(int index) async {
    if (_waterReminders.length <= 1) return;
    setState(() => _waterReminders.removeAt(index));
    await _saveToPrefs();
    await _rescheduleAll();
  }

  Future<void> _addMealReminder() async {
    if (_mealReminders.length >= 50) return;
    final label = await showDialog<String>(
      context: context,
      builder: (context) => _MealNameDialog(),
    );
    if (label != null && label.isNotEmpty) {
      setState(() {
        _mealReminders.add(_MealReminder(
          label: label,
          enabled: true,
          hour: 12,
          minute: 0,
        ));
      });
      await _saveToPrefs();
      await _rescheduleAll();
    }
  }

  Future<void> _removeMealReminder(int index) async {
    if (_mealReminders.length <= 1) return;
    setState(() => _mealReminders.removeAt(index));
    await _saveToPrefs();
    await _rescheduleAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Powiadomienia'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Przypomnienia o wodzie
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Przypomnienia o wodzie',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _waterReminders.length < 50
                            ? _addWaterReminder
                            : null,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Dodaj'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_waterReminders.length, (i) {
                    final r = _waterReminders[i];
                    return _buildWaterReminderRow(i, r);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Przypomnienia o posiłkach
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Przypomnienia o posiłkach',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed:
                            _mealReminders.length < 50 ? _addMealReminder : null,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Dodaj'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_mealReminders.length, (i) {
                    final r = _mealReminders[i];
                    return _buildMealReminderRow(i, r);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterReminderRow(int index, _WaterReminder r) {
    return Column(
      children: [
        if (index > 0) const Divider(),
        Row(
          children: [
            Switch(
              value: r.enabled,
              onChanged: (value) {
                _updateWaterReminder(
                    index, r.copyWith(enabled: value));
              },
            ),
            Expanded(
              child: ListTile(
                leading: const Icon(Icons.access_time, size: 20),
                title: Text(
                  '${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: r.hour, minute: r.minute),
                        );
                        if (picked != null) {
                          _updateWaterReminder(index, r.copyWith(
                            hour: picked.hour,
                            minute: picked.minute,
                          ));
                        }
                      },
                    ),
                    if (_waterReminders.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _removeWaterReminder(index),
                      ),
                  ],
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: r.hour, minute: r.minute),
                  );
                  if (picked != null) {
                    _updateWaterReminder(index, r.copyWith(
                      hour: picked.hour,
                      minute: picked.minute,
                    ));
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealReminderRow(int index, _MealReminder r) {
    return Column(
      children: [
        if (index > 0) const Divider(),
        Row(
          children: [
            Switch(
              value: r.enabled,
              onChanged: (value) {
                _updateMealReminder(index, r.copyWith(enabled: value));
              },
            ),
            Expanded(
              child: ListTile(
                leading: const Icon(Icons.restaurant_menu, size: 20),
                title: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    r.label,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                subtitle: Text(
                  '${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () async {
                        final result = await showDialog<_MealEditResult>(
                          context: context,
                          builder: (context) => _MealEditDialog(
                            label: r.label,
                            hour: r.hour,
                            minute: r.minute,
                          ),
                        );
                        if (result != null) {
                          _updateMealReminder(index, r.copyWith(
                            label: result.label,
                            hour: result.hour,
                            minute: result.minute,
                          ));
                        }
                      },
                    ),
                    if (_mealReminders.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _removeMealReminder(index),
                      ),
                  ],
                ),
                onTap: () async {
                  final result = await showDialog<_MealEditResult>(
                    context: context,
                    builder: (context) => _MealEditDialog(
                      label: r.label,
                      hour: r.hour,
                      minute: r.minute,
                    ),
                  );
                  if (result != null) {
                    _updateMealReminder(index, r.copyWith(
                      label: result.label,
                      hour: result.hour,
                      minute: result.minute,
                    ));
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WaterReminder {
  final bool enabled;
  final int hour;
  final int minute;

  _WaterReminder({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
      };

  _WaterReminder copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) =>
      _WaterReminder(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );
}

class _MealReminder {
  final String label;
  final bool enabled;
  final int hour;
  final int minute;

  _MealReminder({
    required this.label,
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
      };

  _MealReminder copyWith({
    String? label,
    bool? enabled,
    int? hour,
    int? minute,
  }) =>
      _MealReminder(
        label: label ?? this.label,
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );
}

class _MealNameDialog extends StatefulWidget {
  @override
  State<_MealNameDialog> createState() => _MealNameDialogState();
}

class _MealNameDialogState extends State<_MealNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'Posiłek');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nowe przypomnienie o posiłku'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Nazwa posiłku',
          hintText: 'np. Drugie śniadanie, Podwieczorek',
        ),
        onSubmitted: (value) => context.pop(value.trim().isEmpty ? 'Posiłek' : value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () => context.pop(
            _controller.text.trim().isEmpty ? 'Posiłek' : _controller.text.trim(),
          ),
          child: const Text('Dodaj'),
        ),
      ],
    );
  }
}

class _MealEditResult {
  final String label;
  final int hour;
  final int minute;

  _MealEditResult({
    required this.label,
    required this.hour,
    required this.minute,
  });
}

class _MealEditDialog extends StatefulWidget {
  final String label;
  final int hour;
  final int minute;

  const _MealEditDialog({
    required this.label,
    required this.hour,
    required this.minute,
  });

  @override
  State<_MealEditDialog> createState() => _MealEditDialogState();
}

class _MealEditDialogState extends State<_MealEditDialog> {
  late TextEditingController _labelController;
  TimeOfDay _time = const TimeOfDay(hour: 12, minute: 0);

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.label);
    _time = TimeOfDay(hour: widget.hour, minute: widget.minute);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edytuj przypomnienie'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Nazwa posiłku',
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(
              '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickTime,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () => context.pop(
            _MealEditResult(
              label: _labelController.text.trim().isEmpty ? widget.label : _labelController.text.trim(),
              hour: _time.hour,
              minute: _time.minute,
            ),
          ),
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}
