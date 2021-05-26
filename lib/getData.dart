import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GetData extends StatefulWidget {
  @override
  _GetDataState createState() => _GetDataState();
}

class _GetDataState extends State<GetData> {
  Future<List<dynamic>> fetchAlbum() async {
    final response = await http.get(Uri.http('api.dataatwork.org', '/v1/jobs'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
      // return DataGet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> fetchd(String id) async {
    print(id);
    final response = await http.get(Uri.http(
        'api.dataatwork.org', '/v1/jobs/normalize?job_title="ninja"'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
      // return DataGet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  TextEditingController controller = TextEditingController();
  bool search = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          'List',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        search = true;
                      });
                    }),
                hintText: 'Enter job title',
              ),
            ),
          ),
          FutureBuilder(
            future: search ? fetchd(controller.text) : fetchAlbum(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            index.toString(),
                          ),
                        ),
                        title: Text(snapshot.data[index]['title']),
                      );
                    });
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}

class DataGet {
  String title;
  String uid;
  DataGet({this.title, this.uid});
  factory DataGet.fromJson(Map<String, dynamic> json) {
    return DataGet(
      uid: json['uid'],
      title: json['title'],
    );
  }
}
