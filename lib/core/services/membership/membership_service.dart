

import 'package:question_nswer/core/constants/api_constants.dart';
import 'package:question_nswer/core/services/api_service.dart';

class MembershipService {
  final ApiService _apiService = ApiService();

  Future<Map<String,dynamic>> getMembership() async {
    try {
      final response = await _apiService.get(ApiConstants.membershipEndpoint);

      if(response.statusCode == 200){
        final membershipData = response.data;

        return membershipData;
      } else {
        return {};
      }
    }
    catch(e) {
      throw Exception("Failed to load Mmembership plan data");

    }
  }

  Future<bool> addMembership(Map<String,dynamic> data) async{
    if(data.isEmpty){
      return false;
    }

    try{
      final response = await _apiService.post(ApiConstants.membershipEndpoint, data);

      if(response.statusCode == 201) {
        return true;
      } else {
        return false;
      }

    }catch(e){
      throw Exception("ERROR ADDING MEMBERSHIP PLAN $e");
    }
  }
}