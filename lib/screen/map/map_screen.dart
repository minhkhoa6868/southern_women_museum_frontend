import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

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
              Icon(Icons.map_rounded, color: Color(0xFFD1BCA7), size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Map Highlights',
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
            'Explore locations and rooms with interactive markers.\nTap points on the map to open exhibit details.',
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
