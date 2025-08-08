
import 'package:flutter/rendering.dart';

class Info {
  final String title;
  final String value;
  final Color color;
  final bool isItalic;

  Info(this.title, this.value, this.color, {this.isItalic = false});
}