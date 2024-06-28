import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pred_platform/pages/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideosListScreen extends StatefulWidget {
  final List<String> videos;
  final Function(int) onDelete;

  const VideosListScreen(
      {Key? key, required this.videos, required this.onDelete})
      : super(key: key);

  @override
  _VideosListScreenPageState createState() => _VideosListScreenPageState();
}

class _VideosListScreenPageState extends State<VideosListScreen> {

   Map<int, Color> uploadStatusColors = {};

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

  Future<void> _renameVideo(int index) async {
    final oldPath = widget.videos[index];
    final directory = Directory(oldPath).parent;

    final TextEditingController controller = TextEditingController();

    String newName = '';

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Video'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New Name'),
            onChanged: (value) {
              newName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Rename'),
              onPressed: () {
                Navigator.of(context).pop(
                    newName); // Passa o newName de volta ao fechar a caixa de diálogo.
              },
            ),
          ],
        );
      },
    );

    if (newName.isNotEmpty) {
      final newPath = '${directory.path}/$newName.mp4';
      final newFile = await File(oldPath).rename(newPath);

      setState(() {
        widget.videos[index] = newFile.path;
      });
    }
  }

  Future<void> _uploadVideo(int index, String videoPath) async {
    // final uri = Uri.parse('https://api.exemplo.com/upload');
    // final request = http.MultipartRequest('POST', uri)
    //   ..files.add(await http.MultipartFile.fromPath('video', videoPath));

    const response = 1;
    if (response == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video enviado com sucesso!')),
      );
      setState(() {
        uploadStatusColors[index] = Colors.green;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao enviar o vídeo.')),
      );
      setState(() {
        uploadStatusColors[index] = Colors.red;
      });
    }
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
                  leading: snapshot.hasData
                      ? Image.file(File(snapshot.data!))
                      : const Icon(Icons.videocam),
                  title: Text('Animal ${index + 1}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _renameVideo(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          widget.onDelete(index);
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.cloud_upload, color: uploadStatusColors[index] ?? Colors.grey),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enviando vídeo...')),
                          );
                          _uploadVideo(index, widget.videos[index]);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(videoPath: widget.videos[index]),
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
