import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill_model.dart';
import '../core/constants/api_constants.dart';

class SkillService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  SkillService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('api_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// Fetch all active skills from the backend database.
  /// Uses a GET request on the skills endpoint.
  Future<List<Skill>> getSkills() async {
    try {
      final response = await _dio.get(ApiConstants.skills);
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((item) => Skill.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load skills: Server returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio Error while fetching skills: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create a new skill in the database.
  /// Sends a POST request with the serialized Skill model.
  Future<Skill> createSkill(Skill skill) async {
    try {
      final response = await _dio.post(
        ApiConstants.skills,
        data: skill.toJson(),
      );
      if (response.statusCode == 201) {
        return Skill.fromJson(response.data);
      } else {
        throw Exception('Failed to create skill: Server returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio Error while creating skill: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update an existing skill in the database by its ID.
  /// Sends a PUT request with the updated serialized Skill model.
  Future<Skill> updateSkill(int id, Skill skill) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.skills}/$id',
        data: {
          ...skill.toJson(),
          '_method': 'PUT', // standard Laravel REST routing fallback
        },
      );
      if (response.statusCode == 200) {
        return Skill.fromJson(response.data);
      } else {
        throw Exception('Failed to update skill: Server returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio Error while updating skill: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Delete a skill from the database by its ID.
  /// Sends a DELETE request.
  Future<void> deleteSkill(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.skills}/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete skill: Server returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio Error while deleting skill: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

