import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myhome/IPaddress.dart';

class RoomData extends StatefulWidget {
  final String HomeNumber;
  RoomData({required this.HomeNumber});
  @override
  _RoomDataState createState() => _RoomDataState();
}

class _RoomDataState extends State<RoomData> {
  Map<String, dynamic>? _profileData;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    Constants contants = Constants();
    final responseBody = await contants
        .sendRequst('get-profile', {'Home_No': widget.HomeNumber});
    if (responseBody != null) {
      final dataprofile = jsonDecode(responseBody);
      setState(() {
        _profileData = dataprofile;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final profile = _profileData!['RoomData'].first as Map<String, dynamic>;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: Color.fromARGB(255, 234, 202, 164),
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 50, bottom: 22),
              title: Text(
                'Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        body: Container(
          color: Color.fromARGB(255, 234, 202, 164),
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                width: 400,
                height: 711,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    color: Colors.grey.shade100),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: Color.fromARGB(255, 234, 202, 164),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 234, 202, 164),
                          image: DecorationImage(
                            image: AssetImage('images/profile.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '${profile['firstname']}  ${profile['lastname']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Home owner',
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 23, bottom: 5),
                            child: Text(
                              'Your Email',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        Container(
                          height: 55,
                          width: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                            child: TextField(
                              controller: TextEditingController(
                                text: profile['email'],
                              ),
                              style: TextStyle(color: Colors.black),
                              readOnly: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.email_outlined,
                                    color: Colors.grey.shade700),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 12, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 23, bottom: 5),
                            child: Text(
                              'Phone Number',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        Container(
                          height: 55,
                          width: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                            child: TextField(
                              controller: TextEditingController(
                                text: profile['Phone_No'],
                              ),
                              style: TextStyle(color: Colors.black),
                              readOnly: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.phone_outlined,
                                    color: Colors.grey.shade700),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 12, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 23, bottom: 5),
                            child: Text(
                              'Home Number',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        Container(
                          height: 55,
                          width: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                            child: TextField(
                              controller: TextEditingController(
                                text: profile['Home_No'],
                              ),
                              style: TextStyle(color: Colors.black),
                              readOnly: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.numbers_outlined,
                                    color: Colors.grey.shade700),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 12, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 23, bottom: 5),
                            child: Text(
                              'Home Type',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        Container(
                          height: 55,
                          width: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                            child: TextField(
                              controller: TextEditingController(
                                text: profile['Home_Type'],
                              ),
                              style: TextStyle(color: Colors.black),
                              readOnly: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.home_outlined,
                                    color: Colors.grey.shade700),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 12, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 23, bottom: 5),
                            child: Text(
                              'Receipt Number',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        Container(
                          height: 55,
                          width: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                            child: TextField(
                              controller: TextEditingController(
                                text: profile['Receipt_number'],
                              ),
                              style: TextStyle(color: Colors.black),
                              readOnly: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.receipt_outlined,
                                    color: Colors.grey.shade700),
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 12, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
