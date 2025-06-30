import 'package:flutter/material.dart';
import 'dart:async';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.day}/${now.month}/${now.year}\n${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6BCB77), // Lighter green
            Color(0xFF3A9D5D), // Darker green
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian atas: logo, judul, update info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                SizedBox(width: 16),
                // Judul dan subjudul
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monitoring Tanah IoT',
                        style: TextStyle(
                          color: Colors.black, // Darker text color
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Dashboard Lingkungan & Sensor',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.85), // Darker subheading
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                // Info update waktu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.update, color: Colors.black54, size: 16), // Darker icon color
                        SizedBox(width: 4),
                        Text(
                          'Update',
                          style: TextStyle(
                            color: Colors.black54, // Darker text color
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Container(
                      constraints: BoxConstraints(maxWidth: 70),
                      child: Text(
                        _currentTime,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.black, // Darker time color
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(
              color: Colors.black.withOpacity(0.18), // Darker divider color
              thickness: 1,
              height: 1,
            ),
            SizedBox(height: 8),
            Text(
              'Selamat datang di sistem monitoring tanah berbasis IoT.\nPantau kondisi lingkungan dan sensor secara real-time.',
              style: TextStyle(
                color: Colors.black.withOpacity(0.92), // Darker welcome text
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}