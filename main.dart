import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CurrencyConverter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  Dio dio = Dio();
  String realToDollar = '';
  String realToEuro = '';
  String realToBitcoin = '';
  TextEditingController fromValueController = TextEditingController();
  String fromCurrency = 'Real';
  TextEditingController toValueController = TextEditingController();
  String toCurrency = 'Dólar';

  Future<void> fetchCurrencyData() async {
    try {
      final responseDollar =
          await dio.get('https://economia.awesomeapi.com.br/json/last/USD-BRL');
      final responseEuro =
          await dio.get('https://economia.awesomeapi.com.br/json/last/EUR-BRL');
      final responseBitcoin =
          await dio.get('https://economia.awesomeapi.com.br/json/last/BTC-BRL');

      if (responseDollar.statusCode == 200 &&
          responseEuro.statusCode == 200 &&
          responseBitcoin.statusCode == 200) {
        final dataDollar = responseDollar.data;
        final dataEuro = responseEuro.data;
        final dataBitcoin = responseBitcoin.data;

        setState(() {
          realToDollar = dataDollar['USDBRL']['ask'];
          realToEuro = dataEuro['EURBRL']['ask'];
          realToBitcoin = dataBitcoin['BTCBRL']['ask'];
        });
      }
    } catch (e) {
      print('Erro na solicitação da API: $e');
    }
  }

  void convertCurrency() {
    if (fromValueController.text.isNotEmpty) {
      double inputValue = double.tryParse(fromValueController.text) ?? 0.0;
      double? fromRate;
      double? toRate;

      if (fromCurrency == 'Real') {
        fromRate = 1.0;
      } else if (fromCurrency == 'Dólar') {
        fromRate = double.tryParse(realToDollar);
      } else if (fromCurrency == 'Euro') {
        fromRate = double.tryParse(realToEuro);
      } else if (fromCurrency == 'Bitcoin') {
        fromRate = double.tryParse(realToBitcoin);
      }

      if (toCurrency == 'Real') {
        toRate = 1.0;
      } else if (toCurrency == 'Dólar') {
        toRate = double.tryParse(realToDollar);
      } else if (toCurrency == 'Euro') {
        toRate = double.tryParse(realToEuro);
      } else if (toCurrency == 'Bitcoin') {
        toRate = double.tryParse(realToBitcoin);
      }

      if (fromRate != null && toRate != null) {
        double convertedValueResult = (inputValue * fromRate) / toRate;
        setState(() {
          toValueController.text = convertedValueResult.toStringAsFixed(2);
        });
      } else {
        print('Erro ao obter as taxas de conversão.');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCurrencyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Conversor de Moedas API'),
      ),
      body: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: fromValueController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: fromCurrency,
                    onChanged: (value) {
                      setState(() {
                        fromCurrency = value!;
                      });
                    },
                    items: <String>['Real', 'Dólar', 'Euro', 'Bitcoin']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.blue),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: convertCurrency,
                child: Text('Converter'),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: toValueController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Resultado',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: toCurrency,
                    onChanged: (value) {
                      setState(() {
                        toCurrency = value!;
                      });
                    },
                    items: <String>['Real', 'Dólar', 'Euro', 'Bitcoin']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.blue),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
