import 'package:flutter/material.dart';
import '../providers/skill_service.dart';
import '../models/skill_model.dart';

class SkillProvider with ChangeNotifier {
  final SkillService _skillService = SkillService();
  
  // State variables for managing active list, loading status and api errors
  List<Skill> _skills = [];
  bool _isLoading = false;
  String? _error;

  // Getters to access private state variables
  List<Skill> get skills => _skills;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches skills asynchronously from the service, handles state,
  /// and notifies listening widgets of changes.
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

  /// Adds a new skill to the database, then refreshes the global list state.
  Future<Map<String, dynamic>> addSkill(Skill skill) async {
    try {
      await _skillService.createSkill(skill);
      await fetchSkills();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Updates an existing skill and triggers a refresh of the list state.
  Future<Map<String, dynamic>> updateSkill(int id, Skill skill) async {
    try {
      await _skillService.updateSkill(id, skill);
      await fetchSkills();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Deletes a skill by its ID, and refreshes the local skills list.
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

