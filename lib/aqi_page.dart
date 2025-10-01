import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AqiPage extends StatefulWidget {
  const AqiPage({super.key});

  @override
  State<AqiPage> createState() => _AqiPageState();
}

class _AqiPageState extends State<AqiPage> {
  String city = "";
  int aqi = 0;
  double temperature = 0;
  String? selectedCity = "nakhon-pathom";

  Future<void> fetchAqi() async {
    final url = Uri.parse(
      "https://api.waqi.info/feed/$selectedCity/?token=55194b3fd8dd5442dbf904deafc7e4bc9ec8051b",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        aqi = data["data"]["aqi"];
        city = data["data"]["city"]["name"];
        temperature = (data["data"]["iaqi"]["t"]["v"] as num).toDouble();
      });
    } else {
      throw Exception("Failed to load data");
    }
  }

  String getAqiScale(int aqi) {
    if (aqi <= 50) {
      return "Good";
    } else if (aqi <= 100) {
      return "Moderate";
    } else if (aqi <= 150) {
      return "Unhealthy for Sensitive Groups";
    } else if (aqi <= 200) {
      return "Unhealthy";
    } else if (aqi <= 300) {
      return "Very Unhealthy";
    } else {
      return "Hazardous";
    }
  }

  Color getAqiColor(int aqi) {
    if (aqi <= 50) {
      return Colors.green;
    } else if (aqi <= 100) {
      return Colors.yellow;
    } else if (aqi <= 150) {
      return Colors.orange;
    } else if (aqi <= 200) {
      return Colors.red;
    } else if (aqi <= 300) {
      return Colors.purple;
    } else {
      return const Color.fromARGB(255, 81, 9, 11);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAqi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AQI")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [getAqiColor(aqi), const Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedCity,
              items: const [
                DropdownMenuItem(
                  value: "chiang-mai",
                  child: Text("Chiang Mai"),
                ),
                DropdownMenuItem(
                  value: "udon-thani",
                  child: Text("Udon Thani"),
                ),
                DropdownMenuItem(value: "bangkok", child: Text("Bangkok")),
                DropdownMenuItem(
                  value: "nakhon-pathom",
                  child: Text("Nakhon Pathom"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCity = value!;
                });
                fetchAqi();
              },
            ),

            const SizedBox(height: 20),

            RichText(
              text: TextSpan(
                children: [
                  const WidgetSpan(
                    child: Icon(Icons.location_on, color: Colors.red, size: 30),
                  ),
                  TextSpan(
                    text: "City: $city",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "$aqi",
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),
            Text(
              "Temperature: $temperature °C",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),
            const Text("Air Quality", style: TextStyle(fontSize: 15)),
            Text(
              getAqiScale(aqi),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: fetchAqi,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 8,
              highlightElevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.refresh, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}
