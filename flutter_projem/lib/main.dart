import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Gelecekte buraya: await Firebase.initializeApp(); veya LocalDb.init();
  runApp(const ProviderScope(child: App()));
}