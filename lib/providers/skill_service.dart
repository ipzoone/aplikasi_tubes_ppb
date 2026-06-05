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

  Future<List<Skill>> getSkills() async {
    try {
      final response = await _dio.get(ApiConstants.skills);
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((item) => Skill.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load skills');
      }
    } on DioException catch (e) {
      throw Exception('Dio Error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Skill> createSkill(Skill skill) async {
    try {
      final response = await _dio.post(
        ApiConstants.skills,
        data: skill.toJson(),
      );
      if (response.statusCode == 201) {
        return Skill.fromJson(response.data);
      } else {
        throw Exception('Failed to create skill');
      }
    } on DioException catch (e) {
      throw Exception('Dio Error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Skill> updateSkill(int id, Skill skill) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.skills}/$id',
        data: skill.toJson(),
      );
      if (response.statusCode == 200) {
        return Skill.fromJson(response.data);
      } else {
        throw Exception('Failed to update skill');
      }
    } on DioException catch (e) {
      throw Exception('Dio Error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteSkill(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.skills}/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete skill');
      }
    } on DioException catch (e) {
      throw Exception('Dio Error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
