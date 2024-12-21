import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password_manager_uts_pb/common/Encryption.dart';
import 'package:password_manager_uts_pb/database/db_helper.dart';
import 'package:password_manager_uts_pb/models/password.dart';

class PasswordScreen extends StatefulWidget {
  final int userId;
  PasswordScreen({required this.userId});

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  List<Password> _password = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> result = await db.query(
      'passwords',
      where: 'userId = ?',
      whereArgs: [widget.userId],
    );
    setState(() {
      _password = result.map((map) => Password.fromMap(map)).toList();
    });
  }

  Future<void> _addOrEditPassword({Password? password}) async {
    final titleController = TextEditingController(text: password != null ? password.title : '');
    final usernameController = TextEditingController(text: password != null ? password.username : '');
    EncryptionKey encryptionKey = EncryptionKey(
        key: usernameController.text
    );
    final passwordController = TextEditingController(text: password != null ? Encryption.decryptText(password.password, encryptionKey) : '');
    bool passwordVisibleDialog = false;

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(password == null? 'Add New Password' : 'Edit Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
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
                  const SizedBox(height: 20,),
                  Text(password != null ? 'Encrypted Password: ${password.password}' : '')
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final db = await DBHelper().database;
                    EncryptionKey encryptionKey = EncryptionKey(
                        key: usernameController.text
                    );
                    if(password == null){
                      await db.insert(
                          'passwords',
                          {
                            'userId': widget.userId,
                            'title': titleController.text,
                            'username': usernameController.text,
                            'password': Encryption.encryptText(passwordController.text, encryptionKey),
                          }
                      );
                    } else {
                      await db.update(
                        'passwords',
                        {
                          'title': titleController.text,
                          'username': usernameController.text,
                          'password': Encryption.encryptText(passwordController.text, encryptionKey),
                        },
                        where: 'id = ? AND userId = ?',
                        whereArgs: [password.id, widget.userId],
                      );
                    }
                    Navigator.pop(context);
                    _loadPasswords();
                  },
                  child: Text(password == null ? 'Add' : 'Save'),
                )
              ],
            ),
        )
    );
  }

  Future<void> _deletePassword(Password password) async {
    final db = await DBHelper().database;
    await db.delete(
        'passwords',
        where: 'id = ? and userId = ?',
        whereArgs: [password.id, widget.userId],
    );
    _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Password'),),
      body: ListView.builder(
        itemCount: _password.length,
        itemBuilder: (context, index) {
          final password = _password[index];
          return ListTile(
            title: Text(password.title),
            subtitle: Text(password.username),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () => _addOrEditPassword(password: password),
                    icon: Icon(Icons.edit, color: Colors.blue,),
                ),
                IconButton(
                    onPressed: () => _deletePassword(password),
                    icon: Icon(Icons.delete, color: Colors.red,),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditPassword(),
        child: Icon(Icons.add),
      ),
    );
  }
}