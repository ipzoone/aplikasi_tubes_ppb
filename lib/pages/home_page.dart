import 'package:flutter/material.dart';
import 'package:skilltrackit/pages/tampil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Nilai perhitungan counter untuk contoh state local sederhana
  int angka = 0;

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.cyan.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillTrackIt Counter', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.cyan.shade100, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Nilai Hitung',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  angka.toString(),
                  style: TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.remove,
                      color: Colors.redAccent,
                      onPressed: () {
                        setState(() {
                          if (angka > 0) angka--;
                        });
                      },
                    ),
                    const SizedBox(width: 24),
                    _buildActionButton(
                      icon: Icons.add,
                      color: Colors.green.shade600,
                      onPressed: () {
                        setState(() {
                          angka++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TampilPage(pesan: angka.toString()),
            ),
          );
        },
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        label: const Text('Halaman Selanjutnya', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.navigate_next),
      ),
    );
  }

  // Builder widget untuk tombol aksi penambahan atau pengurangan counter
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}

