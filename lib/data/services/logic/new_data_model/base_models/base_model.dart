abstract class BaseModel {
  final String id;
  DateTime createdAt;
  DateTime updatedAt;

  BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson();
  // static BaseModel fromSnapshot(
  //   DocumentSnapshot<Map<String, dynamic>> document,
  // ) {
  //   // Implement the logic to create a BaseModel instance from the document snapshot
  //   throw UnimplementedError('fromSnapshot() has not been implemented.');
  // }
}
