import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double rate = 0.0;
  double total = 0.0;
  TextEditingController amountController = TextEditingController();
  List<String> currency = [];

  @override
  void initState() {
    super.initState();
    _getCurrency();
  }

  Future<void> _getCurrency() async {
    try {
      var response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
      var data = json.decode(response.body);
      setState(() {
        currency = (data['rates'] as Map<String, dynamic>).keys.toList();
        rate = data['rates'][toCurrency];
      });
    } catch (e) {
      print('Error fetching currency data: $e');
    }
  }

  Future<void> _getRate() async {
    try {
      var response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'));
      var data = json.decode(response.body);
      setState(() {
        rate = data['rates'][toCurrency];
      });
    } catch (e) {
      print('Error fetching rate data: $e');
    }
  }

  Future<void> _swapCurrency() async {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
    });
    await _getRate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Currency Converter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Image(image: AssetImage('assets/images/logo.jpg')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.green.shade800),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade800),
                  ),
                  label: Text('Amount'),
                  labelStyle: TextStyle(color: Colors.green.shade800),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      double amount = double.parse(value);
                      total = amount * rate;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100,
                    child: DropdownButton(
                      onChanged: (newValue) {
                        setState(() {
                          fromCurrency = newValue!;
                          _getRate();
                        });
                      },
                      value: fromCurrency,
                      isExpanded: true,
                      style: TextStyle(color: Colors.green.shade800),
                      items: currency.map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                    onPressed: _swapCurrency,
                    icon: Icon(Icons.swap_horiz_outlined, size: 40, color: Colors.green.shade800),
                  ),
                  SizedBox(
                    width: 100,
                    child: DropdownButton(
                      onChanged: (newValue) {
                        setState(() {
                          toCurrency = newValue!;
                          _getRate();
                        });
                      },
                      value: toCurrency,
                      isExpanded: true,
                      style: TextStyle(color: Colors.green.shade800),
                      items: currency.map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Rate $rate',
              style: TextStyle(color: Colors.green.shade800, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "$toCurrency ${total.toStringAsFixed(3)}",
              style: TextStyle(color: Colors.green.shade800, fontSize: 30),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
