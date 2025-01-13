class User {
  final String username;
  final String email;
  final String password;

  User({required this.username,required this.email,required this.password});

  factory User.fromJson(Map<String,dynamic> json) {
    return User(username: json["username."], email: json["email"], password: json["password"]);
    
  }
}