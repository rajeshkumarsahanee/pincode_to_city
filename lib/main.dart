import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pincode_to_city/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pincode to City',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Pincode to City'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Location> locations = [];
  String status = '';

  _getLocations(pincode) {
    setState(() {
      status = 'Please wait...';
    });
    final JsonDecoder _decoder = const JsonDecoder();
    http
        .get(Uri.parse("http://www.postalpincode.in/api/pincode/$pincode"))
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400) {
        throw Exception("Error while fetching data");
      }

      setState(() {
        var json = _decoder.convert(res);
        var tmp = json['PostOffice'] as List;
        locations =
            tmp.map<Location>((json) => Location.fromJson(json)).toList();
        status = 'All Locations at Pincode ' + pincode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              key: GlobalKey<FormState>(),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                labelText: "Pincode",
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              onFieldSubmitted: (val) => _getLocations(val),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(status,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: locations.length,
                itemBuilder: (BuildContext context, int index) {
                  final Location location = locations.elementAt(index);

                  return Card(
                    child: ListTile(
                      title: Text(location.name),
                      subtitle: Text('District: ' +
                          location.district +
                          '\nRegion: ' +
                          location.region +
                          '\nState: ' +
                          location.state),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
