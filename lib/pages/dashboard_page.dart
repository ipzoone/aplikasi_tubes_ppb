import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skilltrackit/pages/add_skill_page.dart';
import 'package:skilltrackit/pages/schedule_page.dart';
import 'package:skilltrackit/models/skill_model.dart';
import 'package:skilltrackit/providers/skill_service.dart';
import 'package:skilltrackit/providers/auth_provider.dart';
import 'package:skilltrackit/pages/login_page.dart';
import 'package:skilltrackit/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentTab = 0;
  final SkillService _skillService = SkillService();
  
  // Real calendar state
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  
  // Search state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Reload skills data
  void _triggerRefresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeColor = Colors.cyan.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab,
          children: [
            _buildHomeTab(authProvider, themeColor),
            _buildCalendarTab(themeColor),
            const SchedulePage(),
            _buildSettingsTab(authProvider, themeColor),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Home Tab Button
              IconButton(
                icon: Icon(
                  Icons.home_rounded,
                  color: _currentTab == 0 ? themeColor : Colors.grey.shade400,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _currentTab = 0;
                  });
                },
                tooltip: 'Beranda',
              ),
              // Calendar Tab Button
              IconButton(
                icon: Icon(
                  Icons.calendar_month_rounded,
                  color: _currentTab == 1 ? themeColor : Colors.grey.shade400,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _currentTab = 1;
                  });
                },
                tooltip: 'Kalender',
              ),
              const SizedBox(width: 40), // Space for FAB
              // Schedule Tab Button
              IconButton(
                icon: Icon(
                  Icons.event_note_rounded,
                  color: _currentTab == 2 ? themeColor : Colors.grey.shade400,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _currentTab = 2;
                  });
                },
                tooltip: 'Jadwal',
              ),
              // Settings Tab Button
              IconButton(
                icon: Icon(
                  Icons.settings_rounded,
                  color: _currentTab == 3 ? themeColor : Colors.grey.shade400,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _currentTab = 3;
                  });
                },
                tooltip: 'Pengaturan',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSkillPage()),
          );
          _triggerRefresh();
        },
        backgroundColor: themeColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ----------------------------------------------------
  // HOME TAB
  // ----------------------------------------------------
  Widget _buildHomeTab(AuthProvider auth, Color themeColor) {
    // Generate week days
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => firstDayOfWeek.add(Duration(days: i)));
    final List<String> dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return FutureBuilder<List<Skill>>(
      future: _skillService.getSkills(),
      builder: (context, snapshot) {
        final List<Skill> allSkills = snapshot.data ?? [];
        
        // Filter skills based on search
        final filteredSkills = allSkills.where((skill) {
          return skill.name.toLowerCase().contains(_searchQuery);
        }).toList();

        // Categorize count
        int beginnerCount = allSkills.where((s) => s.status.toLowerCase() == 'beginner').length;
        int intermediateCount = allSkills.where((s) => s.status.toLowerCase() == 'intermediate').length;
        int masterCount = allSkills.where((s) => s.status.toLowerCase() == 'master').length;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${auth.userName}!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pantau progres belajar IT kamu.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentTab = 3),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeColor.withOpacity(0.2)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: auth.userAvatar != null && auth.userAvatar!.isNotEmpty
                            ? Image.network(
                                auth.userAvatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.person_rounded, color: themeColor),
                              )
                            : Icon(Icons.person_rounded, color: themeColor, size: 26),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari skill...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Weekly Calendar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tugas Mingguan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    '${_getMonthName(now.month)} ${now.year}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Weekly Date strip
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final dayDate = weekDays[index];
                    final isTodaySelected = dayDate.day == _selectedDate.day &&
                        dayDate.month == _selectedDate.month &&
                        dayDate.year == _selectedDate.year;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = dayDate;
                        });
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 40) / 7 - 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isTodaySelected ? themeColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (!isTodaySelected)
                              BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayNames[index],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isTodaySelected ? Colors.white70 : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dayDate.day.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isTodaySelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Overview Cards (Mockup Screen 1 & 2 categories list)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('Beginner', beginnerCount, Colors.orange.shade400),
                  _buildStatCard('Intermediate', intermediateCount, Colors.cyan.shade600),
                  _buildStatCard('Master', masterCount, Colors.green.shade400),
                ],
              ),
              const SizedBox(height: 24),

              // Skill List section
              const Text(
                'Daftar Skill Aktif',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ))
              else if (snapshot.hasError)
                Center(child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Gagal mengambil data: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                ))
              else if (filteredSkills.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.bubble_chart_outlined, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty ? 'Skill tidak ditemukan' : 'Belum ada skill ditambahkan',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredSkills.length,
                  itemBuilder: (context, index) {
                    final skill = filteredSkills[index];
                    return _buildSkillCard(skill, themeColor);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(Skill skill, Color themeColor) {
    Color badgeColor;
    switch (skill.status.toLowerCase()) {
      case 'beginner':
        badgeColor = Colors.orange.shade400;
        break;
      case 'intermediate':
        badgeColor = Colors.cyan.shade600;
        break;
      default:
        badgeColor = Colors.green.shade400;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  skill.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddSkillPage(skill: skill)),
                      );
                      _triggerRefresh();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit_rounded, color: Colors.cyan.shade700, size: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus Skill'),
                          content: const Text('Apakah Anda yakin ingin menghapus skill ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _skillService.deleteSkill(skill.id!);
                        _triggerRefresh();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete_rounded, color: Colors.red.shade400, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              skill.status,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
            ),
          ),
          const SizedBox(height: 14),
          // Level progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tingkat Penguasaan',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Text(
                '${skill.level.round()}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: themeColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: skill.level / 100,
              backgroundColor: Colors.grey.shade100,
              color: themeColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // CALENDAR TAB
  // ----------------------------------------------------
  Widget _buildCalendarTab(Color themeColor) {
    // Days in Month generator
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1 = Mon, ..., 7 = Sun
    
    // Grid list builder
    final List<int?> calendarCells = [];
    // Pad first days
    for (int i = 1; i < firstWeekday; i++) {
      calendarCells.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      calendarCells.add(i);
    }

    final List<String> shortWeekdays = ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'];

    return FutureBuilder<List<Skill>>(
      future: _skillService.getSkills(),
      builder: (context, snapshot) {
        final List<Skill> allSkills = snapshot.data ?? [];
        
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Kalender Kegiatan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Daftar progres skill berdasarkan waktu.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Calendar Card Wrapper
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Month selector strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                            });
                          },
                        ),
                        Text(
                          '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Calendar columns headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: shortWeekdays.map((day) {
                        return SizedBox(
                          width: 32,
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Calendar Grid cells
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: calendarCells.length,
                      itemBuilder: (context, index) {
                        final cellVal = calendarCells[index];
                        if (cellVal == null) return const SizedBox();

                        final cellDate = DateTime(_currentMonth.year, _currentMonth.month, cellVal);
                        final isSelected = cellDate.day == _selectedDate.day &&
                            cellDate.month == _selectedDate.month &&
                            cellDate.year == _selectedDate.year;
                        
                        final isToday = cellDate.day == DateTime.now().day &&
                            cellDate.month == DateTime.now().month &&
                            cellDate.year == DateTime.now().year;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = cellDate;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? themeColor : Colors.transparent,
                              shape: BoxShape.circle,
                              border: isToday && !isSelected
                                  ? Border.all(color: themeColor, width: 1.5)
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cellVal.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : (isToday ? themeColor : Colors.black87),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Calendar Tasks details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kegiatan ${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${allSkills.length} Total',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (allSkills.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      'Tidak ada kegiatan belajar terdaftar',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allSkills.length,
                  itemBuilder: (context, index) {
                    final skill = allSkills[index];
                    return _buildSkillCard(skill, themeColor);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // SETTINGS TAB
  // ----------------------------------------------------
  Widget _buildSettingsTab(AuthProvider auth, Color themeColor) {
    final nameController = TextEditingController(text: auth.userName);
    final formKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Pengaturan Profil',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Sesuaikan informasi dan preferensi akun Anda.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Profile Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor.withOpacity(0.2), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: auth.userAvatar != null && auth.userAvatar!.isNotEmpty
                        ? Image.network(
                            auth.userAvatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.person_rounded, color: themeColor, size: 36),
                          )
                        : Icon(Icons.person_rounded, color: themeColor, size: 36),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.userEmail.isNotEmpty ? auth.userEmail : 'Email tidak terdaftar',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Change Name Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubah Nama Akun',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama baru',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: themeColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama tidak boleh kosong!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await auth.updateLocalName(nameController.text.trim());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama berhasil disimpan!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // About App Info List
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                _buildInfoTile(Icons.color_lens_rounded, 'Tema Aktif', 'Solid Cyan (Solid)', themeColor),
                const Divider(height: 1),
                _buildInfoTile(Icons.info_outline_rounded, 'Versi Aplikasi', '1.0.0', themeColor),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Notifikasi Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifikasi Jadwal',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'Untuk Xiaomi: pastikan Battery Saver = No Restrictions dan Autostart = ON',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 14),
                // Test button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await NotificationService().testNotificationIn5Seconds();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notif langsung + terjadwal 10 detik dikirim. Minimize app!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.notifications_active_rounded, size: 18),
                    label: const Text('Test Notifikasi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.cyan.shade600,
                      side: BorderSide(color: Colors.cyan.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Buka app settings Xiaomi
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Buka halaman settings app (battery, autostart, dll)
                      await openAppSettings();
                    },
                    icon: const Icon(Icons.settings_applications_rounded, size: 18),
                    label: const Text('Buka Pengaturan Izin App'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                foregroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => _handleLogout(context, auth),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Keluar Akun', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value, Color themeColor) {
    return ListTile(
      leading: Icon(icon, color: themeColor),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      trailing: Text(value, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }
      
      await auth.logout();
      
      if (context.mounted) {
        Navigator.pop(context); // Pop loading spinner
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  // Helper helper to format months
  String _getMonthName(int monthNum) {
    if (monthNum < 1 || monthNum > 12) return "";
    return _monthNames[monthNum - 1];
  }

  static const List<String> _monthNames = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember"
  ];
}
