import 'dart:io';
import 'package:assignment/screens/phone.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/progess.dart';
import 'home.dart';

class UploadForm extends StatefulWidget {
  File? videoFile;
  String videoPath;
  UploadForm({required this.videoFile, required this.videoPath});

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  VideoPlayerController? playerController;
  bool isUploading = false;
  TextEditingController locationController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  String postId = const Uuid().v4();

  @override
  void initState() {
    super.initState();

    setState(() {
      playerController = VideoPlayerController.file(widget.videoFile!);
    });
    playerController!.initialize();
    playerController!.play();
    playerController!.setVolume(2.0);
    playerController!.setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    playerController!.dispose();
  }

  clearVideo() {
    setState(() {
      playerController!.dispose();
      widget.videoPath = '';
      widget.videoFile = null;
      Navigator.pop(context);
    });
  }

  getUserLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      String address = '${placemark.locality}, ${placemark.country}';
      setState(() {
        locationController.text = address;
      });
    }
  }

  createPost() async {
    setState(() {
      isUploading = true;
    });

    String mediaUrl = await uploadVideo(widget.videoFile);
    postRef.doc(MyPhone.phoneNumber).collection('userPost').doc(postId).set({
      'videoTitle': titleController.text,
      'videoDescription': descriptionController.text,
      'videoCategory': categoryController.text,
      'location': locationController.text,
      'mediaUrl': mediaUrl,
      'timestamp': dateTime,
    });
    locationController.clear();
    titleController.clear();
    descriptionController.clear();
    categoryController.clear();
    setState(() {
      isUploading = false;
      postId = const Uuid().v4();
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Video Uploaded Successfully')));
    Navigator.pop(context);
  }

  Future<String> uploadVideo(videoFile) async {
    UploadTask uploadTask =
        storageRef.child('post_$postId.mp4').putFile(videoFile);

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caption Video'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: clearVideo,
        ),
        actions: [
          TextButton(
              onPressed: createPost,
              child: const Text(
                'Post',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            isUploading ? linearProgress() : const Text(''),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              height: MediaQuery.of(context).size.height * 0.55,
              //width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              child: VideoPlayer(playerController!),
            ),
            const SizedBox(
              height: 20.0,
            ),
            ListTile(
              leading: const Icon(
                Icons.title_rounded,
                size: 32.0,
                color: Colors.orange,
              ),
              title: SizedBox(
                width: 250,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: "Video Title",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.description,
                size: 32.0,
                color: Colors.orange,
              ),
              title: SizedBox(
                width: 250,
                child: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: "Video Description",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.category_outlined,
                size: 32.0,
                color: Colors.orange,
              ),
              title: SizedBox(
                width: 250,
                child: TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    hintText: "Video Category",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.pin_drop,
                size: 32.0,
                color: Colors.orange,
              ),
              title: SizedBox(
                width: 250,
                child: TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    hintText: "Where was this video taken?",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 50.0,
                width: 220.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                  onPressed: getUserLocation,
                  label: const Text(
                    'Use my current location',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
