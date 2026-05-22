import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/features/habits/domain/entities/habit.dart';
import 'package:better_life_app/features/habits/domain/entities/week_day_utils.dart';
import 'package:better_life_app/features/habits/domain/utils/icon_mapper.dart';
import 'package:better_life_app/features/habits/presentation/providers.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_state.dart';

/// Form screen for creating or editing a habit.
///
/// When [habitId] is provided, the form attempts to pre-populate from the
/// currently loaded habits state.
class HabitFormScreen extends ConsumerStatefulWidget {
  final String? habitId;

  const HabitFormScreen({super.key, this.habitId});

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _selectedCategoryId;
  int _frequencyType = 0;
  int _weekDays = 0;
  TimeOfDay? _reminderTime;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _populateFromExisting(widget.habitId!);
    }
  }

  void _populateFromExisting(String id) {
    final state = ref.read(habitsNotifierProvider);
    if (state is HabitsLoaded) {
      try {
        final habit = state.habits.firstWhere((h) => h.id == id);
        _nameController.text = habit.name;
        _selectedCategoryId = habit.categoryId;
        _frequencyType = habit.frequencyType;
        _weekDays = habit.weekDays;
        _reminderTime = apiToTimeOfDay(habit.reminderTime);
      } catch (_) {
        // habit not found — leave form empty
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    setState(() => _isSaving = true);

    final id = widget.habitId ?? ref.read(uuidProvider).v4();
    final habit = Habit(
      id: id,
      userId: '', // backend ignores this on upsert
      categoryId: _selectedCategoryId!,
      name: _nameController.text.trim(),
      frequencyType: _frequencyType,
      weekDays: _frequencyType == 1 ? _weekDays : 0,
      reminderTime: timeOfDayToApi(_reminderTime),
      status: 0,
      createdAt: '',
      updatedAt: '',
    );

    ref.read(habitsNotifierProvider.notifier).upsert(habit).then((_) {
      if (mounted) context.pop();
    }).catchError((_) {
      if (mounted) setState(() => _isSaving = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habitId != null;
    final canSave = _nameController.text.trim().isNotEmpty &&
        _nameController.text.length <= 200 &&
        _selectedCategoryId != null &&
        !_isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Hábito' : 'Nuevo Hábito'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Name ────────────────────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                counterText: '',
              ),
              maxLength: 200,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (value.length > 200) {
                  return 'Máximo 200 caracteres';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // ── Category ────────────────────────────────────────────────────
            const Text('Categoría', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoriesProvider);
                return categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) return const SizedBox.shrink();
                    return Wrap(
                      spacing: 8,
                      children: categories.map((cat) {
                        final selected = _selectedCategoryId == cat.id;
                        return ChoiceChip(
                          label: Text(cat.name),
                          avatar: Icon(iconFromName(cat.icon), size: 18),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 16),

            // ── Frequency ────────────────────────────────────────────────────
            const Text('Frecuencia', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _frequencyType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Diario')),
                DropdownMenuItem(value: 1, child: Text('Personalizado')),
                DropdownMenuItem(value: 2, child: Text('Semanal')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _frequencyType = value;
                    if (_frequencyType != 1) _weekDays = 0;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // ── WeekDays (only for SpecificWeekDays) ────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _frequencyType == 1
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Días de la semana',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _DayChip(day: 1, label: 'L', selected: _weekDays, onToggle: _toggleDay),
                            _DayChip(day: 2, label: 'M', selected: _weekDays, onToggle: _toggleDay),
                            _DayChip(day: 3, label: 'X', selected: _weekDays, onToggle: _toggleDay),
                            _DayChip(day: 4, label: 'J', selected: _weekDays, onToggle: _toggleDay),
                            _DayChip(day: 5, label: 'V', selected: _weekDays, onToggle: _toggleDay),
                            _DayChip(day: 6, label: 'S', selected: _weekDays, onToggle: _toggleDay),
                            _DayChip(day: 7, label: 'D', selected: _weekDays, onToggle: _toggleDay),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Reminder Time ──────────────────────────────────────────────
            const Text('Recordatorio', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _reminderTime != null
                          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                          : 'Seleccionar hora',
                    ),
                  ),
                ),
                if (_reminderTime != null)
                  IconButton(
                    onPressed: () => setState(() => _reminderTime = null),
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Save ─────────────────────────────────────────────────────────
            ElevatedButton(
              onPressed: canSave ? _save : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleDay(int day) {
    setState(() {
      final flag = 1 << (day - 1);
      if (_weekDays & flag == flag) {
        _weekDays &= ~flag;
      } else {
        _weekDays |= flag;
      }
    });
  }
}

class _DayChip extends StatelessWidget {
  final int day;
  final String label;
  final int selected;
  final ValueChanged<int> onToggle;

  const _DayChip({
    required this.day,
    required this.label,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final flag = 1 << (day - 1);
    final isSelected = selected & flag == flag;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onToggle(day),
    );
  }
}
