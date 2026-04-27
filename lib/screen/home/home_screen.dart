import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      leadingIcon: Icons.star_rounded,
      title: 'Key Features',
      description:
          'Welcome to the Southern Women Museum app. Browse highlights,\nplan tours, and discover stories through each section.',
    );
  }
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({
    required this.leadingIcon,
    required this.title,
    required this.description,
  });

  final IconData leadingIcon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  leadingIcon,
                  color: theme.colorScheme.secondary,
                  size: 30,
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.displaySmall,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              description,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}