import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:myhome/IPaddress.dart';
import 'package:myhome/homepage_1.dart';
import 'package:myhome/room_data.dart';
import 'package:myhome/roomdevices.dart';
import 'package:myhome/sceneswitch.dart';
import 'package:myhome/settingpassword.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage_2 extends StatefulWidget {
  final String userInput;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? datascenesw;
  const HomePage_2(
      {Key? key, required this.userInput, this.data, this.datascenesw})
      : super(key: key);

  @override
  State<HomePage_2> createState() => _HomePage_2State();
}

class _HomePage_2State extends State<HomePage_2>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _roomnameController = TextEditingController();

  Map<String, dynamic>? _data;
  late SharedPreferences _prefs;
  String displayName = '';
  int _currentPage = 0;
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  Color _iconColor = Colors.white;

  // late Map<String, int> roomTypeDeviceCounts;

  @override
  void initState() {
    super.initState();
    _initPreferences();
    _data = widget.data;
    printSharedPreferencesData();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      print('Permission granted');
    } else {
      print('Permission denied');
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  void _handlePress() {
    setState(() {
      _iconColor = Colors.grey.shade700;
    });
    Timer(Duration(milliseconds: 50), () {
      setState(() {
        _iconColor = Colors.white;
      });
    });
  }

  Future<void> _updateName(String customName, String subHomeId,
      List<Map<String, dynamic>> roomList, String roomKey) async {
    Constants contants = Constants();
    final responseBody = await contants.sendRequst(
        'customize-name', {'cus_name': customName, 'Sub_home_ID': subHomeId});

    if (responseBody != null) {
      setState(() {
        for (var room in roomList) {
          if (room['Room_type'] == roomKey) {
            room['customize_name'] = customName; // Update the customize_name
            break;
          }
        }
      });
    }
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    String? storedData = _prefs.getString('roomData');
    if (storedData != null) {
      setState(() {
        _data = jsonDecode(storedData);
      });
    }
  }

  Future<void> printSharedPreferencesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? roomDataString = prefs.getString('roomData');
    if (roomDataString != null) {
      print('Room Data from SharedPreferences:');
      print(roomDataString);
      // You can decode and print the JSON if needed
      // Map<String, dynamic> roomData = jsonDecode(roomDataString);
      // print(roomData);
    } else {
      print('No Room Data found in SharedPreferences.');
    }
  }

  Future<void> _clearSavedRoom() async {
    await _prefs.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully locked out'),
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  IconData getIconGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.wb_sunny_outlined;
    } else if (hour < 18) {
      return Icons.wb_sunny_outlined;
    } else {
      return Icons.nights_stay;
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupRoomsByType(
      List<Map<String, dynamic>> roomData) {
    final Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var room in roomData) {
      final roomType = room['Room_type'] as String;
      if (groupedData.containsKey(roomType)) {
        groupedData[roomType]!.add(room);
      } else {
        groupedData[roomType] = [room];
      }
    }

    return groupedData;
  }

  String _getImageForRoomType(String roomType) {
    if (roomType.startsWith('bedroom')) {
      return 'images/bedroom.jpg';
    } else if (roomType.startsWith('kitchen')) {
      return 'images/kitchenroom.jpg';
    } else if (roomType.startsWith('livingroom')) {
      return 'images/livingroom.jpg';
    } else if (roomType.startsWith('bathroom')) {
      return 'images/bathroom.jpg';
    } else if (roomType.startsWith('toilet')) {
      return 'images/toilet.jpg';
    } else {
      return 'images/default.jpg';
    }
  }

  Map<String, int> countDevicesByRoomType(List<Map<String, dynamic>> roomData) {
    Map<String, int> deviceCounts = {};

    for (var room in roomData) {
      var roomType = room['Room_type'];
      if (deviceCounts.containsKey(roomType)) {
        deviceCounts[roomType] = deviceCounts[roomType]! + 1;
      } else {
        deviceCounts[roomType] = 1;
      }
    }

    return deviceCounts;
  }

  List<Widget> _buildHDLContainer(List<Map<String, dynamic>> hdldevices) {
    List<Widget> widgets = [];

    for (var deviceData in hdldevices) {
      // String deviceID = deviceData['switch_ID'] ?? '';
      // String stateId = deviceData['state_1'] ?? '';
      widgets.add(
        Container(
          width: 270,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.shade500.withOpacity(0.6),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Icon(
                    Icons.device_thermostat,
                    size: 30,
                    color: Colors.white,
                  ),
                  Text(
                    'Temperature',
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Text(
                    '25°',
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Image.asset(
                    'images/humidity.png',
                    height: 30,
                    width: 30,
                    color: Colors.white,
                  ),
                  Text(
                    'Humidity',
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                  SizedBox(
                    width: 80,
                  ),
                  Text(
                    '50 %',
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOut;
          var offsetTween = Tween(begin: Offset(-1, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: curve));
          var scaleTween =
              Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(offsetTween),
            child: ScaleTransition(
              scale: animation.drive(scaleTween),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedRooms = _groupRoomsByType(_data != null
        ? List<Map<String, dynamic>>.from(_data!['RoomData'])
        : []);
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
                Icons.menu,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          title: Center(
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Image.asset(
                'images/smart-home.png',
                height: 35,
                width: 35,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(
                getIconGreeting(),
                size: 30,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
      key: _scaffoldKey,
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.50,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 150,
              child: const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 177, 148, 112),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.file_copy),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _navigateToPage(
                    context, RoomData(HomeNumber: widget.userInput));
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Password'),
              onTap: () {
                Navigator.pop(context);
                _navigateToPage(context, Password());
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _clearSavedRoom();
              },
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 650,
          decoration: BoxDecoration(color: Color.fromARGB(255, 234, 202, 164)),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                'SELECT A ROOM',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 40),
              Container(
                width: 440,
                height: 420,
                color: Color.fromARGB(255, 234, 202, 164),
                child: FlutterCarousel(
                  items: List.generate(groupedRooms.keys.length, (index) {
                    return Builder(
                      builder: (context) {
                        String roomType = groupedRooms.keys.elementAt(index);
                        List<Map<String, dynamic>> roomList =
                            groupedRooms[roomType]!;

                        return _buildRoomWidget(roomType, roomList);
                      },
                    );
                  }),
                  options: CarouselOptions(
                    height: 440.0,
                    autoPlay: false,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.7,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    enableInfiniteScroll: true,
                    showIndicator: false,
                  ),
                ),
              ),
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  groupedRooms.keys.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: _currentPage == index ? 13 : 8,
                    height: _currentPage == index ? 6 : 8,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(6),
                      color: _currentPage == index ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.person_outlined),
                color: Colors.grey.shade800,
                iconSize: 30,
                onPressed: () {
                  _navigateToPage(
                      context, RoomData(HomeNumber: widget.userInput));
                },
              ),
              IconButton(
                icon: Icon(Icons.view_comfy_alt_outlined),
                color: Colors.grey.shade800,
                iconSize: 35,
                onPressed: () {
                  final groupedRooms = _groupRoomsByType(_data != null
                      ? List<Map<String, dynamic>>.from(_data!['RoomData'])
                      : []);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Sceneswitch(
                        grouproom: groupedRooms,
                        datascenesw: widget.datascenesw,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.lock_outline),
                color: Colors.grey.shade800,
                iconSize: 30,
                onPressed: () {
                  _navigateToPage(context, Password());
                },
              ),
              IconButton(
                icon: Icon(Icons.logout_outlined),
                color: Colors.grey.shade800,
                iconSize: 30,
                onPressed: () {
                  _clearSavedRoom();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomWidget(
      String roomType, List<Map<String, dynamic>> roomList) {
    String displayName = roomType;
    List<Map<String, dynamic>> hdlDevices =
        roomList.where((device) => device['Device_Type'] == 'HDL').toList();

    for (var room in roomList) {
      if (room.containsKey('customize_name') &&
          room['customize_name'] != null &&
          room['customize_name'].isNotEmpty &&
          room['Room_type'] == roomType) {
        displayName = room['customize_name'];

        break;
      }
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDevices(roomData: roomList),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_getImageForRoomType(roomType)),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        width: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            ..._buildHDLContainer(hdlDevices),
            Spacer(),
            Container(
              width: 270,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      displayName,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.edit, size: 25, color: _iconColor),
                        onPressed: () {
                          _handlePress();
                          _roomnameController.text = displayName;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // controller.forward();
                              return _buildDialog(context, roomType, roomList);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  ' DEVICE',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDialog(BuildContext context, String roomKey,
      List<Map<String, dynamic>> roomList) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        width: 300,
        height: 230,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.only(right: 180),
                child: Text(
                  'Roomname',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              TextField(
                controller: _roomnameController,
                onChanged: (value) {},
                maxLength: 15,
                inputFormatters: [LengthLimitingTextInputFormatter(15)],
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.edit,
                    color: Colors.black,
                    size: 30,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: EdgeInsets.only(left: 110),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: 17,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        String customName = _roomnameController.text;
                        String subHomeId = '';
                        for (var room in roomList) {
                          if (room['Room_type'] == roomKey) {
                            subHomeId = room['Sub_home_ID'].toString();

                            break;
                          }
                        }

                        await _updateName(
                            customName, subHomeId, roomList, roomKey);
                        setState(() {
                          for (var room in roomList) {
                            if (room['Room_type'] == roomKey) {
                              room['customize_name'] == customName;
                            }
                          }

                          _roomnameController.clear();
                        });

                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 234, 202, 164),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(width: 1, color: Colors.black)),
                        child: Center(
                          child: Text(
                            'Submit',
                            style: TextStyle(
                                fontSize: 17,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 20); // ระยะจากล่างขึ้นมา
    path.quadraticBezierTo(
      size.width / 2, // จุดควบคุม x (ตรงกลาง)
      size.height, // จุดควบคุม y (ส่วนโค้ง)
      size.width, // จุดปลาย x
      size.height - 20, // จุดปลาย y
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
