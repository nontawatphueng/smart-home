import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myhome/IPaddress.dart';
import 'package:myhome/homepage_1.dart';

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final TextEditingController _home = TextEditingController();
  final TextEditingController _people = TextEditingController();
  final TextEditingController _receipt = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _obscureText = true;
  String? _errorText;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _validatePasswords() async {
    setState(() {
      if (_home.text.isEmpty ||
          _people.text.isEmpty ||
          _receipt.text.isEmpty ||
          _email.text.isEmpty ||
          _password.text.isEmpty ||
          _confirm.text.isEmpty) {
        _errorText = 'All fields must be filled';
      } else if (_password.text != _confirm.text) {
        _errorText = 'Passwords do not match';
      } else {
        _errorText = null;
      }
    });
    if (_errorText == null) {
      await _updatePassword(
          _home.text, _people.text, _receipt.text, _email.text, _confirm.text);
    }
  }

  Future<void> _updatePassword(String homeNo, String peopleId,
      String receiptNumber, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://${Constants.IPAddress}:5050/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Home_No': homeNo,
          'People_ID': peopleId,
          'Receipt_number': receiptNumber,
          'email': email,
          'password': password
        }),
      );
      if (response.statusCode == 200) {
        print(
          'Response from server: ${response.body}',
        );
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${response.body}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 700),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            HomePage(),
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
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        print('Failed to send request: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${response.statusCode}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('$e'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(left: 50, bottom: 22),
            title: Text(
              'Setting Password',
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
        child: Container(
          width: 400,
          height: 722,
          padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 60,
                ),
                SizedBox(height: 40),
                CustomTextField(
                  label: 'Home Number',
                  controller: _home,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  label: 'Personal Identity',
                  controller: _people,
                  isPassword: false,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  label: 'Receipt Number',
                  controller: _receipt,
                  isPassword: false,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  label: 'Email',
                  controller: _email,
                  isPassword: false,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  label: 'Password',
                  controller: _password,
                  isPassword: true,
                  obscureText: _obscureText,
                  onSuffixIconPressed: _togglePasswordVisibility,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  label: 'Confirm Password',
                  controller: _confirm,
                  isPassword: true,
                  obscureText: _obscureText,
                  onSuffixIconPressed: _togglePasswordVisibility,
                ),
                if (_errorText != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorText!,
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 165,
                        height: 45,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(width: 0.5, color: Colors.black),
                            color: Colors.white),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: _validatePasswords,
                      child: Container(
                        width: 165,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromARGB(255, 234, 202, 164),
                        ),
                        child: Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
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
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onSuffixIconPressed;
  const CustomTextField({
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.onSuffixIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.5)),
        ),
        SizedBox(height: 8),
        Container(
          width: 340,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade100,
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscureText : false,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black,
                      ),
                      onPressed: onSuffixIconPressed,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
