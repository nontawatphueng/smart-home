import 'dart:convert';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:myhome/IPaddress.dart';

class Sceneswitch extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> grouproom;
  final Map<String, dynamic>? datascenesw;

  const Sceneswitch({super.key, required this.grouproom, this.datascenesw});

  @override
  State<Sceneswitch> createState() => _SceneswitchState();
}

class _SceneswitchState extends State<Sceneswitch> {
  late final Map<String, List<Map<String, dynamic>>> grouproom;
  ScrollController _scrollController = ScrollController();
  // Map<String, String> containers = {};
  List<Widget> switchonetwo = [];
  bool isSettingscene = false;
  Map<String, bool> _isIconPressed = {};
  String _selectedValue = '';
  List<Map<String, dynamic>> sceneSwitchList = [];
  int _currentIndex = 0;
  Map<String, String> sceneData = {};
  bool shownull = false;

  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    grouproom = widget.grouproom;
    // print('rooms : $grouproom');

    if (widget.datascenesw != null &&
        widget.datascenesw!['results'].isNotEmpty) {
      var initialScene = widget.datascenesw!['results'].first;
      _sendSceneData(
        initialScene['switch_ID'],
        initialScene['brand'],
        initialScene['switch_type'],
        initialScene['group_1'] ?? '',
        initialScene['group_2'] ?? '',
        initialScene['group_3'] ?? '',
        initialScene['group_4'] ?? '',
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String _generateCompositeKey(String switchID, String keyState) {
    return '$switchID+$keyState';
  }

  void _onScroll() {
    double position = _scrollController.position.pixels;
    int currentIndex = (position / 295).round();

    if (currentIndex != _lastIndex) {
      _lastIndex = currentIndex;

      if (currentIndex >= 0 &&
          currentIndex < widget.datascenesw!['results'].length) {
        var currentScene = widget.datascenesw!['results'][currentIndex];
        _sendSceneData(
          currentScene['switch_ID'],
          currentScene['brand'],
          currentScene['switch_type'],
          currentScene['group_1'] ?? '',
          currentScene['group_2'] ?? '',
          currentScene['group_3'] ?? '',
          currentScene['group_4'] ?? '',
        );
      }
    }
  }

  int _lastIndex = -1;

  void _sendSceneData(
    String switchID,
    String brand,
    String switchType,
    String group1,
    String group2,
    String group3,
    String group4,
  ) {
    print("Current Scene:");
    print("switchID: $switchID");
    print("brand: $brand");
    print("switchType: $switchType");
    print("group1: $group1");
    print("group2: $group2");
    print("group3: $group3");
    print("group4: $group4");

    List<Widget> groupContainers = [];

    sceneData = {
      "switchID": switchID,
      "group1": group1,
      "group2": group2,
      "group3": group3,
      "group4": group4,
    };
    _getscenedata(sceneData);

    if (group1.isNotEmpty) {
      groupContainers.add(_buildGroupContainer(
        1,
        switchID,
        group1,
      ));
    }
    if (group2.isNotEmpty) {
      groupContainers.add(_buildGroupContainer(
        2,
        switchID,
        group2,
      ));
    }
    if (group3.isNotEmpty) {
      groupContainers.add(_buildGroupContainer(
        3,
        switchID,
        group3,
      ));
    }
    if (group4.isNotEmpty) {
      groupContainers.add(_buildGroupContainer(
        4,
        switchID,
        group4,
      ));
    }

    setState(() {
      switchonetwo = groupContainers;
    });
  }

  Widget _buildGroupContainer(int group, String switchID, String group4) {
    return Container(
      width: 60,
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        SizedBox(height: 2),
        Text(
          '$group',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
        ),
        Spacer(),
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.yellow.shade400,
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(1),
                blurRadius: 1,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
      ]),
    );
  }

  void _updateLightStatus(List<Map<String, dynamic>> dataList) {
    setState(() {
      // รีเซ็ตค่าทุกตัวใน _isIconPressed เป็น false
      _isIconPressed.updateAll((key, value) => false);
    });
    for (var data in dataList) {
      if (data.containsKey('switch_ID') && data.containsKey('key_state')) {
        String switchID = data['switch_ID'];
        String keyState = data['key_state'];

        String compositeKey = _generateCompositeKey(switchID, keyState);

        setState(() {
          _isIconPressed[compositeKey] =
              !(_isIconPressed[compositeKey] ?? false);
          print('state :  ${_isIconPressed[compositeKey]}, $compositeKey');
        });
      }
    }
  }

