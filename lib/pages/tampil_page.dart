import 'package:flutter/material.dart';

class TampilPage extends StatefulWidget {
  // Pesan teks yang dioper dari halaman sebelumnya untuk ditampilkan di layar
  final String pesan;
  const TampilPage({super.key, required this.pesan});

  @override
  State<TampilPage> createState() => _TampilPageState();
}

class _TampilPageState extends State<TampilPage> {
  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.cyan.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_rounded, size: 80, color: themeColor.withOpacity(0.8)),
              const SizedBox(height: 24),
              const Text(
                'Pesan yang diterima dari Notifikasi:',
                style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  widget.pesan,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

