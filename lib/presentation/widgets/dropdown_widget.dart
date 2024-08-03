import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/adding_provider.dart';
import 'package:movietix_distributor/business_logis/provider/editing_provider.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';

Widget dropdownwidget({
  required MovieProvider movieProvider,
  required String names,
  required List<String> value,
  required String type,
  required Function(String) set,
}) {
  String? selectedValue = type == 'languages' 
      ? movieProvider.selectedLanguage 
      : movieProvider.selectedCategory;

  return DropdownButtonFormField<String>(
    value: selectedValue,
    items: value.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item, style: TextStyle(color: MyColor().white)),
      );
    }).toList(),
    onChanged: (String? newValue) {
      if (newValue != null) {
        set(newValue);
      }
    },
    decoration: InputDecoration(
      filled: true,
      fillColor: MyColor().darkblue,
      hintText: names,
      hintStyle: TextStyle(color: MyColor().white.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MyColor().white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MyColor().white),
      ),
    ),
    dropdownColor: MyColor().darkblue,
    style: TextStyle(color: MyColor().white),
    icon: Icon(Icons.arrow_drop_down, color: MyColor().white),
  );
}





Widget dropdownwidgetedit({
  required MovieEditProvider movieEdintProvider,
  required String names,
  required List<String> value,
  required String type,
  required Function(String) set,
}) {
  String? selectedValue = type == 'languages' 
      ? movieEdintProvider.selectedLanguage 
      : movieEdintProvider.selectedCategory;

  return DropdownButtonFormField<String>(
    value: selectedValue,
    items: value.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item, style: TextStyle(color: MyColor().white)),
      );
    }).toList(),
    onChanged: (String? newValue) {
      if (newValue != null) {
        set(newValue);
      }
    },
    decoration: InputDecoration(
      filled: true,
      fillColor: MyColor().darkblue,
      hintText: names,
      hintStyle: TextStyle(color: MyColor().white.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MyColor().white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MyColor().white),
      ),
    ),
    dropdownColor: MyColor().darkblue,
    style: TextStyle(color: MyColor().white),
    icon: Icon(Icons.arrow_drop_down, color: MyColor().white),
  );
}