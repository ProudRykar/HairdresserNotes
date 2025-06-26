class Client {
  final String name;
  final String? phone;

  Client({required this.name, this.phone});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}