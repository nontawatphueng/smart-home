import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myhome/homepage_2.dart';
import 'package:myhome/settingpassword.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:myhome/IPaddress.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _roomcontroller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  String _userInput = '';
  String _userPassword = '';
  Map<String, dynamic>? _data;
  Color _colorLogin = Color.fromARGB(255, 234, 202, 164);
  Map<String, dynamic>? _scenedata;
  @override
  void initState() {
    super.initState();
    _checkSavedRoom();
    print('${Constants.IPAddress}');
  }

  @override
  void dispose() {
    _roomcontroller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> _roomData() async {
  //   // แสดง Dialog รอ
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return _showWaitingDialog(context);
  //     },
  //   );

  //   // ตั้งค่าข้อมูล RoomData โดยตรง
  //   setState(() {
  //     _data = {
  //       "RoomData": [
  //         {
  //           "Home_No": "202/1",
  //           "Sub_home_ID": 1,
  //           "customize_name": "Bedroom 1",
  //           "Room_type": "bedroom1",
  //           "device_ID": 1,
  //           "switch_ID": "0x123456789a",
  //           "Device_Type": "light",
  //           "key_state_1": "state_l1",
  //           "key_state_2": null,
  //           "key_state_3": null,
  //           "image_room": "1-br001.jpg",
  //           "left": 130,
  //           "top": 20
  //         },
  //         {
  //           "Home_No": "202/1",
  //           "Sub_home_ID": 1,
  //           "customize_name": "Bedroom 1",
  //           "Room_type": "bedroom1",
  //           "device_ID": 2,
  //           "switch_ID": "0x123456789b",
  //           "Device_Type": "HDL",
  //           "key_state_1": "state_5",
  //           "key_state_2": null,
  //           "key_state_3": "humidity_65",
  //           "image_room": "1-br001.jpg",
  //           "left": 85,
  //           "top": 90
  //         },
  //         {
  //           "Home_No": "202/1",
  //           "Sub_home_ID": 1,
  //           "customize_name": "Bedroom 1",
  //           "Room_type": "bedroom1",
  //           "device_ID": 3,
  //           "switch_ID": "0x123456789a",
  //           "Device_Type": "light",
  //           "key_state_1": "state_l2",
  //           "key_state_2": null,
  //           "key_state_3": null,
  //           "image_room": "1-br001.jpg",
  //           "left": 130,
  //           "top": 160
  //         },
  //         {
  //           "Home_No": "202/1",
  //           "Sub_home_ID": 1,
  //           "customize_name": "Bedroom 1",
  //           "Room_type": "bedroom1",
  //           "device_ID": 4,
  //           "switch_ID": "0x123456789c",
  //           "Device_Type": "curtain",
  //           "key_state_1": "state",
  //           "key_state_2": null,
  //           "key_state_3": null,
  //           "image_room": "1-br001.jpg",
  //           "left": 85,
  //           "top": 5
  //         },
  //         {
  //           "Home_No": "202/1",
  //           "Sub_home_ID": 1,
  //           "customize_name": "Bedroom 1",
  //           "Room_type": "bedroom1",
  //           "device_ID": 1,
  //           "switch_ID": "0x123456789a",
  //           "Device_Type": "light",
  //           "key_state_1": "state_l1",
  //           "key_state_2": null,
  //           "key_state_3": null,
  //           "image_room": "1-br001.jpg",
  //           "left": 130,
  //           "top": 20
  //         },
  //         {
  //           "Home_No": "202/1",
  //           "Sub_home_ID": 1,
  //           "customize_name": "Bedroom 2",
  //           "Room_type": "bedroom2",
  //           "device_ID": 2,
  //           "switch_ID": "0x123456789b",
  //           "Device_Type": "HDL",
  //           "key_state_1": "state_5",
  //           "key_state_2": null,
  //           "key_state_3": "humidity_65",
  //           "image_room": "1-br001.jpg",
  //           "left": 85,
  //           "top": 90
  //         },
  //         {
  //           "Home_No": "202/1",
  //           "Sub_home_ID": 1,
  //           "customize_name": "Bedroom 2",
  //           "Room_type": "bedroom2",
  //           "device_ID": 3,
  //           "switch_ID": "0x123456789a",
  //           "Device_Type": "light",
  //           "key_state_1": "state_l2",
  //           "key_state_2": null,
  //           "key_state_3": null,
  //           "image_room": "1-br001.jpg",
  //           "left": 130,
  //           "top": 160
  //         },
  //         {
  //           "Home_No": "202/1",
  //           "Sub_home_ID": 1,
  //           "customize_name": "Bedroom 2",
  //           "Room_type": "bedroom2",
  //           "device_ID": 4,
  //           "switch_ID": "0x123456789c",
  //           "Device_Type": "curtain",
  //           "key_state_1": "state",
  //           "key_state_2": null,
  //           "key_state_3": null,
  //           "image_room": "1-br001.jpg",
  //           "left": 85,
  //           "top": 5
  //         }
  //       ]
  //     };
  //   });

  //   await Future.delayed(Duration(seconds: 1)); // จำลองการรอโหลดข้อมูล
  //   Navigator.pop(context);

  //   if (_data != null && _data!.isNotEmpty) {
  //     _sceneSwitch();
  //   } else {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return dialogforhome(
  //           context,
  //           'images/incorrect.png',
  //           'No Home',
  //           'The Home Number OR password is incorrect',
  //         );
  //       },
  //     );
  //   }
  // }

  // Future<void> _sceneSwitch() async {
  //   // ตั้งค่าข้อมูล SceneSwitch โดยตรง
  //   setState(() {
  //     _scenedata = {
  //       "results": [
  //         {
  //           "switch_ID": "Legrand-SCENE4G(new)",
  //           "brand": "bticino",
  //           "switch_type": "SW-SCENE4G",
  //           "group_1": "65517",
  //           "group_2": "65516",
  //           "group_3": "65515",
  //           "group_4": "65514"
  //         },
  //         {
  //           "switch_ID": "SH-SC2G",
  //           "brand": "schneider",
  //           "switch_type": "SW-SCENE2G",
  //           "group_1": "key1_event_notification",
  //           "group_2": "key2_event_notification"
  //         },
  //         {
  //           "switch_ID": "SH-SC4G",
  //           "brand": "schneider",
  //           "switch_type": "SW-SCENE4G",
  //           "group_1": "key1_event_notification",
  //           "group_2": "key2_event_notification",
  //           "group_3": "key3_event_notification",
  //           "group_4": "key4_event_notification"
  //         }
  //       ]
  //     };
  //   });

  //   Navigator.pushReplacement(
  //     context,
  //     PageRouteBuilder(
  //       transitionDuration: Duration(milliseconds: 700),
  //       pageBuilder: (context, animation, secondaryAnimation) => HomePage_2(
  //         userInput: _userInput,
  //         data: _data,
  //         datascenesw: _scenedata,
  //       ),
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //         var begin = Offset(0.0, 1.0);
  //         var end = Offset.zero;
  //         var curve = Curves.ease;

  //         var tween =
  //             Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  //         return SlideTransition(
  //           position: animation.drive(tween),
  //           child: child,
  //         );
  //       },
  //     ),
  //   );
  // }

  Future<void> _roomData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _showWaitingDialog(context);
      },
    );
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialogforhome(
            context,
            'images/nointernet.png',
            'NO INTERNET',
            'Please check your internet connection and try again',
          );
        },
      );
    } else {
      try {
        final response = await http.post(
          Uri.parse('http://${Constants.IPAddress}:5050/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'Home_No': '$_userInput', 'password': '$_userPassword'}),
        );
        await Future.delayed(Duration(seconds: 1));
        Navigator.pop(context);
        if (response.statusCode == 200) {
          setState(() {
            _data = json.decode(response.body);
          });
          _sceneSwitch();
          print(_data);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return dialogforhome(
                context,
                'images/incorrect.png',
                'No Home',
                'The Home Number OR password is incorrect',
              );
            },
          );
          print('Failed to load data2: ${response.body}');
        }
      } catch (e) {
        print('Exception:$e');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return dialogforhome(
              context,
              'images/incorrect.png',
              'No Home',
              'The Home Number OR password is incorrect',
            );
          },
        );
      }
    }
  }

  Future<void> _sceneSwitch() async {
    Constants contants = Constants();
    final responseBody = await contants.sendRequst('get-scene-sw', {
      'Home_No': '$_userInput',
    });

    if (responseBody != null) {
      setState(() {
        _scenedata = json.decode(responseBody);
      });
      if (_data == null || _data!.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return dialogforhome(
              context,
              'images/incorrect.png',
              'No Home',
              'The Home Number OR password is incorrect',
            );
          },
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 700),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomePage_2(
                    userInput: _userInput,
                    data: _data,
                    datascenesw: _scenedata,
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var begin = Offset(0.0, 1.0);
                var end = Offset.zero;
                var curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                // return DelayedReveal(
                //   delay: Duration(milliseconds: 500),
                //   child:
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              }),
        );
      }
    }
  }

  Future<void> _checkSavedRoom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedRoom = prefs.getString('saved_room');
    String? savedPassword = prefs.getString('saved_password');
    print('Saved room: $savedRoom');
    if (savedRoom != null && savedPassword != null) {
      setState(() {
        _userInput = savedRoom;
        _userPassword = savedPassword;
      });
      if (_userInput.isNotEmpty && _userPassword.isNotEmpty) {
        await _roomData();
      }
    }
  }

  Future<void> _saveRoom(String room, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_room', room);
    await prefs.setString('saved_password', password);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Dialog _showWaitingDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 60,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Please wait...'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: 825,

          // color: Colors.white,
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              CustomPaint(
                painter: ContainerShadowPainter(),
                child: ClipPath(
                  clipper: BottomMiddleClipper(),
                  child: Container(
                    width: 400,
                    height: 320,
                    color: Color.fromARGB(255, 234, 202, 164),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                        ),
                        Image.asset(
                          'images/smart-home.png',
                          height: 100,
                          width: 100,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'My Home',
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 60),
              Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 250, 0),
                      child: Text(
                        'Home Number',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: 60,
                      width: 375,
                      child: TextField(
                        controller: _roomcontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 177, 148, 112),
                                width: 2.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 177, 148, 112)
                                    .withOpacity(0.5),
                                width: 2.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 177, 148, 112),
                                width: 2.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: Icon(
                            Icons.room_preferences,
                            color: Color.fromARGB(255, 177, 148, 112),
                            size: 30,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 280, 0),
                      child: Text(
                        'Password',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: 60,
                      width: 375,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 177, 148, 112),
                                width: 2.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 177, 148, 112)
                                    .withOpacity(0.5),
                                width: 2.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 177, 148, 112),
                                width: 2.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color.fromARGB(255, 177, 148, 112),
                            size: 30,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color.fromARGB(255, 177, 148, 112),
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: GestureDetector(
                        onTapDown: (_) {
                          setState(() {
                            _colorLogin = Color.fromARGB(255, 234, 202, 164)
                                .withOpacity(0.5);
                          });
                        },
                        onTapUp: (_) async {
                          setState(() {
                            _userInput = _roomcontroller.text;
                            _userPassword = _passwordController.text;
                            _colorLogin = Color.fromARGB(255, 234, 202, 164);
                          });
                          await _saveRoom(_userInput, _userPassword);
                          _roomData();

                          FocusScope.of(context).unfocus();
                        },
                        onTapCancel: () {
                          setState(() {
                            _colorLogin = Color.fromARGB(255, 234, 202, 164);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
                          decoration: BoxDecoration(
                            color: _colorLogin,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 60,
                          width: 250,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Password()),
                        );
                      },
                      child: Text(
                        'Setting Password',
                        style: TextStyle(color: Colors.black),
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

  Widget dialogforhome(
      BuildContext context, String imagePath, String title, String message) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 250,
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade100,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Image.asset(
              imagePath,
              width: 100,
              height: 100,
              color: Colors.grey.shade700,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              title, //
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, left: 20),
              child: Text(
                textAlign: TextAlign.center,
                message, //'Please check your internet connection and try again','NO INTERNET',
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 280,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  color: Color.fromARGB(255, 234, 202, 164).withOpacity(0.8),
                ),
                child: Center(
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BottomMiddleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;

    Path path = Path();
    path.lineTo(0, height);
    path.lineTo(width * 0.0, height);
    path.quadraticBezierTo(width * 0.5, height - 90, width * 1.0, height);
    path.lineTo(width, height);
    path.lineTo(width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class ContainerShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    double width = size.width;
    double height = size.height;

    path.lineTo(0, height);
    path.lineTo(width * 0.0, height);
    path.quadraticBezierTo(width * 0.5, height - 90, width * 1.0, height);
    path.lineTo(width, height);
    path.lineTo(width, 0);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.7), 12.0, false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