  Future<void> _getscenedata(Map<String, dynamic> sceneData) async {
    if (sceneData.isNotEmpty) {
      Map<String, dynamic> newEntries = {};
      sceneSwitchList.clear();
      switch (_currentIndex) {
        case 0:
          if (sceneData['group1']!.isNotEmpty) {
            newEntries = ({
              "scene_switch_ID": sceneData['switchID']!,
              "action_group": sceneData['group1']!,
              "group": '1',
            });
          }
          break;
        case 1:
          if (sceneData['group2']!.isNotEmpty) {
            newEntries = ({
              "scene_switch_ID": sceneData['switchID']!,
              "action_group": sceneData['group2']!,
              "group": '2',
            });
          }
          break;
        case 2:
          if (sceneData['group3']!.isNotEmpty) {
            newEntries = ({
              "scene_switch_ID": sceneData['switchID']!,
              "action_group": sceneData['group3']!,
              "group": '3',
            });
          }
          break;
        case 3:
          if (sceneData['group4']!.isNotEmpty) {
            newEntries = ({
              "scene_switch_ID": sceneData['switchID']!,
              "action_group": sceneData['group4']!,
              "group": '4',
            });
          }
          break;
      }
      setState(() {
        sceneSwitchList.add(newEntries);
      });

      print('Updated Scene Switch List: $sceneSwitchList');

      Constants constants = Constants();
      final responseBody = await constants.sendRequst(
        'get-scene-sw-group',
        newEntries,
      );

      if (responseBody != null) {
        final decodedResponse =
            jsonDecode(responseBody) as Map<String, dynamic>;
        List<Map<String, dynamic>> apiEntries = [];

        if (decodedResponse.containsKey('results')) {
          final results = decodedResponse['results'] as List<dynamic>;
          for (var item in results) {
            final entry = item as Map<String, dynamic>;
            if (entry.containsKey('switch_ID') &&
                entry.containsKey('key_state') &&
                entry.containsKey('value_state')) {
              apiEntries.add({
                'switch_ID': entry['switch_ID'],
                'key_state': entry['key_state'],
                'value_state': entry['value_state'],
              });
            }
          }

          // อัปเดต sceneSwitchList ด้วยข้อมูลจาก API
          setState(() {
            sceneSwitchList.addAll(apiEntries);
            _updateLightStatus(sceneSwitchList);
            print('Updated Scene Switch List from API: $sceneSwitchList');
          });
        }
      }
    }
  }

  Future<void> _submitscene() async {
    const String ipAddress = "192.168.108.234"; // เปลี่ยนเป็น IP ของคุณ
    final String endpoint = 'set-scene-sw';

    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:5050/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(sceneSwitchList),
      );

