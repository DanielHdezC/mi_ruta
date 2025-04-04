import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(const MiRutaApp());

class MiRutaApp extends StatelessWidget {
  const MiRutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mi Ruta Morelia',
      debugShowCheckedModeBanner: false,
      home: MapaPage(),
    );
  }
}

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse('ws://44.243.38.48:3000'));

  List<LatLng> posiciones = [];

  @override
  void initState() {
    super.initState();
    channel.stream.listen((data) {
      try {
        final List<dynamic> jsonData = jsonDecode(data);
        final nuevasPosiciones = jsonData.map((pos) => LatLng(
              pos['latitude'],
              pos['longitude'],
            )).toList();

        setState(() {
          posiciones = nuevasPosiciones;
        });

        print('📡 Datos recibidos: ${jsonData.length} posiciones');
      } catch (e) {
        print('❌ Error al procesar datos WebSocket: $e');
      }
    }, onError: (error) {
      print('❌ WebSocket error: $error');
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const LatLng centroMorelia = LatLng(19.705, -101.194);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Ruta Morelia',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: centroMorelia,
          zoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.mi_ruta_morelia',
          ),
          MarkerLayer(
            markers: posiciones
                .map(
                  (pos) => Marker(
                    point: pos,
                    width: 36,
                    height: 36,
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.black87,
                      size: 28,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

