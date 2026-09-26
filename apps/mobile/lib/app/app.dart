import 'package:flutter/material.dart';

class VardigoApp extends StatelessWidget {
  const VardigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Vardigo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('Vardigo'))),
    );
  }
}
