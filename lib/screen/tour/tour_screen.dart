import 'package:flutter/material.dart';

class TourScreen extends StatelessWidget {
  const TourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.explore_rounded, color: Color(0xFFD1BCA7), size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tour Overview',
                  style: TextStyle(
                    color: Color(0xFFF2EAE2),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Follow curated museum routes by time and theme.\nStart a guided path and track your progress.',
            style: TextStyle(
              color: Color(0xCCEFE3D7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
