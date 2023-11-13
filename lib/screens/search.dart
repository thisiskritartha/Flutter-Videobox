import 'package:assignment/screens/home.dart';
import 'package:assignment/screens/phone.dart';
import 'package:assignment/widgets/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/video.dart';
import '../widgets/progess.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<QuerySnapshot>? searchResultFuture;
  TextEditingController textEditingController = TextEditingController();

  handleSearch(String query) {
    Future<QuerySnapshot> videos = postRef
        .doc(MyPhone.phoneNumber)
        .collection('userPost')
        .where("videoTitle", isGreaterThanOrEqualTo: query)
        .get();
    setState(() {
      searchResultFuture = videos;
    });
  }

  clearSearch() {
    textEditingController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: "Search for videos with Video Title...",
          filled: true,
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Center(
        child: Text(
      'Find Videos',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.deepPurple[300],
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        fontSize: 60,
        letterSpacing: 1.8,
      ),
    ));
  }

  buildSearchResult() {
    return FutureBuilder(
        future: searchResultFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }

          List<VideoResult> searchResults = [];
          for (var doc in snapshot.data!.docs) {
            Video video = Video.fromDocument(doc);
            VideoResult searchResult = VideoResult(video);
            searchResults.add(searchResult);
          }

          return ListView(
            children: searchResults,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: searchResultFuture == null ? buildNoContent() : buildSearchResult(),
    );
  }
}

class VideoResult extends StatelessWidget {
  final Video video;
  const VideoResult(this.video, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Post(video: video)),
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
            ),
          ),
          const Divider(
            height: 2.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
