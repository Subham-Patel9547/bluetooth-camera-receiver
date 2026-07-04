import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String status;
  final Color color;
  final IconData icon;

  const StatusCard({
    super.key,
    required this.title,
    required this.status,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(status),
      ),
    );
  }
}