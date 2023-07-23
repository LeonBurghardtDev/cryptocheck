import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import 'crypto_currency.dart';
import 'crypto_detail_screen.dart';
import 'rate_limiter.dart';

// entry point
// ignore: non_constant_identifier_names
void main() {
  runApp(const CryptoApp());
}

/// main application class
class CryptoApp extends StatefulWidget {
  const CryptoApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CryptoAppState createState() => _CryptoAppState();
}

/// main application state class
class _CryptoAppState extends State<CryptoApp> {
  List<CryptoCurrency> cryptoList = [];
  bool isSearchActive = false;
  List<CryptoCurrency> filteredList = [];
  bool isAscending = true;

  /// call to fetch data from API
  @override
  void initState() {
    super.initState();
    fetchCryptoData();
  }

  /// fetches cryptocurrency data from the Coingecko API
  Future<void> fetchCryptoData() async {
    const String apiUrl =
        "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          cryptoList = responseData
              .map((data) => CryptoCurrency.fromJson(data))
              .toList();
        });
      } else {
        // ignore: use_build_context_synchronously
        showRateLimitErrorDialog(context);
        throw Exception("Failed to load data");
      }
      // ignore: empty_catches
    } catch (e) {
      throw Exception(e);
    }
    toggleSort();
  }

  /// searches the cryptocurrency list based on the users query
  void search(String query) {
    filteredList = cryptoList
        .where((currency) =>
            currency.name.toLowerCase().contains(query.toLowerCase()) ||
            currency.symbol.toLowerCase().contains(query.toLowerCase()))
        .toList();

    filteredList.sort((a, b) {
      if (isAscending) {
        return a.price.compareTo(b.price);
      } else {
        return b.price.compareTo(a.price);
      }
    });
  }

  /// toggles the sorting order of the cryptocurrency list
  void toggleSort() {
    setState(() {
      isAscending = !isAscending;
      if (isSearchActive) {
        filteredList.sort((a, b) {
          if (isAscending) {
            return a.price.compareTo(b.price);
          } else {
            return b.price.compareTo(a.price);
          }
        });
      } else {
        cryptoList.sort((a, b) {
          if (isAscending) {
            return a.price.compareTo(b.price);
          } else {
            return b.price.compareTo(a.price);
          }
        });
      }
    });
  }

  /// builds the main application widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CryptoCheck'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  isSearchActive = !isSearchActive;
                  filteredList.clear();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {
                toggleSort();
              },
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0, // Remove elevation shadow
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount:
                    isSearchActive ? filteredList.length : cryptoList.length,
                itemBuilder: (context, index) {
                  final currency =
                      isSearchActive ? filteredList[index] : cryptoList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CryptoDetailScreen(
                            currency: currency,
                            duration: 365, // default duration is 365 days
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: currency.iconUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        height: 48,
                        width: 48,
                      ),
                      title: Text(currency.name),
                      subtitle: Text(currency.symbol),
                      trailing: Text('${currency.price.toStringAsFixed(2)} \$'),
                    ),
                  );
                },
              ),
            ),
            if (isSearchActive) _buildSearchField(),
          ],
        ),
      ),
    );
  }

  /// builds the search field widget
  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[300],
      child: TextField(
        autofocus: true,
        onChanged: (query) {
          setState(() {
            search(query);
          });
        },
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
        ),
      ),
    );
  }
}
