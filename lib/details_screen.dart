
import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final String details;
  final String objectName;

  const DetailsScreen(
      {Key? key, required this.details, required this.objectName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Object Name: $objectName',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              'Details: $details',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
          ]
        ),
      ),
    );
  }
}
