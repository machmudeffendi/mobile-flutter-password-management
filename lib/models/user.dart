class User {
  int? id;
  String username;
  String password;
  String fullname;
  User({this.id, required this.username, required this.password, required this.fullname});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullname': fullname,
    };
  }
  factory User.fromMap(Map<String, dynamic> map){
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      fullname: map['fullname'],
    );
  }
}