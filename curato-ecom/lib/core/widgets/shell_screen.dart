import 'package:flutter/material.dart';
import 'package:curato_user/core/widgets/curato_layout.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;
  final String activeTitle;
  const ShellScreen({super.key, required this.child, this.activeTitle = 'HOME'});

  @override
  Widget build(BuildContext context) {
    return CuratoLayout(activeTitle: activeTitle, child: child);
  }
}

