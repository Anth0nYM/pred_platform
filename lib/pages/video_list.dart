import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pred_platform/pages/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideosListScreen extends StatefulWidget {
  final List<String> videos;
  final Function(int) onDelete;

  const VideosListScreen({Key? key, required this.videos, required this.onDelete}) : super(key: key);

  @override
  _VideosListScreenPageState createState() => _VideosListScreenPageState();
}

class _VideosListScreenPageState extends State<VideosListScreen> {
  Future<String> _getThumbnail(String videoPath) async {
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 64,
      quality: 75,
    );
    return thumbnail!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Videos'),
      ),
      body: ListView.builder(
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          return FutureBuilder<String>(
            future: _getThumbnail(widget.videos[index]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('Loading...'),
                );
              } else {
                return ListTile(
                  leading: snapshot.hasData ? Image.file(File(snapshot.data!)) : const Icon(Icons.videocam),
                  title: Text('Video ${index + 1}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      widget.onDelete(index);
                      setState(() {});
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(videoPath: widget.videos[index]),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
