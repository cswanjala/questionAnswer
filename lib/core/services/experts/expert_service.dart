import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/constants/api_constants.dart';
import 'package:question_nswer/core/services/api_service.dart';

class ExpertsService {
  final ApiService _apiService = ApiService();

  // Fetch all experts
  Future<List<dynamic>> fetchExperts() async {
    try {
      final response = await _apiService.get(ApiConstants.expertsEndpoint);

      if (response.statusCode == 200) {
        // Fluttertoast.showToast(msg: "Experts fetched successfully");
        return response.data;
      } else {
        // Fluttertoast.showToast(msg: "Failed to fetch experts: ${response.data}");
        return [];
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return [];
    }
  }

  // Add a new expert
  Future<bool> addExpert(String name, String expertise, String bio) async {
    if (name.isEmpty || expertise.isEmpty || bio.isEmpty) {
      Fluttertoast.showToast(msg: "Name, expertise, and bio must be filled");
      return false;
    }

    try {
      final response = await _apiService.post(
        ApiConstants.expertsEndpoint,
        {'name': name, 'expertise': expertise, 'bio': bio},
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Expert added successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to add expert: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }

  // Update an existing expert
  Future<bool> updateExpert(int expertId, String name, String expertise, String bio) async {
    if (name.isEmpty || expertise.isEmpty || bio.isEmpty) {
      Fluttertoast.showToast(msg: "Name, expertise, and bio must be filled");
      return false;
    }

    try {
      final response = await _apiService.put(
        "${ApiConstants.expertsEndpoint}/$expertId",
        {'name': name, 'expertise': expertise, 'bio': bio},
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Expert updated successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to update expert: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }

  // Delete an expert
  Future<bool> deleteExpert(int expertId) async {
    try {
      final response = await _apiService.delete(
        "${ApiConstants.expertsEndpoint}/$expertId",
      );

      if (response.statusCode == 204) {
        Fluttertoast.showToast(msg: "Expert deleted successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to delete expert: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }
}
