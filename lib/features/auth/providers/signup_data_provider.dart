import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpData {
  final String? name;
  final String? email;
  final String? password;

  SignUpData({this.name, this.email, this.password});

  SignUpData copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return SignUpData(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

final signUpDataProvider = StateProvider<SignUpData>((ref) => SignUpData());
