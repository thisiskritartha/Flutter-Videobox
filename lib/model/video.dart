import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  late final String location;
  late final String mediaUrl;
  late final Timestamp timestamp;
  late final String videoCategory;
  late final String videoDescription;
  late final String videoTitle;

  Video({
    required this.location,
    required this.mediaUrl,
    required this.timestamp,
    required this.videoCategory,
    required this.videoDescription,
    required this.videoTitle,
  });

  factory Video.fromDocument(DocumentSnapshot doc) {
    return Video(
      location: doc['location'],
      mediaUrl: doc['mediaUrl'],
      timestamp: doc['timestamp'],
      videoCategory: doc['videoCategory'],
      videoDescription: doc['videoDescription'],
      videoTitle: doc['videoTitle'],
    );
  }
}
