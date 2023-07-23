import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';

import 'crypto_currency.dart';
import 'rate_limiter.dart';

/// this is the screen that displays detailed information about a specific cryptocurrency
class CryptoDetailScreen extends StatefulWidget {
  final CryptoCurrency currency;
  final int
      duration; // represents the number of days of historical data to fetch

  const CryptoDetailScreen({
    super.key,
    required this.currency,
    required this.duration,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CryptoDetailScreenState createState() => _CryptoDetailScreenState();
}

/// CryptoDetailScreen widget state class
class _CryptoDetailScreenState extends State<CryptoDetailScreen> {
  List<FlSpot> historicalData = [];
  int selectedDurationIndex = 0;

  final List<Map<String, dynamic>> chartDurations = [
    {'label': '12 Months', 'days': 365},
    {'label': '6 Months', 'days': 180},
    {'label': '1 Month', 'days': 30},
    {'label': '24 Hours', 'days': 1},
  ];

  /// changes the duration of data to fetch
  void changeChartDuration(int durationIndex) {
    setState(() {
      selectedDurationIndex = durationIndex;
    });

    final int duration = chartDurations[selectedDurationIndex]['days'];
    fetchHistoricalData(duration);
  }

  @override
  void initState() {
    super.initState();
    fetchHistoricalData(widget.duration);
  }

  /// fetches data for the selected cryptocurrency from the Coingecko API in the specified duration
  Future<void> fetchHistoricalData(int duration) async {
    final String apiUrl =
        "https://api.coingecko.com/api/v3/coins/${widget.currency.id}/market_chart?vs_currency=usd&days=$duration&interval=daily&precision=0";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['prices'];
        setState(() {
          historicalData = responseData
              .map((data) => FlSpot(
                    responseData.indexOf(data).toDouble(),
                    data[1].toDouble(),
                  ))
              .toList();
        });
      } else {
        // ignore: use_build_context_synchronously
        showRateLimitErrorDialog(context);
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currency.name),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: widget.currency.iconUrl,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.currency.name,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Current price: ${widget.currency.price.toStringAsFixed(2)} \$',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: historicalData,
                        isCurved: false,
                        color: Colors.blue,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    titlesData: const FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              reservedSize: 50,
                              showTitles: true,
                              interval: 100000)),
                      rightTitles: AxisTitles(
                          sideTitles:
                              SideTitles(reservedSize: 44, showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles:
                              SideTitles(reservedSize: 44, showTitles: false)),
                      topTitles: AxisTitles(
                          sideTitles:
                              SideTitles(reservedSize: 44, showTitles: false)),
                    ),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < chartDurations.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: ElevatedButton(
                          onPressed: () => changeChartDuration(i),
                          style: ElevatedButton.styleFrom(
                            primary:
                                i == selectedDurationIndex ? Colors.blue : null,
                          ),
                          child: Text(chartDurations[i]['label']),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
