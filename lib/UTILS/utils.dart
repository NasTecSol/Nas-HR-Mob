import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Utils {
  static formatPrice(double price) => '\$ ${price.toStringAsFixed(2)}';
  static formatDate(DateTime date) => DateFormat.yMd().format(date);
}


void  showSnackBar(BuildContext context, String content){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(content)));

}