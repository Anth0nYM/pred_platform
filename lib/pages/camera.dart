import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pred_platform/pages/video_list.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;
  List<String> _videos = [];

  @override
  void initState() {
    _initCamera();
    _loadVideos();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(
      back,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController.initialize();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videos.add(file.path);
      });
      _saveVideos();
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _saveVideos() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/videos.json');
    final jsonString = jsonEncode(_videos);
    await file.writeAsString(jsonString);
  }

  Future<void> _loadVideos() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/videos.json');

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      setState(() {
        _videos = List<String>.from(jsonDecode(jsonString));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera Page'),
          actions: [
            IconButton(
              icon: const Icon(Icons.video_library),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideosListScreen(videos: _videos, onDelete: _onDelete)),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CameraPreview(_cameraController),
              Padding(
                padding: const EdgeInsets.all(25),
                child: FloatingActionButton(
                  backgroundColor: _isRecording ? Colors.red : Colors.grey,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.circle,
                    color: _isRecording ? Colors.white : Colors.black,
                  ),
                  onPressed: () => _recordVideo(),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _onDelete(int index) {
    setState(() {
      _videos.removeAt(index);
    });
    _saveVideos();
  }
}
