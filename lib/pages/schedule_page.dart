import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study_schedule_model.dart';
import '../providers/schedule_provider.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _selectedDay = DateTime.now().weekday; // 1=Senin ... 7=Minggu

  final List<String> _dayNames = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
  ];
  final List<String> _dayNamesLong = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.cyan.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jadwal Belajar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Atur jadwal mingguan kamu',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  FloatingActionButton.small(
                    heroTag: 'add_schedule',
                    onPressed: () => _showScheduleForm(context),
                    backgroundColor: themeColor,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Day selector
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final isSelected = day == _selectedDay;
                  final isToday = day == DateTime.now().weekday;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: Container(
                      width: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? themeColor : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: isToday && !isSelected
                            ? Border.all(color: themeColor, width: 1.5)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? themeColor.withValues(alpha: 0.3)
                                : Colors.grey.shade100,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _dayNames[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white70 : Colors.grey.shade500,
                            ),
                          ),
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : themeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Day label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _dayNamesLong[_selectedDay - 1],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Schedule list
            Expanded(
              child: Consumer<ScheduleProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off_rounded,
                              size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => provider.fetchSchedules(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  final daySchedules = provider.schedulesForDay(_selectedDay);

                  if (daySchedules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_note_rounded,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada jadwal untuk ${_dayNamesLong[_selectedDay - 1]}',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + untuk menambahkan jadwal',
                            style: TextStyle(
                                color: Colors.grey.shade300, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: daySchedules.length,
                    itemBuilder: (context, index) {
                      return _buildScheduleCard(
                          context, daySchedules[index], themeColor);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
      BuildContext context, StudySchedule schedule, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: schedule.isActive ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: schedule.isActive
              ? themeColor.withValues(alpha: 0.15)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time block
          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: schedule.isActive
                  ? themeColor.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  schedule.startTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: schedule.isActive ? themeColor : Colors.grey,
                  ),
                ),
                Text(
                  '|',
                  style: TextStyle(
                      color: schedule.isActive
                          ? themeColor.withValues(alpha: 0.5)
                          : Colors.grey.shade300,
                      fontSize: 10),
                ),
                Text(
                  schedule.endTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: schedule.isActive ? themeColor : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Title & description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color:
                        schedule.isActive ? Colors.black87 : Colors.grey.shade400,
                    decoration:
                        schedule.isActive ? null : TextDecoration.lineThrough,
                  ),
                ),
                if (schedule.description != null &&
                    schedule.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    schedule.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      size: 13,
                      color: schedule.isActive
                          ? Colors.green.shade400
                          : Colors.grey.shade300,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule.isActive ? 'Notif aktif' : 'Notif nonaktif',
                      style: TextStyle(
                        fontSize: 11,
                        color: schedule.isActive
                            ? Colors.green.shade400
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              Switch.adaptive(
                value: schedule.isActive,
                activeColor: themeColor,
                onChanged: (val) {
                  context
                      .read<ScheduleProvider>()
                      .toggleSchedule(schedule.id!, val);
                },
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showScheduleForm(context, schedule: schedule),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit_rounded,
                          color: Colors.cyan.shade700, size: 15),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _confirmDelete(context, schedule),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete_rounded,
                          color: Colors.red.shade400, size: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, StudySchedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Jadwal'),
        content: Text(
            'Yakin ingin menghapus jadwal "${schedule.title}"?\nNotifikasi juga akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final result =
          await context.read<ScheduleProvider>().deleteSchedule(schedule.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['success'] == true
              ? 'Jadwal berhasil dihapus'
              : result['message'] ?? 'Gagal menghapus'),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              result['success'] == true ? Colors.green.shade600 : Colors.red,
        ));
      }
    }
  }

  void _showScheduleForm(BuildContext context, {StudySchedule? schedule}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScheduleFormSheet(
        schedule: schedule,
        initialDay: _selectedDay,
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// FORM BOTTOM SHEET
// ──────────────────────────────────────────────────
class ScheduleFormSheet extends StatefulWidget {
  final StudySchedule? schedule;
  final int initialDay;

  const ScheduleFormSheet({
    super.key,
    this.schedule,
    required this.initialDay,
  });

  @override
  State<ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<ScheduleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late int _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isLoading = false;

  final List<String> _dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      final s = widget.schedule!;
      _titleController.text = s.title;
      _descController.text = s.description ?? '';
      _selectedDay = s.dayOfWeek;
      final startParts = s.startTime.split(':');
      final endParts = s.endTime.split(':');
      _startTime =
          TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
      _endTime =
          TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
    } else {
      _selectedDay = widget.initialDay;
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay(
          hour: (TimeOfDay.now().hour + 1) % 24,
          minute: TimeOfDay.now().minute);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _timeStr(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi waktu
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Waktu selesai harus lebih dari waktu mulai'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<ScheduleProvider>();
    final newSchedule = StudySchedule(
      id: widget.schedule?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      dayOfWeek: _selectedDay,
      startTime: _timeStr(_startTime),
      endTime: _timeStr(_endTime),
      isActive: widget.schedule?.isActive ?? true,
    );

    Map<String, dynamic> result;
    if (widget.schedule == null) {
      result = await provider.addSchedule(newSchedule);
    } else {
      result = await provider.updateSchedule(widget.schedule!.id!, newSchedule);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.schedule == null
              ? 'Jadwal berhasil ditambahkan! Notifikasi diatur.'
              : 'Jadwal berhasil diperbarui!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'Gagal menyimpan jadwal'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.cyan.shade600;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                widget.schedule == null ? 'Tambah Jadwal Baru' : 'Edit Jadwal',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Nama Jadwal / Skill',
                  hintText: 'Misal: Belajar Flutter, React JS...',
                  prefixIcon: const Icon(Icons.school_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: themeColor, width: 2),
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama jadwal wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  hintText: 'Misal: Fokus pada state management...',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: themeColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Day picker
              DropdownButtonFormField<int>(
                value: _selectedDay,
                decoration: InputDecoration(
                  labelText: 'Hari',
                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: themeColor, width: 2),
                  ),
                ),
                items: List.generate(7, (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(_dayNames[i]),
                )),
                onChanged: (v) => setState(() => _selectedDay = v!),
              ),
              const SizedBox(height: 14),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Mulai',
                      time: _startTime,
                      onTap: () => _pickTime(true),
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Selesai',
                      time: _endTime,
                      onTap: () => _pickTime(false),
                      color: themeColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_active_rounded,
                                size: 18),
                            const SizedBox(width: 8),
                            Text(
                              widget.schedule == null
                                  ? 'Simpan & Aktifkan Notifikasi'
                                  : 'Simpan Perubahan',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                Text(
                  _timeStr(time),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
