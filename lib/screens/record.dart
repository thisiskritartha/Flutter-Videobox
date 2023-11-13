import 'dart:io';
import 'package:assignment/screens/upload_form.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class RecordVideo extends StatefulWidget {
  const RecordVideo({Key? key}) : super(key: key);

  @override
  State<RecordVideo> createState() => _RecordVideoState();
}

class _RecordVideoState extends State<RecordVideo> {
  VideoPlayerController? videoPlayerController;
  openCamera() async {
    final XFile? videoFile =
        await ImagePicker().pickVideo(source: ImageSource.camera);
    if (videoFile != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadForm(
                videoFile: File(videoFile.path), videoPath: videoFile.path),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Videos'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: openCamera,
              icon: Icon(
                Icons.camera_alt,
                size: 50.0,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Tap on camera to start recording the videos.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
