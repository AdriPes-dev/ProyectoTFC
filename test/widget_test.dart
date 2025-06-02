// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fichi/main.dart';

void main() {
  testWidgets('App shows login/register screen on startup', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Busca textos comunes en login o registro
    expect(find.textContaining('Iniciar'), findsWidgets);
    expect(find.textContaining('Registr'), findsWidgets);
  });

  testWidgets('Login screen has email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Busca campos de correo y contraseña
    expect(find.byType(TextField), findsWidgets);
    expect(find.widgetWithText(TextField, 'Correo electrónico'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Contraseña'), findsOneWidget);
  });

  testWidgets('Register button exists on login/registro screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.widgetWithText(ElevatedButton, 'Registrarse'), findsWidgets);
  });

  testWidgets('Main menu has navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(BottomNavigationBar), findsWidgets);
  });

  testWidgets('Widgets principales existen en PaginaPrincipal', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Busca widgets clave por tipo o texto
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(find.byType(Column), findsWidgets);
  });
}
