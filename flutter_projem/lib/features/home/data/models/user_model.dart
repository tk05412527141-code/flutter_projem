import 'package:json_annotation/json_annotation.dart';

// 1. Buradaki isim dosya adınla birebir aynı olmalı
part 'user_model.g.dart'; 

@JsonSerializable()
class UserModel {
  final int id;
  final String name;

  UserModel({required this.id, required this.name});

  // 2. Buradaki metot isimleri sınıf isminle uyumlu olmalı
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}