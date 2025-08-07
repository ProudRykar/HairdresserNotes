class Client {
  final String name;
  final String? phone;
  final String? telegramId;

  Client({required this.name, this.phone, this.telegramId});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'] as String,
      phone: json['phone'] as String?,
      telegramId: json['telegram_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'telegram_id': telegramId ?? '',
    };
  }
}