//appointment.dart

class Appointment {
  final String name;
  final String service;
  final DateTime dateTime;
  final double earnings;

  Appointment({
    required this.name,
    required this.service,
    required this.dateTime,
    this.earnings = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'service': service,
        'dateTime': dateTime.toIso8601String(),
        'earnings': earnings,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        name: json['name'] as String? ?? '',
        service: json['service'] as String? ?? '',
        dateTime: DateTime.parse(json['dateTime'] as String),
        earnings: (json['earnings'] is num ? (json['earnings'] as num).toDouble() : 0.0),
      );
}