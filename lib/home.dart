import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytm/paytm.dart';

import 'package:http/http.dart' as http;
import 'package:paytm_project/getData.dart';
import 'package:upi_pay/upi_pay.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;
  bool _isUpiEditable = true;
  String _upiAddrError;
  TextEditingController controller = TextEditingController();
  TextEditingController upicontroller = TextEditingController();
  Future<List<ApplicationMeta>> _appsFuture;
  @override
  void initState() {
    _appsFuture = UpiPay.getInstalledUpiApplications();
    super.initState();
  }

  String _validateUpiAddress(String value) {
    if (value.isEmpty) {
      return 'UPI Address is required.';
    }

    if (!UpiPay.checkIfUpiAddressIsValid(value)) {
      return 'UPI Address is invalid.';
    }

    return null;
  }

  Future<void> _onTap(ApplicationMeta app) async {
    final err = _validateUpiAddress(upicontroller.text);
    if (err != null) {
      setState(() {
        _upiAddrError = err;
      });
      return;
    }
    setState(() {
      _upiAddrError = null;
    });

    try {
      final transactionRef = Random.secure().nextInt(1 << 32).toString();
      print("Starting transaction with id $transactionRef");

      await UpiPay.initiateTransaction(
        app: app.upiApplication,
        amount: controller.text + ".00",
        receiverName: "Ashish",
        receiverUpiAddress: upicontroller.text,
        transactionRef: transactionRef,
      ).then((value) {
        if (value.status == UpiTransactionStatus.success) {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Payment was successfully added!',
                    style: TextStyle(color: Colors.green),
                  ),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Okay',
                      ),
                    )
                  ],
                );
              });
        } else {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Oops! Something went wrong.',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Okay',
                      ),
                    )
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
              title: Text(
                'Oops! Something went wrong.',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Okay',
                  ),
                )
              ],
            );
          });
    }
  }

  // String payment_response = null;

  // String website = "DEFAULT";
  // bool testing = false;

  // String mid = "UpNKDA70368281575842";
  // String mkey = "CONALvaAM4vMejWB";
  // // ignore: non_constant_identifier_names
  // Map<String, dynamic> _response = null;
  // void generateTxnToken(
  //   String pay,
  // ) async {
  //   setState(() {
  //     loading = true;
  //   });
  //   String orderId = DateTime.now().millisecondsSinceEpoch.toString();

  //   String callBackUrl = (testing
  //           ? 'https://securegw-stage.paytm.in'
  //           : 'https://securegw.paytm.in') +
  //       '/theia/paytmCallback?ORDER_ID=' +
  //       orderId;

  //   var url = Uri.parse(
  //       'https://desolate-anchorage-29312.herokuapp.com/generateTxnToken');

  //   var body = json.encode({
  //     "mid": mid,
  //     "key_secret": mkey,
  //     "website": website,
  //     "orderId": orderId,
  //     "amount": pay,
  //     "callbackUrl": callBackUrl,
  //     "custId": "122",
  //     // "mode": "1",
  //     "testing": testing ? 0 : 1,
  //   });

  //   try {
  //     final response = await http.post(
  //       url,
  //       body: body,
  //       headers: {'Content-type': "application/json"},
  //     );

  //     String txnToken = response.body;

  //     payment_response = txnToken;

  //     var paytmResponse =
  //         Paytm.payWithPaytm(mid, orderId, txnToken, pay, callBackUrl, testing);

  //     paytmResponse.then((value) {
  //       print(value);
  //       if (value['response']['STATUS'] == 'TXN_SUCCESS') {
  //         setState(() {
  //           loading = false;

  //           return showDialog(
  //               context: context,
  //               builder: (BuildContext context) {
  //                 return AlertDialog(
  //                   title: Text(
  //                     'your Payment was successfully received!',
  //                     style: TextStyle(
  //                       color: Colors.green,
  //                     ),
  //                   ),
  //                   actions: [
  //                     TextButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: Text(
  //                         'Okay',
  //                       ),
  //                     ),
  //                   ],
  //                 );
  //               });
  //         });
  //       } else {
  //         return showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 title: Text(
  //                   'OOps! something went wrong',
  //                   style: TextStyle(
  //                     color: Colors.red,
  //                   ),
  //                 ),
  //                 actions: [
  //                   TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: Text(
  //                       'Okay',
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             });
  //       }
  //     });
  //   } catch (e) {
  //     return showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text('Something went wrong'),
  //             actions: [
  //               TextButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: Text(
  //                     'Okay',
  //                   )),
  //             ],
  //           );
  //         });
  //   } finally {
  //     setState(() {
  //       loading = false;
  //     });
  //   }
  // }

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
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
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              child: TextFormField(
                controller: upicontroller,
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
                  hintText: 'Enter valid UPI Id of reciever',
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            // SizedBox(
            //   height: MediaQuery.of(context).size.height * 0.03,
            // ),
            // Container(
            //   child: ElevatedButton(
            //     style: ButtonStyle(
            //       backgroundColor: MaterialStateProperty.all(
            //         Colors.pink[800],
            //       ),
            //       shape: MaterialStateProperty.all(RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       )),
            //     ),
            //     child: Text(
            //       "Proceed Payment",
            //     ),
            //     onPressed: () {
            //       // Navigator.push(context,
            //       //     MaterialPageRoute(builder: (BuildContext context) {
            //       //   return GetData();
            //       // }));
            //       // generateTxnToken(controller.text);
            //       controller.clear();
            //     },
            //   ),
            // ),
            // loading ? CircularProgressIndicator() : Container(),
            FutureBuilder<List<ApplicationMeta>>(
              future: _appsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container();
                }

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    left: 5,
                    right: 5,
                  ),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.6,
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data
                      .map((it) => Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Colors.black38,
                              ),
                            ),
                            key: ObjectKey(it.upiApplication),
                            color: Colors.grey[200],
                            child: InkWell(
                              onTap: () => _onTap(it),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.memory(
                                    it.icon,
                                    width: 64,
                                    height: 64,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Text(
                                      it.upiApplication.getAppName(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
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
