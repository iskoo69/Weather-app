import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});
  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String city = 'Загрузка...';
  String temp = '--';
  String desc = '--';
  String humidity = '--';
  String wind = '--';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      LocationPermission perm = await Geolocator.requestPermission();
      Position pos = await Geolocator.getCurrentPosition();
      double lat = pos.latitude;
      double lon = pos.longitude;

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&timezone=auto'
      );
      final res = await http.get(url);
      final data = json.decode(res.body);
      final current = data['current'];

      setState(() {
        temp = '${current['temperature_2m']}°C';
        humidity = '${current['relative_humidity_2m']}%';
        wind = '${current['wind_speed_10m']} км/ч';
        desc = getDesc(current['weather_code']);
        city = 'Моё местоположение';
        loading = false;
      });
    } catch (e) {
      setState(() {
        city = 'Ошибка';
        loading = false;
      });
    }
  }

  String getDesc(int code) {
    if (code == 0) return '☀️ Ясно';
    if (code <= 3) return '⛅ Облачно';
    if (code <= 67) return '🌧️ Дождь';
    if (code <= 77) return '❄️ Снег';
    if (code <= 99) return '⛈️ Гроза';
    return '🌤️ Переменная облачность';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: SafeArea(
        child: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(city, style: const TextStyle(color: Colors.white70, fontSize: 20)),
                  const SizedBox(height: 10),
                  Text(temp, style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold)),
                  Text(desc, style: const TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(children: [
                        const Text('💧', style: TextStyle(fontSize: 30)),
                        Text(humidity, style: const TextStyle(color: Colors.white)),
                        const Text('Влажность', style: TextStyle(color: Colors.white70)),
                      ]),
                      const SizedBox(width: 50),
                      Column(children: [
                        const Text('💨', style: TextStyle(fontSize: 30)),
                        Text(wind, style: const TextStyle(color: Colors.white)),
                        const Text('Ветер', style: TextStyle(color: Colors.white70)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () { setState(() { loading = true; }); loadWeather(); },
                    child: const Text('Обновить'),
                  )
                ],
              ),
            ),
      ),
    );
  }
}
