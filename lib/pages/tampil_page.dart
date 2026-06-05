import 'package:flutter/material.dart';

class TampilPage extends StatefulWidget {
  final String pesan;
  const TampilPage({super.key, required this.pesan});

  @override
  State<TampilPage> createState() => _TampilPageState();
}

class _TampilPageState extends State<TampilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pesan yang diterima:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              widget.pesan,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
