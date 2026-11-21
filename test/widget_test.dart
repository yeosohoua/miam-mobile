import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miam/core/app_settings.dart';

void main() {
  test('le theme par defaut suit le telephone', () {
    expect(AppSettings.themeMode.value, ThemeMode.system);
  });

  test('la langue par defaut suit le telephone', () {
    expect(AppSettings.locale.value, isNull);
  });
}