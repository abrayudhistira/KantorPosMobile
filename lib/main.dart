import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kantorpos/barang/barangPage.dart';
import 'package:kantorpos/login/loginPage.dart';
import 'package:kantorpos/login/registerPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kantor Pos',
      initialRoute: 'login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyLogin(),
      routes: {
      'register': (context) => MyRegister(),
      'login': (context) => MyLogin(),
    },
    );
  }
}