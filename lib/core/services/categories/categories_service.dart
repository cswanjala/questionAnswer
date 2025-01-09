import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/constants/api_constants.dart';
import 'package:question_nswer/core/services/api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  // Fetch all categories
  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await _apiService.get(ApiConstants.categoriesEndpoint);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Categories fetched successfully");
        return response.data;
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch categories: ${response.data}");
        return [];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return [];
    }
  }

  // Add a new category
  Future<bool> addCategory(String name, String description) async {
    if (name.isEmpty || description.isEmpty) {
      Fluttertoast.showToast(msg: "Name and description must be filled");
      return false;
    }

    try {
      final response = await _apiService.post(
        ApiConstants.categoriesEndpoint,
        {'name': name, 'description': description},
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Category added successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to add category: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }

  // Update an existing category
  Future<bool> updateCategory(int categoryId, String name, String description) async {
    if (name.isEmpty || description.isEmpty) {
      Fluttertoast.showToast(msg: "Name and description must be filled");
      return false;
    }

    try {
      final response = await _apiService.put(
        "${ApiConstants.categoriesEndpoint}/$categoryId",
        {'name': name, 'description': description},
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Category updated successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to update category: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(int categoryId) async {
    try {
      final response = await _apiService.delete(
        "${ApiConstants.categoriesEndpoint}/$categoryId",
      );

      if (response.statusCode == 204) {
        Fluttertoast.showToast(msg: "Category deleted successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to delete category: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      log(e.toString());
      return false;
    }
  }
}
