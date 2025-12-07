import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'dart:convert';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  _PromoPageState createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  List promos = [];
  bool loading = true;

  getPromos() async {
    final res = await ApiService.get("promos");
    setState(() {
      promos = jsonDecode(res.body)['data'];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getPromos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Promo BSM Clinic")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: promos.length,
              itemBuilder: (_, i) {
                return Card(
                  child: ListTile(
                    title: Text(promos[i]['title']),
                    subtitle: Text(promos[i]['description']),
                  ),
                );
              },
            ),
    );
  }
}