      if (response.statusCode == 200) {
        print('Response from server: ${response.body}');
      } else {
        print('Failed to send request: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }

    // พิมพ์ข้อมูลที่ส่งไป
    print('scene : $sceneSwitchList');
  }

  Map<String, bool> _colorscene = {};
  @override
  List<Widget> _Apiscenesw() {
    List<Widget> widgets = [];
    if (widget.datascenesw != null &&
        widget.datascenesw!.containsKey('results')) {
      var results = widget.datascenesw!['results'] as List<dynamic>;
      for (var device in results) {
        String switchID = device['switch_ID'];
        String brand = device['brand'];
        String switch_type = device['switch_type'];
        String group1 = device['group_1'] ?? '';
        String group2 = device['group_2'] ?? '';
        String group3 = device['group_3'] ?? '';
        String group4 = device['group_4'] ?? '';
        Widget container;

        if (switch_type == "SW-SCENE4G") {
          container = Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(1),
                  offset: Offset(0, -3),
                  blurRadius: 1,
                  spreadRadius: 0.5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(0, 3),
                  blurRadius: 1,
                  spreadRadius: 0.5,
                ),
              ],
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade100,
            ),
            width: 195,
            height: 225,
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 15),
                    Text(
                      brand,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Spacer(),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  height: 160,
                  width: 175,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade700),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _colorscene[group1] = true;
                                  });
                                },
                                onTapUp: (_) async {
                                  _controlscene(switchID, group1, '1');

                                  await Future.delayed(
                                      Duration(milliseconds: 100));
                                  setState(() {
                                    _colorscene[group1] = false;
                                  });
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _colorscene[group1] = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                      ),
                                      color: _colorscene[group1] == true
                                          ? Colors.yellow.shade400
                                          : Colors.grey.shade700),
                                  width: 85,
                                  height: 80,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '1',
                                        style: TextStyle(
                                            color: _colorscene[group1] == true
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade500,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Container(
                                        width: 20,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: _colorscene[group1] == true
                                              ? Colors.white
                                              : Colors.yellow.shade400,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.yellow.withOpacity(1),
                                              blurRadius: 1,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10)
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _colorscene[group2] = true;
                                  });
                                },
                                onTapUp: (_) async {
                                  _controlscene(switchID, group2, '2');

                                  await Future.delayed(
                                      Duration(milliseconds: 100));
                                  setState(() {
                                    _colorscene[group2] = false;
                                  });
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _colorscene[group2] = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                    ),
                                    color: _colorscene[group2] == true
                                        ? Colors.yellow.shade400
                                        : Colors.grey.shade700,
                                  ),
                                  width: 85,
                                  height: 80,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        '2',
                                        style: TextStyle(
                                            color: _colorscene[group2] == true
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade500,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Container(
                                        width: 20,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: _colorscene[group2] == true
                                              ? Colors.white
                                              : Colors.yellow.shade400,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.yellow.withOpacity(1),
                                              blurRadius: 1,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            color: Colors.grey.shade300,
                            width: 5,
                            height: 160,
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _colorscene[group3] = true;
                                  });
                                },
                                onTapUp: (_) async {
                                  _controlscene(switchID, group3, '3');

                                  await Future.delayed(
                                      Duration(milliseconds: 100));
                                  setState(() {
                                    _colorscene[group3] = false;
                                  });
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _colorscene[group3] = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20),
                                    ),
                                    color: _colorscene[group3] == true
                                        ? Colors.yellow.shade400
                                        : Colors.grey.shade700,
                                  ),
                                  width: 85,
                                  height: 80,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        '3',
                                        style: TextStyle(
                                            color: _colorscene[group3] == true
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade500,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Container(
                                        width: 20,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: _colorscene[group3] == true
                                              ? Colors.white
                                              : Colors.yellow.shade400,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.yellow.withOpacity(1),
                                              blurRadius: 1,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10)
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _colorscene[group4] = true;
                                  });
                                },
                                onTapUp: (_) async {
                                  _controlscene(switchID, group4, '4');

                                  await Future.delayed(
                                      Duration(milliseconds: 100));
                                  setState(() {
                                    _colorscene[group4] = false;
                                  });
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _colorscene[group4] = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(20),
                                    ),
                                    color: _colorscene[group4] == true
                                        ? Colors.yellow.shade400
                                        : Colors.grey.shade700,
                                  ),
                                  width: 85,
                                  height: 80,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        '4',
                                        style: TextStyle(
                                            color: _colorscene[group4] == true
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade500,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Container(
                                        width: 20,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: _colorscene[group4] == true
                                              ? Colors.white
                                              : Colors.yellow.shade400,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.yellow.withOpacity(1),
                                              blurRadius: 1,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          container = Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(1),
                  offset: Offset(0, -3), // เงาด้านบนมีการเลื่อนขึ้น
                  blurRadius: 1,
                  spreadRadius: 0.5,
                ),
                // เงาด้านล่าง
                BoxShadow(
                  color: Colors.black.withOpacity(0.5), // สีของเงาด้านล่าง
                  offset: Offset(0, 3), // เงาด้านล่างมีการเลื่อนลง
                  blurRadius: 1, // ความเบลอของเงา
                  spreadRadius: 0.5, // ขยายขอบเขตของเงา
                ),
              ],
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade100,
            ),
            width: 195,
            height: 225,
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 15),
                    Text(
                      brand,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Spacer(),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  height: 160,
                  width: 175,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade700),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _colorscene[group1] = true;
                                  });
                                },
                                onTapUp: (_) async {
                                  _controlscene(switchID, group1, '1');

                                  await Future.delayed(
                                      Duration(milliseconds: 100));
                                  setState(() {
                                    _colorscene[group1] = false;
                                  });
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _colorscene[group1] = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20)),
                                      color: _colorscene[group1] == true
                                          ? Colors.yellow.shade400
                                          : Colors.grey.shade700),
                                  width: 85,
                                  height: 160,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        '1',
                                        style: TextStyle(
                                            color: _colorscene[group1] == true
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade500,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Container(
                                        width: 20,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: _colorscene[group1] == true
                                              ? Colors.white
                                              : Colors.yellow.shade400,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.yellow.withOpacity(1),
                                              blurRadius: 1,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            color: Colors.grey.shade300,
                            width: 5,
                            height: 160,
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _colorscene[group2] = true;
                                  });
                                },
                                onTapUp: (_) async {
                                  _controlscene(switchID, group2, '2');

                                  await Future.delayed(
                                      Duration(milliseconds: 100));
                                  setState(() {
                                    _colorscene[group2] = false;
                                  });
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _colorscene[group2] = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      color: _colorscene[group2] == true
                                          ? Colors.yellow.shade400
                                          : Colors.grey.shade700),
                                  width: 85,
                                  height: 160,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        '2',
                                        style: TextStyle(
                                            color: _colorscene[group2] == true
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade500,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Container(
                                        width: 20,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: _colorscene[group2] == true
                                              ? Colors.white
                                              : Colors.yellow.shade400,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.yellow.withOpacity(1),
                                              blurRadius: 1,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        widgets.add(container);
      }
    }

    return widgets;
  }

  Future<void> _controlscene(
    String switch_ID,
    String actiongroup,
    String group,
  ) async {
    Constants constants = Constants();
    final responseBody = await constants.sendRequst('publish-scene-sw', {
      'switch_ID': switch_ID,
      'group': group,
      'action_group': actiongroup,
    });

    if (responseBody != null) {
      setState(() {});
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300, // เลื่อนซ้าย 200 หน่วย
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300, // เลื่อนขวา 200 หน่วย
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Color? _getColor(
    String Device_Type,
    String switch_ID,
    String key_state,
  ) {
    final lightRegex = RegExp(r'^light(_\d+)?$');
    final hdlRegex = RegExp(r'^HDL(_\d+)?$');
    final curRegex = RegExp(r'^curtain(_\d+)?$');
    final plugRegex = RegExp(r'^PLUG(_\d+)?$');
    final dimRegex = RegExp(r'^dim(_\d+)?$');
    // final curstopRegex = RegExp(r'^Curstop(_\d+)?$');

    String compositeKey = _generateCompositeKey(switch_ID, key_state);

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
      return null;
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

  Widget? _getIcon(
    String Device_Type,
    String switch_ID,
    String key_state,
  ) {
    final lightRegex = RegExp(r'^light(_\d+)?$');
    final hdlRegex = RegExp(r'^HDL(_\d+)?$');
    final curRegex = RegExp(r'^curtain(_\d+)?$');
    final plugRegex = RegExp(r'^PLUG(_\d+)?$');
    final dimRegex = RegExp(r'^dim(_\d+)?$');
    // final curstopRegex = RegExp(r'^Curstop(_\d+)?$');
    String compositeKey = _generateCompositeKey(switch_ID, key_state);

    if (lightRegex.hasMatch(Device_Type)) {
      return Icon(
        Icons.lightbulb_rounded,
        color:
            _isIconPressed[compositeKey] ?? false ? Colors.white : Colors.black,
        size: 32.0,
      );
    }
    if (hdlRegex.hasMatch(Device_Type)) {
      return Icon(
        Icons.dew_point,
        color:
            _isIconPressed[compositeKey] ?? false ? Colors.white : Colors.black,
        size: 32.0,
      );
    }
    if (curRegex.hasMatch(Device_Type)) {
      // ใช้ compositeKey
      return null;
    }
    if (plugRegex.hasMatch(Device_Type)) {
      return Icon(
        Icons.power,
        color:
            _isIconPressed[compositeKey] ?? false ? Colors.white : Colors.black,
        size: 32.0,
      );
    }
    if (dimRegex.hasMatch(Device_Type)) {
      return Icon(
        Icons.light_mode,
        color:
            _isIconPressed[compositeKey] ?? false ? Colors.white : Colors.black,
        size: 32.0,
      );
    }

    return null;
  }

  Future<void> _Selectstate(
    String switch_ID,
    String key_state,
    String selectedValue,
  ) async {
    String compositeKey = _generateCompositeKey(switch_ID, key_state);

    setState(() {
      print('switch_ID : $switch_ID');
      print('key_state : $key_state');
      print('value_state : $selectedValue');

      _isIconPressed[compositeKey] = !(_isIconPressed[compositeKey] ?? false);

      // สร้างข้อมูลที่จะเพิ่มลงใน List
      Map<String, String> sceneData = {
        'switch_ID': switch_ID,
        'key_state': key_state,
        'value_state': selectedValue,
      };

      // ตรวจสอบว่าข้อมูลนี้มีอยู่ใน List หรือไม่
      bool exists = sceneSwitchList.any((item) =>
          item['switch_ID'] == switch_ID && item['key_state'] == key_state);

      if (exists) {
        // ถ้ามีข้อมูลอยู่แล้ว ให้ทำการอัปเดตข้อมูล
        int index = sceneSwitchList.indexWhere((item) =>
            item['switch_ID'] == switch_ID && item['key_state'] == key_state);
        sceneSwitchList[index] = sceneData;
      } else {
        // ถ้ายังไม่มีข้อมูล ให้เพิ่มข้อมูลใหม่เข้าไป
        sceneSwitchList.add(sceneData);
      }

      print('Updated sceneSwitchList: $sceneSwitchList');
    });
  }

  List<Widget> _buildscene(
      List<Map<String, dynamic>> rooms, Function updateDialogState) {
    List<Widget> widgets = [];

    for (var device in rooms) {
      if (device.containsKey('left') && device.containsKey('top')) {
        double left = double.tryParse(device['left'].toString()) ?? 0.0;
        double top = double.tryParse(device['top'].toString()) ?? 0.0;

        String keyState1 = device['key_state_1'] ?? '';
        String switchID = device['switch_ID'] ?? '';
        String compositeKey = _generateCompositeKey(switchID, keyState1);

        widgets.add(
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () {
                bool isCheckList = sceneSwitchList.any((item) =>
                    item.containsKey('switch_ID') &&
                    item['switch_ID'] == switchID &&
                    item['key_state'] == keyState1);

                if (isCheckList) {
                  setState(() {
                    sceneSwitchList.removeWhere((item) =>
                        item.containsKey('switch_ID') &&
                        item['switch_ID'] == switchID &&
                        item['key_state'] == keyState1);

                    _isIconPressed[compositeKey] =
                        !(_isIconPressed[compositeKey] ?? false);
                    print('l : $sceneSwitchList');
                  });
                  updateDialogState();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Container(
                              width: 280,
                              height: 220,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        topLeft: Radius.circular(20),
                                      ),
                                      color: Color.fromARGB(255, 234, 202, 164),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Select state',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Text('ON'),
                                          leading: Radio(
                                            value: 'ON',
                                            activeColor: Colors.green,
                                            groupValue: _selectedValue,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _selectedValue = value!;
                                              });
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          title: Text('OFF'),
                                          leading: Radio(
                                            value: 'OFF',
                                            groupValue: _selectedValue,
                                            activeColor: Colors.green,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _selectedValue = value!;
                                              });
                                            },
                                          ),
                                        ),
                                        Spacer(),
                                        Row(
                                          children: [
                                            SizedBox(width: 30),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                fixedSize: Size(100, 40),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Spacer(),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _Selectstate(
                                                  device['switch_ID'] ?? '',
                                                  device['key_state_1'] ?? '',
                                                  _selectedValue,
                                                );
                                                updateDialogState();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey.shade500,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    (20),
                                                  ),
                                                ),
                                                fixedSize: Size(100, 40),
                                              ),
                                              child: Text(
                                                'Save',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(width: 30),
                                          ],
                                        ),
                                        SizedBox(height: 10)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
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
                  _getIcon(device['Device_Type'], device['switch_ID'],
                          device['key_state_1']) ??
                      SizedBox()
                ],
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  String _getImageForRoomType(String roomType) {
    if (grouproom.containsKey(roomType)) {
      List<Map<String, dynamic>> rooms = grouproom[roomType] ?? [];

      for (var room in rooms) {
        if (room.containsKey('image_room') && room['image_room'] != null) {
          return 'http://${Constants.IPAddress}:5050/images/${room['image_room']}';
        }
      }
    }

    return 'http://${Constants.IPAddress}:5050/images/default.jpg';
  }

  // String _getImageForRoomType(String roomType) {
  //   if (roomType.startsWith('bedroom')) {
  //     return 'images/bedroom.jpg';
  //   } else if (roomType.startsWith('kitchen')) {
  //     return 'images/kitchenroom.jpg';
  //   } else if (roomType.startsWith('livingroom')) {
  //     return 'images/livingroom.jpg';
  //   } else if (roomType.startsWith('bathroom')) {
  //     return 'images/bathroom.jpg';
  //   } else if (roomType.startsWith('toilet')) {
  //     return 'images/toilet.jpg';
  //   } else {
  //     return 'images/default.jpg';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  sceneSwitchList.clear();
                  print('Exit : $sceneSwitchList');
                  Navigator.pop(context);
                }),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(left: 50, bottom: 22),
            title: Text(
              'Scene switch',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: Container(
        width: 400,
        color: Color.fromARGB(255, 234, 202, 164),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Container(
                    width: 365,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Future.delayed(Duration(milliseconds: 500), () {
                              // Delay 500 milliseconds before executing the function
                              _scrollLeft();
                            });
                          },
                          child: Container(
                            width: 35,
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              color: Colors.grey.shade100,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 295,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            physics: NeverScrollableScrollPhysics(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var scene in _Apiscenesw())
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50.0),
                                    child: scene,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Future.delayed(Duration(milliseconds: 500), () {
                              // Delay 500 milliseconds before executing the function
                              _scrollRight();
                            });
                          },
                          child: Container(
                            width: 35,
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              color: Colors.grey.shade100,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: isSettingscene ? 0 : 280,
              child: Container(
                height: 723,
                width: 395,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.grey.shade100,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Container(
                      width: 300,
                      height: 70,
                      color: Colors.grey.shade100,
                      child: FlutterCarousel(
                        items: switchonetwo,
                        options: CarouselOptions(
                          height: 70.0,
                          autoPlay: false,
                          enlargeCenterPage: true,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.4,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;

                              _getscenedata(sceneData);
                            });
                          },
                          physics: isSettingscene
                              ? NeverScrollableScrollPhysics()
                              : BouncingScrollPhysics(),
                          enableInfiniteScroll: true,
                          showIndicator: false,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_up,
                      size: 50,
                      color: Colors.grey.shade600,
                    ),
                    Container(
                      height: 50,
                      color: Colors.grey.shade400,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 20),
                          Text(
                            'Setting scene',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSettingscene = true;
                                });
                              },
                              child: isSettingscene
                                  ? SizedBox()
                                  : Icon(Icons.settings_outlined, size: 25)),
                          isSettingscene
                              ? Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSettingscene = false;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.grey.shade100,
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.grey.shade800)),
                                        width: 80,
                                        height: 40,
                                        child: Center(
                                          child: Text(
                                            'Cencel',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade800),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        _submitscene();
                                        setState(() {
                                          isSettingscene = false;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.grey.shade700,
                                        ),
                                        width: 80,
                                        height: 40,
                                        child: Center(
                                          child: Text(
                                            'Save',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade300),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          isSettingscene
                              ? SizedBox(width: 10)
                              : SizedBox(
                                  width: 30,
                                )
                        ],
                      ),
                    ),
                    SizedBox(height: 0),
                    Container(
                      height: isSettingscene ? 540 : 260,
                      width: 395,
                      color: Colors.grey.shade200,
                      child: ListView.builder(
                        itemCount: grouproom.length,
                        itemBuilder: (context, index) {
                          String roomType = grouproom.keys.elementAt(index);
                          List<Map<String, dynamic>> rooms =
                              grouproom[roomType] ?? [];

                          String displayName;
                          if (rooms.isNotEmpty &&
                              rooms.first.containsKey('customize_name') &&
                              rooms.first['customize_name'] != null) {
                            displayName = rooms.first['customize_name'];
                          } else {
                            displayName = roomType;
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

                          Icon _getIconForDevice(String deviceType) {
                            if (deviceType == 'light') {
                              return Icon(Icons.lightbulb_outline,
                                  color: Colors.yellow);
                            } else if (deviceType == 'dim') {
                              return Icon(Icons.light_mode,
                                  color: Colors.yellow);
                            } else if (deviceType == 'HDL') {
                              return Icon(Icons.thermostat,
                                  color: Colors.purple);
                            } else if (deviceType == 'PLUG') {
                              return Icon(
                                Icons.power_outlined,
                                color: Colors.green,
                              );
                            } else {
                              return Icon(Icons.device_unknown,
                                  color: Colors.grey);
                            }
                          }

                          return Container(
                            width: 350,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade300,
                            ),
                            margin: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(_getImageForRoomType(
                                            roomType)), // ใช้ฟังก์ชันเพื่อกำหนดรูปภาพ
                                        fit: BoxFit
                                            .cover, // ปรับขนาดของรูปภาพให้พอดีกับ container
                                      ),
                                      color: Colors.white),
                                ),
                                SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      displayName,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      width: 210,
                                      height: 60,
                                      color: Colors.grey.shade300,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            // ตรวจสอบข้อมูลใน sceneSwitchList และ rooms
                                            ...sceneSwitchList
                                                .where((sceneSwitch) {
                                              // ตรวจสอบข้อมูลใน rooms
                                              final hasMatchingRoom =
                                                  rooms.any((room) {
                                                return room['switch_ID'] ==
                                                        sceneSwitch[
                                                            'switch_ID'] &&
                                                    room['key_state_1'] ==
                                                        sceneSwitch[
                                                            'key_state'];
                                              });

                                              return hasMatchingRoom;
                                            }).map((sceneSwitch) {
                                              // หาประเภทของอุปกรณ์จาก room ที่ตรงกัน
                                              final matchedRoom =
                                                  rooms.firstWhere(
                                                      (room) =>
                                                          room['switch_ID'] ==
                                                              sceneSwitch[
                                                                  'switch_ID'] &&
                                                          room['key_state_1'] ==
                                                              sceneSwitch[
                                                                  'key_state'],
                                                      orElse: () => {});

                                              if (matchedRoom == false) {
                                                // ถ้าไม่มี room ที่ตรงกัน
                                                return Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 5, 5, 0),
                                                  width: 120,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'No control devices',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }

                                              final valueState =
                                                  sceneSwitchList.firstWhere(
                                                (s) =>
                                                    s['switch_ID'] ==
                                                        sceneSwitch[
                                                            'switch_ID'] &&
                                                    s['key_state'] ==
                                                        sceneSwitch[
                                                            'key_state'],
                                                orElse: () =>
                                                    {'value_state': 'Unknown'},
                                              )['value_state'];

                                              return Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 5, 5, 0),
                                                width: 65,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.white,
                                                ),
                                                child: Row(
                                                  children: [
                                                    _getIconForDevice(
                                                        matchedRoom[
                                                            'Device_Type']),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      valueState,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // ถ้าไม่มี room ที่ตรงกัน
                                  ],
                                ),
                                Spacer(),
                                isSettingscene
                                    ? AnimatedContainer(
                                        duration: Duration(milliseconds: 500),
                                        width: 60,
                                        height: 100,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                            ),
                                            color: Colors.white),
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              _showdialogscene(
                                                  context, roomType, rooms);
                                            },
                                            child: Icon(
                                              Icons.settings_outlined,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox()
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showdialogscene(
      BuildContext context, String roomType, List<Map<String, dynamic>> rooms) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              void updateDialogState() {
                setState(() {});
              }

              return Container(
                width: 100,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 400,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        color: Color.fromARGB(255, 234, 202, 164),
                      ),
                      child: Center(
                        child: Text(
                          'Select device',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Image.network(
                          _getImageForRoomType(roomType),
                          fit: BoxFit.contain,
                          height: 300,
                          width: 225,
                        ),
                        ..._buildscene(rooms, updateDialogState)
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            width: 280,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20)),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.black,
                                    width: 0.2,
                                  ),
                                  right: BorderSide(
                                    color: Colors.black,
                                    width: 0.2,
                                  ),
                                )),
                            child: Center(
                              child: Text(
                                'SAVE',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
