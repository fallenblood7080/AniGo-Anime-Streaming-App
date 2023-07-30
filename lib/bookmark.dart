import 'dart:convert';
import 'dart:io';
import 'app_colors.dart';
import 'fetch_anime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class BookmarkAnimeData {
  final String id;
  final String title;
  final String url;
  final String image;

  BookmarkAnimeData({
    required this.id,
    required this.title,
    required this.url,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'image': image,
    };
  }

  factory BookmarkAnimeData.fromJson(Map<String, dynamic> json) {
    return BookmarkAnimeData(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      image: json['image'],
    );
  }
}

Future<void> writeBookmark(String id, String title, String url, String image,
    BuildContext context) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/bookmarks.json');

  List<Map<String, dynamic>> bookmarks = [];
  if (file.existsSync()) {
    final jsonString = file.readAsStringSync();
    final List<dynamic> jsonList = json.decode(jsonString);
    bookmarks = jsonList.cast<Map<String, dynamic>>();
  }

  final bookmark = {
    'id': id,
    'title': title,
    'url': url,
    'image': image,
  };

  bookmarks.add(bookmark);

  final jsonString = json.encode(bookmarks);

  file.writeAsStringSync(jsonString, flush: true);
  String name = title.length > 30 ? '${title.substring(0, 30)}...' : title;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      "$name! Bookmarked!",
      style: const TextStyle(color: color_1),
    ),
    backgroundColor: color_3,
  ));
}

Future<List<Map<String, dynamic>>> readBookmarks() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/bookmarks.json');

  if (file.existsSync()) {
    final jsonString = await file.readAsString();
    final jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  return [];
}

Future<bool> checkAnimeExistence(String animeId) async {
  final bookmarks = await readBookmarks();

  return bookmarks.any((bookmark) => bookmark['id'] == animeId);
}

Future<void> removeBookmark(String animeId) async {
  final bookmarks = await readBookmarks();

  final updatedBookmarks =
      bookmarks.where((bookmark) => bookmark['id'] != animeId).toList();

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/bookmarks.json');

  final jsonString = json.encode(updatedBookmarks);
  await file.writeAsString(jsonString, flush: true);
}

class BookMarkPage extends StatefulWidget {
  const BookMarkPage({super.key});

  @override
  State<BookMarkPage> createState() => _BookMarkPageState();
}

class _BookMarkPageState extends State<BookMarkPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: color_2,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Bookmarks", style: TextStyle(color: color_1)),
        backgroundColor: Colors.black.withOpacity(0),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: readBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading bookmarks'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No bookmarks available'),
            );
          }

          final bookmarks = snapshot.data!;

          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: Image.network(bookmark['image']),
                  title: Text(bookmark['title']),
                  tileColor: color_3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      final animeId = bookmark['id'];
                      removeBookmark(animeId).then((_) {
                        setState(() {
                          bookmarks.removeAt(index);
                        });
                      });
                    },
                  ),
                  onTap: () {
                    openAnime(context, bookmark['id']);
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
