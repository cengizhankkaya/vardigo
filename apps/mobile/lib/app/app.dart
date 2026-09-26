import 'package:flutter/material.dart';

import '../preview/design_preview_screen.dart';

class VardigoApp extends StatelessWidget {
  const VardigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Vardigo',
      debugShowCheckedModeBanner: false,
      home: DesignPreviewScreen(),
    );
  }
}
