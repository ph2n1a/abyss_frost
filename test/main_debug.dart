import 'package:flutter/material.dart';
import 'widgets/chart_debug.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GestureDiagnosticsWidget(),
  ));
}