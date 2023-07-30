import 'dart:convert';
import 'fetch_anime.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'app_colors.dart';

class RecentWatch {
  final String animeId;
  final String animeName;
  final String animeImage;
  final String episodeId;
  final String server;

  RecentWatch({
    required this.animeId,
    required this.animeName,
    required this.animeImage,
    required this.episodeId,
    required this.server,
  });

  Map<String, dynamic> toJson() {
    return {
      'animeId': animeId,
      'animeName': animeName,
      'animeImage': animeImage,
      'episodeId': episodeId,
      'server': server,
    };
  }

  factory RecentWatch.fromJson(Map<String, dynamic> json) {
    return RecentWatch(
      animeId: json['animeId'],
      animeName: json['animeName'],
      animeImage: json['animeImage'],
      episodeId: json['episodeId'],
      server: json['server'],
    );
  }
}

Future<List<RecentWatch>> readRecentWatches() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/recent.json');

    if (file.existsSync()) {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => RecentWatch.fromJson(json)).toList();
    }
  } catch (e) {
    print('Error reading recent watch file: $e');
  }

  return [];
}

Future<void> writeRecentWatch(String animeId, String animeName,
    String animeImage, String episodeId, String server) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/recent.json');

    List<RecentWatch> recentWatches = [];
    if (file.existsSync()) {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      recentWatches =
          jsonList.map((json) => RecentWatch.fromJson(json)).toList();
    }

    // Remove the existing entry with the same animeId
    recentWatches.removeWhere((rw) => rw.animeId == animeId);

    // Append the new entry
    recentWatches.add(RecentWatch(
      animeId: animeId,
      animeName: animeName,
      animeImage: animeImage,
      episodeId: episodeId,
      server: server,
    ));

    final jsonString =
        json.encode(recentWatches.map((rw) => rw.toJson()).toList());
    await file.writeAsString(jsonString, flush: true);
  } catch (e) {
    print('Error writing recent watch file: $e');
  }
}

void updateRecentWatch(String animeId, String episodeId) async {
  final recentWatches = await readRecentWatches();

  final existingWatchIndex =
      recentWatches.indexWhere((rw) => rw.animeId == animeId);

  if (existingWatchIndex != -1) {
    String name = recentWatches[existingWatchIndex].animeName;
    String id = recentWatches[existingWatchIndex].animeId;
    String img = recentWatches[existingWatchIndex].animeImage;
    String server = recentWatches[existingWatchIndex].server;
    writeRecentWatch(id, name, img, episodeId, server);
  }
}

Future<void> removeRecentWatch(String animeId) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/recent.json');

    if (file.existsSync()) {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      List<RecentWatch> recentWatches =
          jsonList.map((json) => RecentWatch.fromJson(json)).toList();

      // Remove the entry with the specified animeId
      recentWatches.removeWhere((rw) => rw.animeId == animeId);

      final updatedJsonString =
          json.encode(recentWatches.map((rw) => rw.toJson()).toList());
      await file.writeAsString(updatedJsonString, flush: true);
    }
  } catch (e) {
    print('Error removing recent watch: $e');
  }
}

class RecentWatchPage extends StatefulWidget {
  const RecentWatchPage({super.key});

  @override
  State<RecentWatchPage> createState() => _RecentWatchPageState();
}

class _RecentWatchPageState extends State<RecentWatchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: color_2,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Watch History", style: TextStyle(color: color_1)),
        backgroundColor: Colors.black.withOpacity(0),
      ),
      body: FutureBuilder<List<RecentWatch>>(
        future: readRecentWatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Your Watch History will appear here!'),
            );
          }

          final watachData = snapshot.data!.reversed.toList();

          return ListView.builder(
            itemCount: watachData.length,
            itemBuilder: (context, index) {
              final history = watachData[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: Image.network(history.animeImage),
                  title: Text(history.animeName),
                  subtitle: Text(
                      'Episode ${history.episodeId.split('episode-').last}'),
                  tileColor: color_3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  trailing: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            openAnime(context, history.animeId);
                          },
                          icon: const Icon(Icons.info_outline_rounded)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          final animeId = history.animeId;
                          removeRecentWatch(animeId).then((_) {
                            setState(() {
                              watachData.removeAt(index);
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    watchEpisode(context, history.episodeId, history.server,
                        history.animeId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
