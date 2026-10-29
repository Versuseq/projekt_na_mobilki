import 'package:objectbox/objectbox.dart';

@Entity()
class TravelLog {
  @Id()
  int id;

  String title;
  String description;

  @Property(type: PropertyType.date)
  DateTime date;

  String? location;
  String? imagePath;
  String userId;

  double? latitude;
  double? longitude;

  TravelLog({
    this.id = 0,
    required this.title,
    required this.description,
    required this.date,
    this.location,
    this.imagePath,
    required this.userId,
    this.latitude,
    this.longitude,
  });
}