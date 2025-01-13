import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/services/api_service.dart';

class CategoriesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  // Fetch all categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/categories');
      if (response.statusCode == 200) {
        _categories = List<Map<String, dynamic>>.from(response.data);
        notifyListeners();
        Fluttertoast.showToast(msg: "Categories fetched successfully!");
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch categories: ${response.statusMessage}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching categories: ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new category
  Future<bool> addCategory(String name, String description) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/categories', {
        'name': name,
        'description': description,
      });

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Category added successfully!");
        await fetchCategories(); // Refresh the categories list
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to add category: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error adding category: ${e.toString()}");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing category
  Future<bool> updateCategory(int categoryId, String name, String description) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.put('/categories/$categoryId', {
        'name': name,
        'description': description,
      });

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Category updated successfully!");
        await fetchCategories(); // Refresh the categories list
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to update category: ${response.data}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating category: ${e.toString()}");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a category
  Future<bool> deleteCategory(int categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.delete('/categories/$categoryId');

      if (response.statusCode == 204) {
        Fluttertoast.showToast(msg: "Category deleted successfully!");
        await fetchCategories(); // Refresh the categories list
        return true;
      } else {
        Fluttertoast.showToast(msg: "Failed to delete category: ${response.statusMessage}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting category: ${e.toString()}");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
