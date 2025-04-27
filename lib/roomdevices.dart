import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myhome/IPaddress.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RoomDevices extends StatefulWidget {
  final List<Map<String, dynamic>> roomData;

  RoomDevices({
    required this.roomData,
  });

  @override
  State<RoomDevices> createState() => _RoomDevicesState();
}

class _RoomDevicesState extends State<RoomDevices> {
  Map<String, bool> _isIconPressed = {};
  Map<String, bool> _Opensetting = {};
  Map<String, double> _brightnessValues = {};
  String Room_type = '';
  String image_room = '';
  String customize_name = '';
  String newname = '';
  String Home_No = '';
  int Sub_home_ID = 0;
  bool isSettingtime = true;
  String selectedCompositeKey = '';
  Timer? _debounce;
  String curtain = 'STOP';
  Color bottomcolorcurteinopen = Colors.grey.shade200;
  Color bottomcolorcurteinstop = Colors.grey.shade200;
  Color bottomcolorcurteinclose = Colors.grey.shade200;
  Color onlinecurtein = Colors.red;
  bool isActive = true;
  List<Map<String, dynamic>> _deviceDataList = [];
  Map<int, bool> isActiveMap = {};

  String removeLastThreeCharacters(String text) {
    if (text.length > 3) {
      return text.substring(0, text.length - 3);
    } else {
      return text; // หรือสามารถคืนค่าค่าว่างถ้าความยาวน้อยกว่าหรือเท่ากับ 3
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.roomData.isNotEmpty) {
      Room_type = widget.roomData.first['Room_type'] ?? '';
      Home_No = widget.roomData.first['Home_No'] ?? '';
      customize_name = widget.roomData.first['customize_name'] ?? '';
      Sub_home_ID = widget.roomData.first['Sub_home_ID'] ?? 0;
      image_room = widget.roomData.first['image_room'] ?? '';
    }

    print('${widget.roomData}');
    _getDeviceState();
    socketmain();
    _updateNewName();
  }

  void _updateNewName() {
    setState(() {
      newname = customize_name.isNotEmpty ? customize_name : Room_type;
    });
  }

  Future<void> _getDeviceState() async {
    Constants contants = Constants();
    final responseBody = await contants.sendRequst(
        'get-device-status', {'Home_No': Home_No, 'Sub_home_ID': Sub_home_ID});
    if (responseBody != null) {
      final data = jsonDecode(responseBody);
      if (data['results'] != null && data['results'] is List) {
        for (var device in data['results']) {
          String switch_ID = device['switch_ID'] ?? '';
          String key_state_1 = device['key_state_1'] ?? '';
          String key_state_2 = device['key_state_2'] ?? '';
          String status = device['status']['state'] ?? '';
          String compositeKey = _generateCompositeKey(switch_ID, key_state_1);
          String compositeKey_1 = _generateCompositeKey(switch_ID, key_state_2);

          bool isOn = status == 'ON';

          setState(() {
            _isIconPressed[compositeKey] = isOn;
            if (device['status'].containsKey('brightness')) {
              _brightnessValues[compositeKey_1] =
                  (device['status']['brightness'] ?? 0).toDouble() / 2.54;
            }
            print('$data');
          });
        }
      }
    }
  }

  Future<void> _getDevicetime(String Device_Type, String switch_ID,
      String key_state_1, String Home_No) async {
    {
      Constants contants = Constants();
      final responseBody = await contants.sendRequst(
        'get-a-schedule',
        {'switch_ID': switch_ID, 'key_state_1': key_state_1},
      );

      if (responseBody != null) {
        final data = jsonDecode(responseBody);
        if (data['message'] != null && data['message'] is List) {
          List<Map<String, dynamic>> deviceDataList = [];
          for (var device in data['message']) {
            int set_time_ID = device['set_time_ID'] ?? 0;
            String switch_ID = device['switch_ID'] ?? '';
            String set_time = device['set_time'] ?? '';
            int active = device['active'] ?? 0;
            String key_state_1 = device['key_state_1'] ?? '';
            String status_1 = device['status_1'] ?? '';
            String key_state_2 = device['key_state_2'] ?? '';
            var status_2;
            var statusValue = device['status_2'] ?? 0.0;

            if (statusValue is int) {
              status_2 = statusValue.toDouble();
            } else if (statusValue is double) {
              status_2 = statusValue;
            } else {
              status_2 =
                  0.0; // ค่าเริ่มต้นหากไม่มีค่าหรือค่าไม่ใช่ int หรือ double
            }

            String compositeKey = _generateCompositeKey(switch_ID, key_state_1);
            bool isActive = active == 1;
            isActiveMap[set_time_ID] = isActive;

            if (set_time.isNotEmpty && status_1.isNotEmpty) {
              deviceDataList.add({
                'set_time_ID': set_time_ID,
                'set_time': set_time,
                'isActive': isActive,
                'status_1': status_1,
                'status_2': status_2 / 2.54,
                'compositeKey': compositeKey
              });
            }

            setState(() {
              _deviceDataList = deviceDataList;
            });
          }
        }
      }
    }
  }

