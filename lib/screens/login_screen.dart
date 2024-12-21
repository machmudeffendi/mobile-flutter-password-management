import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password_manager_uts_pb/common/Encryption.dart';
import 'package:password_manager_uts_pb/database/db_helper.dart';
import 'package:password_manager_uts_pb/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool passwordVisible = false;

  Future<void> _register() async {
    final usernameController = TextEditingController();
    final fullnameController = TextEditingController();
    final passwordController = TextEditingController();
    bool passwordVisibleDialog = false;

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Create Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: fullnameController,
                  decoration: InputDecoration(labelText: 'Fullname'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              passwordVisibleDialog = !passwordVisibleDialog;
                            });
                          },
                          icon: Icon(passwordVisibleDialog ? Icons.visibility : Icons.visibility_off),
                      )
                  ),
                  obscureText: !passwordVisibleDialog,
                ),
              ],
            ),
            actions: [
              TextButton( onPressed: () => Navigator.pop(context), child: Text('Cancel'),),
              ElevatedButton(
                onPressed: () async {
                  if(usernameController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      fullnameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Required field cannot be empty!')),
                    );
                    return;
                  }
                  final db = await DBHelper().database;
                  EncryptionKey encryptionKey = EncryptionKey(
                      key: usernameController.text
                  );
                  try{
                    await db.insert('users', {
                      'username': usernameController.text,
                      'password': Encryption.encryptText(passwordController.text, encryptionKey),
                      'fullname': fullnameController.text,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User registered successfully!')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registration failed: Username might already exist!')),
                    );
                  }
                },
                child: Text('Save'),
              )
            ],
        ),
      )
    );
  }

  Future<void> _login() async {
    if(_usernameController.text.isEmpty || _passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    final db = await DBHelper().database;
    EncryptionKey encryptionKey = EncryptionKey(
      key: _usernameController.text
    );
    final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [_usernameController.text, Encryption.encryptText(_passwordController.text, encryptionKey)]
    );
    if(result.isNotEmpty){
      final userId = result.first['id'] as int;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userId: userId))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password'))
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login/Register'),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                    icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                  )
              ),
              obscureText: !passwordVisible,
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            TextButton(onPressed: _register, child: Text('Crete Account'))
          ],
        ),
      ),
    );
  }
}