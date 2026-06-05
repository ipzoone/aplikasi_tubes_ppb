import 'package:flutter/material.dart';
import 'package:skilltrackit/models/skill_model.dart';
import 'package:skilltrackit/providers/skill_service.dart';

class AddSkillPage extends StatefulWidget {
  final Skill? skill;
  const AddSkillPage({super.key, this.skill});

  @override
  State<AddSkillPage> createState() => _AddSkillPageState();
}

class _AddSkillPageState extends State<AddSkillPage> {
  final SkillService _skillService = SkillService();
  final _nameController = TextEditingController();
  double _currentLevel = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.skill != null) {
      _nameController.text = widget.skill!.name;
      _currentLevel = widget.skill!.level;
    }
  }

  String get _status {
    if (_currentLevel < 30) return 'Beginner';
    if (_currentLevel < 70) return 'Intermediate';
    return 'Master';
  }

  Future<void> _saveSkill() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final skillData = Skill(
        id: widget.skill?.id,
        name: _nameController.text,
        level: _currentLevel,
        status: _status,
      );

      if (widget.skill == null) {
        // Create
        await _skillService.createSkill(skillData);
      } else {
        // Update
        await _skillService.updateSkill(widget.skill!.id!, skillData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill berhasil disimpan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan skill: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skill == null ? 'Tambah Skill Baru' : 'Edit Skill'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apa yang lagi kamu pelajari?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Skill / Bahasa Pemrograman',
                hintText: 'Misal: Python, React, AWS...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Tingkat Pemahaman: ${_currentLevel.round()}% ($_status)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _currentLevel,
              min: 0,
              max: 100,
              divisions: 10,
              label: '${_currentLevel.round()}%',
              onChanged: (value) {
                setState(() {
                  _currentLevel = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Beginner', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Master', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSkill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan Skill', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