  void socketmain() {
    IO.Socket socket =
        IO.io('http://${Constants.IPAddress}:4040', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to server socket');
    });

    socket.on('mqtt-message', (data) {
      print('Received data: $data');

      if (data is Map<String, dynamic>) {
        print('Received Map data: $data');

        if (data.containsKey('getdata')) {
          var getData = data['getdata'];

          if (getData is String) {
            try {
              final List<dynamic> listData = jsonDecode(getData);

              for (var item in listData) {
                if (item is Map<String, dynamic>) {
                  String switch_ID = item['switch_ID'] ?? '';
                  String key_state_1 = item['key_state_1'] ?? '';
                  String key_state_2 = item['key_state_2'] ?? '';
                  String status = item['value_state_1'] ?? '';
                  int brightness = item['value_state_2'] ?? 0;

                  bool isOn = status == 'ON';
                  String compositeKey =
                      _generateCompositeKey(switch_ID, key_state_1);
                  String compositeKey_1 =
                      _generateCompositeKey(switch_ID, key_state_2);

                  setState(() {
                    _isIconPressed[compositeKey] = isOn;
                    if (item['value_state_2'] != null) {
                      _brightnessValues[compositeKey_1] =
                          (brightness.toDouble() / 2.54);
                    }
                    print('Updated state: $compositeKey = $isOn');
                    print(
                        'Brightness Updated: $compositeKey_1 = ${_brightnessValues[compositeKey_1]}');
                  });
                } else {
                  print('Item is not a Map<String, dynamic>: $item');
                }
              }
            } catch (e) {
              print('Error parsing JSON data: $e');
            }
            // } else if (getData is List) {
            //   for (var item in getData) {
            //     if (item is Map<String, dynamic>) {
            //       String deviceID = item['switch_ID'] ?? '';
            //       String stateID = item['state_1'] ?? '';
            //       String stateID_1 = item['state_2'] ?? '';
            //       String status = item['value_state_1'] ?? '';
            //       int brightness = item['value_state_2'] ?? 0;
            //       bool isOn = status == 'ON';
            //       String compositeKey = _generateCompositeKey(deviceID, stateID);
            //       String compositeKey_1 =
            //           _generateCompositeKey(deviceID, stateID_1);

            //       setState(() {
            //         _isIconPressed[compositeKey] = isOn;
            //         if (item['value_state_2'] != null) {
            //           _brightnessValues[compositeKey_1] =
            //               (brightness.toDouble() / 2.54);
            //         }
            //         print('Updated state: $compositeKey = $isOn');
            //         print(
            //             'Brightness Updated: $compositeKey_1 = ${_brightnessValues[compositeKey_1]}');
            //       });
            //     } else {
            //       print('Item is not a Map<String, dynamic>: $item');
            //     }
            //   }
            // } else {
            print('Expected String or List but got: $getData');
          }
        } else {
          print('No "getdata" key in data: $data');
        }
      } else {
        print('Unexpected data type: $data');
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });

    socket.on('connect_error', (data) {
      print('Connection socket Error: $data');
    });

    socket.on('connect_timeout', (_) {
      print('Connection Timeout');
    });

    socket.on('error', (error) {
      print('Socket Error: $error');
    });
  }

