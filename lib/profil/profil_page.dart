import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  String storeName = '';

  @override
  void initState() {
    super.initState();
    loadStore();
  }

  Future<void> editStoreName() async {
    final controller = TextEditingController(text: storeName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ubah Nama Toko"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Masukkan nama toko"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('storeName', controller.text);

              setState(() {
                storeName = controller.text;
              });

              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> loadStore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      storeName = prefs.getString('storeName') ?? 'Belum diatur';
    });
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pop(context); // kembali ke login / menu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(title: const Text("Profil"), centerTitle: true),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user?.photoURL ?? ""),
                    backgroundColor: Colors.white,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    user?.displayName ?? "Nama tidak tersedia",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.store),
                  title: const Text("Nama Toko"),
                  subtitle: Text(storeName),
                  trailing: const Icon(Icons.edit),
                  onTap: editStoreName,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                onPressed: () => logout(context),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
