class Password{
  int? id;
  String title;
  String username;
  String password;
  Password({this.id, required this.title, required this.username, required this.password});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
    };
  }
  factory Password.fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      password: map['password'],
    );
  }
}