  IconData? _getIcon(
    String Device_Type,
    String switch_ID,
    String key_state_1,
  ) {
    final lightRegex = RegExp(r'^light(_\d+)?$');
    final hdlRegex = RegExp(r'^HDL(_\d+)?$');
    final curRegex = RegExp(r'^curtain(_\d+)?$');
    final plugRegex = RegExp(r'^PLUG(_\d+)?$');
    final dimRegex = RegExp(r'^dim(_\d+)?$');
    // final curstopRegex = RegExp(r'^Curstop(_\d+)?$');
    String compositeKey = _generateCompositeKey(switch_ID, key_state_1);

    if (lightRegex.hasMatch(Device_Type)) {
      return Icons.lightbulb_rounded;
    }
    if (hdlRegex.hasMatch(Device_Type)) {
      return Icons.dew_point;
    }
    if (curRegex.hasMatch(Device_Type)) {
      // ใช้ compositeKey
      return _isIconPressed[compositeKey] ?? false
          ? Icons.curtains_sharp
          : Icons.curtains_outlined;
    }
    if (plugRegex.hasMatch(Device_Type)) {
      return _isIconPressed[compositeKey] ?? false
          ? Icons.power
          : Icons.power_off;
    }
    if (dimRegex.hasMatch(Device_Type)) {
      return Icons.light_mode;
    }
    // if (curstopRegex.hasMatch(Type)) {
    //   return Icons.stop;
    // }

    return null;
  }

  Color? _getColor(
    String Device_Type,
    String switch_ID,
    String key_state_1,
  ) {
    final lightRegex = RegExp(r'^light(_\d+)?$');
    final hdlRegex = RegExp(r'^HDL(_\d+)?$');
    final curRegex = RegExp(r'^curtain(_\d+)?$');
    final plugRegex = RegExp(r'^PLUG(_\d+)?$');
    final dimRegex = RegExp(r'^dim(_\d+)?$');
    // final curstopRegex = RegExp(r'^Curstop(_\d+)?$');

    String compositeKey = _generateCompositeKey(switch_ID, key_state_1);

    if (lightRegex.hasMatch(Device_Type)) {
      return _isIconPressed[compositeKey] ?? false
          ? Colors.yellow
          : Colors.grey.shade400;
    }
    if (hdlRegex.hasMatch(Device_Type)) {
      return _isIconPressed[compositeKey] ?? false
          ? Colors.purple
          : Colors.grey.shade400;
    }
    if (curRegex.hasMatch(Device_Type)) {
      return onlinecurtein;
    }
    if (plugRegex.hasMatch(Device_Type)) {
      return _isIconPressed[compositeKey] ?? false
          ? Colors.green
          : Colors.grey.shade400;
    }
    if (dimRegex.hasMatch(Device_Type)) {
      return _isIconPressed[compositeKey] ?? false
          ? Colors.yellow
          : Colors.grey.shade400;
    }
    // if (curstopRegex.hasMatch(Device_Type)) {
    //   return getColorBasedOnCondition();
    // }

    return null;
  }

  Future<void> _toggleIconColor(
    String Device_Type,
    String switch_ID,
    String key_state_1,
    String Home_No,
  ) async {
    String compositeKey = _generateCompositeKey(switch_ID, key_state_1);
    Constants constants = Constants();
    final responseBody = await constants.sendRequst('publish-to-device', {
      'Home_No': Home_No,
      'switch_ID': switch_ID,
      'state_ID': key_state_1,
      'state': (_isIconPressed[compositeKey] ?? false) ? 'OFF' : 'ON',
    });

    if (responseBody != null) {
      setState(() {
        _isIconPressed[compositeKey] = !(_isIconPressed[compositeKey] ?? false);
      });
    }
  }

  Future<void> _activeTime(int settimeID, bool value) async {
    Constants constants = Constants();
    final responseBody = await constants.sendRequst(
      'active-a-schedule',
      {'set_time_ID': settimeID, 'active': value ? 1 : 0},
    );
    if (responseBody != null) {
      setState(() {
        isActiveMap[settimeID] = value;
      });
    }
  }

  Future<void> _deleteTime(
    int settimeID,
  ) async {
    Constants constants = Constants();
    final responseBody = await constants.sendRequst(
      'delete-a-schedule',
      {'set_time_ID': settimeID},
    );
    if (responseBody != null) {
      int index = _deviceDataList
          .indexWhere((deviceData) => deviceData['set_time_ID'] == settimeID);
      if (index != -1) {
        setState(() {
          _deviceDataList.removeAt(index);
        });
      }
    }
  }

