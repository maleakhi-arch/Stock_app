  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../../stock/pages_stock/home_page.dart';
  import '../../kasir/pages_kasir/cashier_page.dart';

  class MainMenuPage extends StatefulWidget {
    const MainMenuPage({super.key});

    @override
    State<MainMenuPage> createState() => _MainMenuPageState();
  }

  class _MainMenuPageState extends State<MainMenuPage> {
    String storeName = '';

    @override
    void initState() {
      super.initState();
      loadStore();
    }

    Future<void> loadStore() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        storeName = prefs.getString('storeName') ?? '';
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            storeName.isEmpty ? 'Menu Utama' : storeName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: menuButton(
                  title: 'Stock Manager',
                  icon: Icons.inventory,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: menuButton(
                  title: 'Kasir',
                  icon: Icons.point_of_sale,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CashierPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget menuButton({
      required String title,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.blue.shade50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }
  }
