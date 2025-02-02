

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:question_nswer/core/services/membership/membership_service.dart';

class MembershipProvider with ChangeNotifier{
  final MembershipService _membershipService = MembershipService();

  Map<String,dynamic> _membership = {};
  bool _isLoading = false;

  Map<String,dynamic> get membership =>_membership;

  Future<void> fetchMembership() async {
    _isLoading = true;
    notifyListeners();

    try {
      final responseData = await _membershipService.getMembership();
      _membership = responseData;

    }catch(e){
      Fluttertoast.showToast(msg: "Unable to fetch Membership");
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }

  }

  Future<bool> addMembership(Map<String,dynamic> data) async{
    _isLoading = true;
    notifyListeners();

    try{
      final response = await _membershipService.addMembership(data);

      if(response){
        Fluttertoast.showToast(msg: "Membership added successfully!");
        return true;
      }else {
        Fluttertoast.showToast(msg: "Unable to add  membership!");
        return false;
      }
    }catch(e){
      return false;
    }

  }
}