import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytm/paytm.dart';

import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;
  TextEditingController controller = TextEditingController();

  String payment_response = null;

  String website = "DEFAULT";
  bool testing = false;

  String mid = "Enter your mid";
  String mkey = "Enter your mkey";
  // ignore: non_constant_identifier_names
  Map<String, dynamic> _response = null;
  void generateTxnToken(
    String pay,
  ) async {
    setState(() {
      loading = true;
    });
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl = (testing
            ? 'https://securegw-stage.paytm.in'
            : 'https://securegw.paytm.in') +
        '/theia/paytmCallback?ORDER_ID=' +
        orderId;

    var url = Uri.parse(
        'https://desolate-anchorage-29312.herokuapp.com/generateTxnToken');

    var body = json.encode({
      "mid": mid,
      "key_secret": mkey,
      "website": website,
      "orderId": orderId,
      "amount": pay,
      "callbackUrl": callBackUrl,
      "custId": "122",
      // "mode": "1",
      "testing": testing ? 0 : 1,
    });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {'Content-type': "application/json"},
      );

      String txnToken = response.body;

      payment_response = txnToken;

      var paytmResponse =
          Paytm.payWithPaytm(mid, orderId, txnToken, pay, callBackUrl, testing);

      paytmResponse.then((value) {
        print(value);
        if (value['response']['STATUS'] == 'TXN_SUCCESS') {
          setState(() {
            loading = false;

            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'your Payment was successfully received!',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Okay',
                        ),
                      ),
                    ],
                  );
                });
          });
        } else {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'OOps! something went wrong',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Okay',
                      ),
                    ),
                  ],
                );
              });
        }
      });
    } catch (e) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Something went wrong'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Okay',
                    )),
              ],
            );
          });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.pink[900],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9]'),
                  ),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.025,
                      horizontal: MediaQuery.of(context).size.width * 0.05),
                  focusColor: Color(0xff0962ff),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.grey[350],
                    ),
                  ),
                  hintText: 'Enter a Amount',
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.pink[800],
                  ),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
                ),
                child: Text(
                  "Proceed Payment",
                ),
                onPressed: () {
                  generateTxnToken(controller.text);
                  controller.clear();
                },
              ),
            ),
            loading ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) {
      //       return Payment();
      //     }));
      //   },
      //   tooltip: 'Increment',
      //   child: Icon(
      //     Icons.payment,
      //   ),
      // ),
    );
  }
}
