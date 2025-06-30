import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEFEFEF), // Lighter background color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, color: Colors.black54, size: 16), // Darker icon color
          SizedBox(width: 8),
          Text(
            'Real-time monitoring aktif',
            style: TextStyle(color: Colors.black54, fontSize: 12), // Darker text color
          ),
        ],
      ),
    );
  }
}