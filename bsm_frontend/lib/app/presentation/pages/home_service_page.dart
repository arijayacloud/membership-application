import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'dart:convert';

class HomeServicePage extends StatefulWidget {
  const HomeServicePage({super.key});

  @override
  _HomeServicePageState createState() => _HomeServicePageState();
}

class _HomeServicePageState extends State<HomeServicePage> {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  bool loading = false;

  Future registerHomeService() async {
    setState(() => loading = true);

    final res = await ApiService.post("home-services/register", {
      "name": nameCtrl.text,
      "address": addressCtrl.text,
      "phone": phoneCtrl.text
    });

    setState(() => loading = false);

    final data = jsonDecode(res.body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Service")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nama")),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Alamat")),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "No HP")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: registerHomeService,
              child: loading ? const CircularProgressIndicator() : const Text("Daftar Home Service"),
            ),
          ],
        ),
      ),
    );
  }
}
