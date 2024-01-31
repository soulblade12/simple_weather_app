import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 35.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 21.0,
            color: Colors.white,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15.0,
            color: Colors.white,
          ),
        ),
      ),debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weather = 'Loading...';
  String? _lat;
  String? _long;
  String? kota;
  dynamic? suhu;
  String? mainkondisi;

  @override
  void initState() {
    super.initState();
    _getLocationPermission();
  }

  Future<void> _getLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Handle the case where the user denies or forever denies location permission
      print("Location permission denied");
    } else {
      _getData();
    }
  }

  Future<void> _getData() async {
    String apikey = "c36d00a1ade6f97e5f7d9861c3dff92c";
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final response = await http.get(Uri.parse(
        'http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=${apikey}&units=metric'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);


    Map<String, dynamic> list = data;
      _getSuhu(list);
      _getWeather(list);
      _getCurrentCity(list);
      setState(() {
        _long = "${position.longitude}";
        _lat = "${position.latitude}";
      });
    } else {
      setState(() {
        _weather = 'Failed to load weather data.';
      });
    }
  }

  Future<void> _getCurrentCity(list) async {
    setState(() {
      kota = list["name"];
    });
  }

  Future<void> _getWeather(list) async {
    setState(() {
      _weather = list["weather"][0]['description'];
      mainkondisi = list["weather"][0]['main'];
    });
  }

  Future<void> _getSuhu(list) async {
    setState(() {
      suhu = list["main"]["temp"];
    });
  }

  String getWeatherIcon(String? kondisi) {
    if (kondisi == null) return 'assets/sunny.json';
    switch (kondisi.toLowerCase()) {
      case "thunderstorm with light rain":
      case "thunderstorm with rain":
      case "thunderstorm with heavy rain":
      case "light thunderstorm":
      case "thunderstorm":
      case "heavy thunderstorm":
      case "ragged thunderstorm":
      case "thunderstorm with light drizzle":
      case "thunderstorm with drizzle":
      case "thunderstorm with heavy drizzle":
      case "Thunderstorm":
      case "very heavy rain":
      case "extreme rain":
      case "light intensity shower rain":
      case "shower rain":
      case "heavy intensity shower rain":
      case "ragged shower rain":
        return 'assets/thunder.json';
      case "Drizzle":
      case "light rain":
      case "moderate rain":
      case "heavy intensity rain":
      case "light intensity drizzle":
      case "drizzle":
      case "heavy intensity drizzle":
      case "light intensity drizzle rain":
      case "drizzle rain":
      case "heavy intensity drizzle rain":
      case "shower rain and drizzle":
      case "heavy shower rain and drizzle":
      case "shower drizzle":
        return 'assets/rain.json';
      case 'Clear':
        return 'assets/sunny.json';
      case 'Clouds':
      case"overcast clouds":
      case'broken clouds':
      case 'scattered clouds':
      case 'few clouds':
        return 'assets/cloudy.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    String Googleapikey =
        "AIzaSyAVsku3_R5bbF-Vc9dt7fnZgu_iR1BYLUM";
    String mapUrl =
        'https://maps.googleapis.com/maps/api/staticmap?center=$_lat,$_long=&zoom=18&size=900x900&maptype=roadmap&markers=color:red%7Clabel:A%7C$_lat,$_long&key=$Googleapikey';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10,50,10,30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 48.0,
                  color: Colors.white,
                ),
                SizedBox(height: 5),
                Text('$_weather',
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 5),
                Text(
                  '$kota',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Expanded(
                  child: Container(
                    child: Lottie.asset(getWeatherIcon(_weather)),
                    height: 400,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Latitude: $_lat",
                        style: Theme.of(context).textTheme.titleSmall),
                    SizedBox(width: 16),
                    Text("Longitude: $_long",
                        style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
                SizedBox(height: 10),
                Text("$suhu °C",
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 10),
                Image.network(
                  mapUrl,
                  width: 200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
