import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password_manager_uts_pb/database/db_helper.dart';
import 'package:password_manager_uts_pb/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int userId;
  const ProfileScreen({required this.userId, Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchUserData() async {
    final db = await DBHelper().database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId]
    );
    return result.isNotEmpty ? result.first : {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(),
      builder: (context, snapshoot) {
        if(snapshoot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        }
        if(!snapshoot.hasData || snapshoot.data!.isEmpty){
          return Center(child: Text('User data not found.'),);
        }
        final userData = snapshoot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: Theme.of(context).textTheme.headlineLarge,),
              SizedBox(height: 20,),
              Text('Username: ${userData['username']}'),
              Text('Fullname: ${userData['fullname']}'),
              Text('Encrypted Password: ${userData['password']}'),
              SizedBox(height: 20,),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                    );
                  },
                  child: Text('Logout'))
            ],
          ),
        );
      },
    );
  }
}