  Future<void> _Opensettingdevice(
    String Device_Type,
    String switch_ID,
    String key_state_1,
    String Home_No,
  ) async {
    String compositeKey = _generateCompositeKey(switch_ID, key_state_1);

    setState(() {
      _Opensetting[compositeKey] = true;
      selectedCompositeKey = compositeKey;
      print('pooh : $selectedCompositeKey');
    });
    await _getDevicetime(Device_Type, switch_ID, key_state_1, Home_No);
  }

  void _updateBrightness(String switch_ID, String key_state_2, String Home_No,
      double brightness, String compositeKey_2) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () async {
      {
        double adjustedBrightness = brightness;
        int intValue = adjustedBrightness.toInt();
        final responseBody = await Constants().sendRequst('publish-to-device', {
          'Home_No': Home_No,
          'switch_ID': switch_ID,
          'state_ID': key_state_2,
          'state': intValue * 2.54,
        });
      }
    });
    setState(() {
      _brightnessValues[compositeKey_2] = brightness;
    });
  }

  Future<void> _curtain(
    String switchID,
    String stateID,
    String Home_No,
    String state,
  ) async {
    Constants constants = Constants();
    final responseBody = await constants.sendRequst('publish-to-device', {
      'Home_No': Home_No,
      'switch_ID': switchID,
      'state_ID': stateID,
      'state': state,
    });

    if (responseBody != null) {
      setState(() {
        if (state == 'OPEN') {
          curtain = 'OPEN';
          bottomcolorcurteinopen = Colors.yellow.shade200;
          bottomcolorcurteinstop = Colors.grey.shade200;
          bottomcolorcurteinclose = Colors.grey.shade200;
          onlinecurtein = Colors.green;
        } else if (state == 'STOP') {
          curtain = 'STOP';
          bottomcolorcurteinopen = Colors.grey.shade200;
          bottomcolorcurteinstop = Colors.yellow.shade200;
          bottomcolorcurteinclose = Colors.grey.shade200;
          onlinecurtein = Colors.red;
        } else if (state == 'CLOSE') {
          curtain = 'CLOSE';
          bottomcolorcurteinopen = Colors.grey.shade200;
          bottomcolorcurteinstop = Colors.grey.shade200;
          bottomcolorcurteinclose = Colors.yellow.shade200;
          onlinecurtein = Colors.green;
        }
      });
    }
  }

  String _generateCompositeKey(String switch_ID, String key_state_1) {
    return '$switch_ID+$key_state_1';
  }

  List<Widget> _buildWidgetsFromData() {
    List<Widget> widgets = [];
    for (var device in widget.roomData) {
      if (device.containsKey('left') && device.containsKey('top')) {
        double left = double.tryParse(device['left'].toString()) ?? 0.0;
        double top = double.tryParse(device['top'].toString()) ?? 0.0;
        String switchID = device['switch_ID'];
        String stateID = device['Device_Type'] == 'dim'
            ? device['key_state_2'] ?? ''
            : device['key_state_1'] ?? '';

        String compositeKey = _generateCompositeKey(switchID, stateID);

        widgets.add(
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () => {
                if (device['Device_Type'] == 'light' ||
                    device['Device_Type'] == 'PLUG')
                  {
                    _toggleIconColor(
                      device['Device_Type'],
                      device['switch_ID'] ?? '',
                      device['key_state_1'] ?? '',
                      device['Home_No'] ?? '',
                    )
                  }
                else
                  {
                    _Opensettingdevice(
                      device['Device_Type'],
                      device['switch_ID'] ?? '',
                      device['key_state_1'] ?? '',
                      device['Home_No'] ?? '',
                    ),
                  }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      width: 60.0 - (i * 10.0),
                      height: 60.0 - (i * 10.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getColor(device['Device_Type'],
                                device['switch_ID'], device['key_state_1'])
                            ?.withOpacity((i + 1) * 0.2),
                      ),
                    ),
                  Icon(
                    _getIcon(device['Device_Type'], device['switch_ID'],
                        device['key_state_1']),
                    color: device['Device_Type'] == 'curtain'
                        ? Colors.white
                        : _isIconPressed[_generateCompositeKey(
                                    device['switch_ID'],
                                    device['key_state_1'])] ??
                                false
                            ? Colors.white
                            : Colors.black,
                    size: 32.0,
                  ),
                  if (device['Device_Type'] == 'dim')
                    Transform.translate(
                      offset: Offset(-23, -23),
                      child: Container(
                        width: 40, // กำหนดความกว้างให้ Container
                        height: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.black.withOpacity(0.5)),
                            color: Colors.grey.shade200),
                        child: Center(
                          child: Text(
                            '${(_brightnessValues[compositeKey] ?? 0).toStringAsFixed(0)}%',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  List<Widget> _buildHDLContainer(String selectedCompositeKey) {
    List<Widget> widgets = [];
    double distance = 10.0;

    // ตรวจสอบว่า roomData มีข้อมูลสำหรับ Device_Type 'HDL'
    List<Map<String, dynamic>> hdlDevices = widget.roomData
        .where((device) => device['Device_Type'] == 'HDL')
        .toList();

    if (hdlDevices.isNotEmpty) {
      for (var deviceData in hdlDevices) {
        String deviceID = deviceData['switch_ID'] ?? '';
        String stateId = deviceData['key_state_1'] ?? '';
        String compositeKey = _generateCompositeKey(deviceID, stateId);
        bool isPressed = _isIconPressed[compositeKey] ?? false;
        Color statusColor =
            isPressed ? Colors.yellow.shade200 : Colors.grey.shade200;

        if (compositeKey == selectedCompositeKey) {
          widgets.add(
            Padding(
              padding: EdgeInsets.all(distance),
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.grey[700],
                ),
                height: 155,
                width: 350,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'HDL',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Spacer(),
                        Switch(
                          value: isPressed,
                          onChanged: (value) {
                            _toggleIconColor(
                              deviceData['Device_Type'] ?? '',
                              deviceData['switch_ID'] ?? '',
                              deviceData['key_state_1'] ?? '',
                              deviceData['Home_No'] ?? '',
                            );
                          },
                          activeColor: Colors.white,
                        ),
                        Text(
                          isPressed ? 'ON' : 'OFF',
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey[800],
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey[400],
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
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
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Text(
                          '25°',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 30,
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
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Humidity',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Text(
                          '50 %',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  List<Widget> _buildDimContainer(String selectedCompositeKey) {
    List<Widget> widgets = [];
    double distance = 10;
    List<Map<String, dynamic>> DimDevices = widget.roomData
        .where((device) => device['Device_Type'] == 'dim')
        .toList();

    if (DimDevices.isNotEmpty) {
      for (var deviceData in DimDevices) {
        String Home_No = deviceData['Home_No'] ?? '';
        String key_state_2 = deviceData['key_state_2'] ?? '';
        String switch_ID = deviceData['switch_ID'] ?? '';
        String key_state_1 = deviceData['key_state_1'] ?? '';
        int device_ID = deviceData['device_ID'] ?? 0;
        String compositeKey_2 = _generateCompositeKey(switch_ID, key_state_2);
        String compositeKey_1 = _generateCompositeKey(switch_ID, key_state_1);

        if (compositeKey_1 == selectedCompositeKey) {
          double brightness = _brightnessValues[compositeKey_2] ?? 0.0;
          bool isPressed = _isIconPressed[compositeKey_1] ?? false;
          Color statusColor =
              isPressed ? Colors.yellow.shade200 : Colors.grey.shade200;

          widgets.add(
            Padding(
              padding: EdgeInsets.all(distance),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[700],
                    ),
                    height: 130,
                    width: 360,
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            Text(
                              'Light brightness',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${brightness.toStringAsFixed(0)} %',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Switch(
                              value: isPressed,
                              onChanged: (value) {
                                _toggleIconColor(
                                  deviceData['Device_Type'] ?? '',
                                  deviceData['switch_ID'] ?? '',
                                  deviceData['key_state_1'] ?? '',
                                  deviceData['Home_No'] ?? '',
                                );
                              },
                              activeColor: Colors.white,
                            ),
                            Text(
                              isPressed ? 'ON' : 'OFF',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10)
                          ],
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey[800],
                          margin: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey[400],
                          margin: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            Container(
                              width: 280,
                              child: Slider(
                                value: brightness,
                                min: 0,
                                max: 100,
                                divisions: 1000,
                                label: '${(brightness).toStringAsFixed(0)}%',
                                onChanged: (double value) {
                                  _updateBrightness(switch_ID, key_state_2,
                                      Home_No, value, compositeKey_2);
                                },
                                activeColor: statusColor,
                                inactiveColor: Colors.grey,
                              ),
                            ),
                            Icon(
                              Icons.wb_sunny_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(width: 10)
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[700],
                    ),
                    width: 360,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[700],
                          ),
                          height: 70,
                          width: 360,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Set Time',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    Icons.alarm_outlined,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      _showModalBottomSheet(
                                          Home_No,
                                          key_state_2,
                                          switch_ID,
                                          key_state_1,
                                          device_ID);
                                    },
                                    icon: Icon(
                                      Icons.add_outlined,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                  _deviceDataList.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isSettingtime = !isSettingtime;
                                            });
                                          },
                                          icon: Icon(Icons.settings_outlined,
                                              size: 30,
                                              color: isSettingtime
                                                  ? Colors.white
                                                  : Colors.yellow.shade200),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Column(
                            children: _deviceDataList.map((deviceData) {
                              int set_time_ID = deviceData['set_time_ID'];
                              String set_time = deviceData['set_time'] ?? '';
                              double status_2 = deviceData['status_2'] ?? 0.0;
                              String status_1 = deviceData['status_1'] ?? '';
                              String CompositeKey =
                                  deviceData['compositeKey'] ?? '';
                              bool isActive = isActiveMap[set_time_ID] ?? false;
                              String formattedTimedim =
                                  removeLastThreeCharacters(set_time);

                              if (CompositeKey == selectedCompositeKey) {
                                return Column(
                                  children: [
                                    Container(
                                      height: 1,
                                      color: Colors.grey[800],
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.grey[400],
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.grey.shade700),
                                          height: 100,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 30,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  _deleteTime(set_time_ID);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.red),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 25,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              )
                                            ],
                                          ),
                                        ),
                                        AnimatedPositioned(
                                          duration: Duration(milliseconds: 300),
                                          left: isSettingtime ? 0 : 60,
                                          right: isSettingtime ? 0 : 50,
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.grey.shade700,
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 30,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 0),
                                                  child: Text(
                                                    '$formattedTimedim',
                                                    style: TextStyle(
                                                        fontSize: 45,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 25),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 28,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade200)),
                                                        child: Row(
                                                          children: [
                                                            Spacer(),
                                                            Icon(
                                                              Icons
                                                                  .wb_sunny_sharp,
                                                              color: status_1 ==
                                                                      'ON'
                                                                  ? Colors
                                                                      .yellow
                                                                      .shade200
                                                                  : Colors
                                                                      .white,
                                                              size: 20,
                                                            ),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              '$status_1',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            Spacer()
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Container(
                                                        height: 25,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade200)),
                                                        child: Center(
                                                          child: Text(
                                                            '${status_2.toStringAsFixed(0)}%',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacer(),
                                                Visibility(
                                                  visible: isSettingtime,
                                                  child: Expanded(
                                                    child: Switch(
                                                      value: isActive,
                                                      onChanged: (value) {
                                                        _activeTime(
                                                            set_time_ID, value);
                                                      },
                                                      activeColor: Colors.green,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2)
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }
      }
    } else {
      print('Toggling_2 compositeKey: $selectedCompositeKey');
    }

    return widgets;
  }

  void _showModalBottomSheet(String Home_No, String key_state_2,
      String switch_ID, String key_state_1, int device_ID) {
    Map<String, bool> _state = {};
    bool _statebool = false;
    int _brightnessontime = 1;
    DateTime _selectedTime = DateTime.now();
    Timer? _timer;
    bool _Iconminus = false;
    bool _Iconplus = false;

    Future<void> _setTime(
      String Home_No,
      String key_state_2,
      String switch_ID,
      String key_state_1,
      int device_ID,
    ) async {
      String compositeKey = _generateCompositeKey(switch_ID, key_state_1);
      String formattedTime =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      try {
        final response = await http.post(
          Uri.parse('http://${Constants.IPAddress}:5050/sets-a-schedule'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'Home_No': Home_No,
            'switch_ID': switch_ID,
            'state': {
              key_state_1: (_state[compositeKey] ?? false) ? 'ON' : 'OFF',
              key_state_2: (_brightnessontime * 2.54)
            },
            'set_time': formattedTime,
            'active': 1,
            'device_ID': device_ID
          }),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['results'] != null &&
              data['results'] is Map<String, dynamic>) {
            int set_time_ID = data['results']['set_time_ID'] ?? 0;
            String newSwitchID = data['results']['switch_ID'] ?? '';
            String newSetTime = data['results']['set_time'] ?? '';
            int newActive = data['results']['active'] ?? 0;
            String newState_1 = data['results']['key_state_1'] ?? '';
            String newStatus_1 = data['results']['status_1'] ?? '';
            var newStatus_2 = data['results']['status_2'] ?? 0.00;
            var newStatus = (newStatus_2 == 254 || newStatus_2 == 127)
                ? newStatus_2.toInt()
                : newStatus_2;
            // var statusValue = data['status_2'] ?? 0.0;

            // if (statusValue is int) {
            //   newStatus_2 = statusValue.toDouble();
            // } else if (statusValue is double) {
            //   newStatus_2 = statusValue;
            // } else {
            //   newStatus_2 =
            //       0.0; // ค่าเริ่มต้นหากไม่มีค่าหรือค่าไม่ใช่ int หรือ double
            // }

            bool isActive = newActive == 1;
            isActiveMap[set_time_ID] = isActive;
            // String compositeKey = newState_1 + newSwitchID;

            setState(() {
              _deviceDataList.add({
                'set_time_ID': set_time_ID,
                'set_time': newSetTime,
                'isActive': newActive == 1,
                'status_1': newStatus_1,
                'status_2': newStatus / 2.54,
                'compositeKey': compositeKey
              });
              print('time = $_deviceDataList');
              _state[compositeKey] = !(_state[compositeKey] ?? false);
            });
            print('Response from server2: ${response.body}');
          } else {
            print('Failed to send request: ${response.statusCode}');
          }
        }
      } catch (e) {
        print('Exception: $e');
      }
    }

    void _startDecreasingBrightness() {}

    String compositeKey = _generateCompositeKey(switch_ID, key_state_1);
    _state[compositeKey] = _statebool;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 234, 202, 164),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Set Time',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            _setTime(Home_No, key_state_2, switch_ID,
                                key_state_1, device_ID);
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    // color: Colors.red,
                    height: 200,
                    width: 380,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      onDateTimeChanged: (DateTime value) {
                        setState(
                          () {
                            _selectedTime = DateTime(
                              _selectedTime.year,
                              _selectedTime.month,
                              _selectedTime.day,
                              value.hour,
                              value.minute,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[700],
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 5)
                        ]),
                    height: 160,
                    width: 360,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 360,
                            height: 50,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Day',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                                Spacer(),
                                Text(
                                  'Everyday',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade200),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Colors.grey.shade200,
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 20,
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey[800],
                          margin: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey[400],
                          margin: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            // color: Colors.red,
                            width: 360,
                            height: 50,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'State',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                                Spacer(),
                                Switch(
                                  value: _statebool,
                                  onChanged: (value) {
                                    setState(() {
                                      _statebool = value;
                                      _state[compositeKey] = value;
                                    });
                                  },
                                  activeColor: Colors.white,
                                ),
                                Text(
                                  _statebool ? 'ON' : 'OFF',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade200),
                                ),
                                SizedBox(
                                  width: 20,
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey[800],
                          margin: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey[400],
                          margin: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            // color: Colors.red,
                            width: 360,
                            height: 50,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Brightness',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_brightnessontime > 0) {
                                        _brightnessontime -= 1;
                                      }
                                    });
                                  },
                                  onTapDown: (_) {
                                    setState(() {
                                      _Iconminus = true;
                                    });
                                  },
                                  onTapUp: (_) {
                                    setState(() {
                                      _Iconminus = false;
                                    });
                                  },
                                  onTapCancel: () {
                                    setState(() {
                                      _Iconminus = false;
                                    });
                                  },
                                  onLongPress: () {
                                    _timer = Timer.periodic(
                                        Duration(milliseconds: 100), (timer) {
                                      setState(() {
                                        if (_brightnessontime > 0) {
                                          _brightnessontime -= 1;
                                        }
                                      });
                                    });
                                  },
                                  onLongPressUp: () {
                                    if (_timer != null) {
                                      _timer!.cancel();
                                    }
                                  },
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: _Iconminus
                                        ? Colors.yellow.shade200
                                        : Colors.grey.shade100,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.white)),
                                  width: 50,
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      '$_brightnessontime %',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade200),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_brightnessontime < 100) {
                                        _brightnessontime += 1;
                                      }
                                    });
                                  },
                                  onTapDown: (_) {
                                    setState(() {
                                      _Iconplus = true;
                                    });
                                  },
                                  onTapUp: (_) {
                                    setState(() {
                                      _Iconplus = false;
                                    });
                                  },
                                  onTapCancel: () {
                                    setState(() {
                                      _Iconplus = false;
                                    });
                                  },
                                  onLongPress: () {
                                    _timer = Timer.periodic(
                                        Duration(milliseconds: 100), (timer) {
                                      setState(() {
                                        if (_brightnessontime < 100) {
                                          _brightnessontime += 1;
                                        }
                                      });
                                    });
                                  },
                                  onLongPressUp: () {
                                    if (_timer != null) {
                                      _timer!.cancel();
                                    }
                                  },
                                  child: Icon(
                                    Icons.add_circle,
                                    color: _Iconplus
                                        ? Colors.yellow.shade200
                                        : Colors.grey.shade200,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildCurstopContainer(String selectedCompositeKey) {
    List<Widget> widgets = [];
    double distance = 10.0;

    List<Map<String, dynamic>> CurDevices = widget.roomData
        .where((device) => device['Device_Type'] == 'curtain')
        .toList();

    if (CurDevices.isNotEmpty) {
      for (var deviceData in CurDevices) {
        String deviceID = deviceData['switch_ID'] ?? '';
        String stateId = deviceData['key_state_1'] ?? '';
        String Home_No = deviceData['Home_No'] ?? '';
        String compositeKey = _generateCompositeKey(deviceID, stateId);
        if (compositeKey == selectedCompositeKey) {
          widgets.add(
            Padding(
              padding: EdgeInsets.all(distance),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey[700]),
                height: 140,
                width: 360,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'Curtein',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: onlinecurtein),
                          width: 10,
                          height: 10,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          curtain,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 15,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey[800],
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey[400],
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            _curtain(deviceID, stateId, Home_No, 'OPEN');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bottomcolorcurteinopen),
                            width: 50,
                            height: 50,
                            child: Center(
                              child: Image.asset(
                                'images/open.png',
                                height: 40,
                                width: 40,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            _curtain(deviceID, stateId, Home_No, 'STOP');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bottomcolorcurteinstop),
                            width: 60,
                            height: 60,
                            child: Center(
                              child: Image.asset(
                                'images/pause-button.png',
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            _curtain(deviceID, stateId, Home_No, 'CLOSE');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bottomcolorcurteinclose),
                            width: 50,
                            height: 50,
                            child: Center(
                              child: Image.asset(
                                'images/close.png',
                                height: 40,
                                width: 40,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Spacer()
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  bool _hasDeviceType(String type) {
    return widget.roomData.any((device) => device['Device_Type'] == type);
  }

  String _getImageForRoomType(String roomType) {
    if (roomType.startsWith('bedroom')) {
      return 'http://${Constants.IPAddress}:5050/images/$image_room';
    } else if (roomType.startsWith('kitchen')) {
      return 'http://${Constants.IPAddress}:5050/images/$image_room';
    } else if (roomType.startsWith('livingroom')) {
      return 'http://${Constants.IPAddress}:5050/images/$image_room';
    } else if (roomType.startsWith('toilet')) {
      return 'http://${Constants.IPAddress}:5050/images/$image_room';
    } else {
      return 'images/default.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Colors.grey.shade100,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(left: 50, bottom: 22),
            title: Text(
              newname,
              style: TextStyle(
                  color: Colors.black,
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
            Container(
              width: 392,
              height: 720,
              decoration: BoxDecoration(color: Colors.grey.shade100),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Center(
                    child: Stack(
                      children: [
                        Image.network(
                          _getImageForRoomType(widget.roomData[0]['Room_type']),
                          fit: BoxFit.contain,
                          height: 300,
                          width: 225,
                        ),
                        ..._buildWidgetsFromData()
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                      color: Color.fromARGB(255, 234, 202, 164),
                    ),
                    width: 392,
                    height: 380,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          if (_Opensetting[selectedCompositeKey] ?? false) ...[
                            ..._buildDimContainer(selectedCompositeKey),
                            ..._buildHDLContainer(selectedCompositeKey),
                            ..._buildCurstopContainer(selectedCompositeKey),
                          ] else ...[
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              width: 340,
                              height: 80,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey.shade700),
                              child: Row(
                                children: [
                                  SizedBox(width: 15),
                                  Text(
                                    'Select device for control',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade100),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.info_outline,
                                    size: 30,
                                    color: Colors.grey.shade100,
                                  ),
                                  SizedBox(width: 15)
                                ],
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
