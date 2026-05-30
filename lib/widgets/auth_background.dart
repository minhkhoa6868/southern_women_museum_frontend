import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/congbaotang.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: theme.scaffoldBackgroundColor);
            },
          ),
        ),
        Positioned.fill(
          child: Container(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}