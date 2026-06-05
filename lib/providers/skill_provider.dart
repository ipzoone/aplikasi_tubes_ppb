import 'package:flutter/material.dart';
import '../providers/skill_service.dart';
import '../models/skill_model.dart';

class SkillProvider with ChangeNotifier {
  final SkillService _skillService = SkillService();
  List<Skill> _skills = [];
  bool _isLoading = false;
  String? _error;

  List<Skill> get skills => _skills;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSkills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _skills = await _skillService.getSkills();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addSkill(Skill skill) async {
    try {
      await _skillService.createSkill(skill);
      await fetchSkills();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateSkill(int id, Skill skill) async {
    try {
      await _skillService.updateSkill(id, skill);
      await fetchSkills();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteSkill(int id) async {
    try {
      await _skillService.deleteSkill(id);
      await fetchSkills();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
