import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'dart:convert';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Map info = {};
  bool loading = true;

  getInfo() async {
    final res = await ApiService.get("infos");
    setState(() {
      info = jsonDecode(res.body)['data'];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Informasi Klinik")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Alamat: ${info['address']}"),
                  Text("Jam Operasional: ${info['operational_hours']}"),
                  Text("Kontak: ${info['phone']}"),
                ],
              ),
            ),
    );
  }
}
