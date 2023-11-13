import 'package:assignment/screens/phone.dart';
import 'package:assignment/widgets/post.dart';
import 'package:assignment/widgets/progess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/video.dart';
import 'home.dart';

class ViewVideos extends StatefulWidget {
  const ViewVideos({Key? key}) : super(key: key);

  @override
  State<ViewVideos> createState() => _ViewVideosState();
}

class _ViewVideosState extends State<ViewVideos> {
  Future<QuerySnapshot>? searchResultFuture;

  @override
  void initState() {
    super.initState();
    getVideos();
  }

  getVideos() {
    Future<QuerySnapshot> videos =
        postRef.doc(MyPhone.phoneNumber).collection('userPost').get();
    setState(() {
      searchResultFuture = videos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Videos'),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: searchResultFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            final videoDocs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: videoDocs.length,
              itemBuilder: (context, index) {
                Video video = Video.fromDocument(videoDocs[index]);
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Post(video: video),
                            ),
                          ),
                        },
                        child: ListTile(
                          leading: const Icon(
                            Icons.photo_outlined,
                            size: 40,
                          ),
                          title: Text(
                            video.videoTitle,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            video.videoCategory,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Text('- ${video.videoCategory}'),
                        ),
                      ),
                      const Divider(
                        height: 2.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
