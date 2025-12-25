import 'package:flutter_projem/features/home/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// API Servisi
final apiClientProvider = Provider((ref) => Dio(BaseOptions(baseUrl: 'https://api.example.com')));

// Veri Çekme İşlemi (FutureProvider)
final userDataProvider = FutureProvider<List<UserModel>>((ref) async {
  final dio = ref.read(apiClientProvider);
  final response = await dio.get('/users');
  
  return (response.data as List)
      .map((user) => UserModel.fromJson(user))
      .toList();
});