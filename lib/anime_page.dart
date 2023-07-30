import 'dart:ui';
import 'anime_home.dart';
import 'app_colors.dart';
import 'fetch_anime.dart';
import 'recent_watch.dart';
import 'package:flutter/material.dart';
import 'bookmark.dart';

class AnimePage extends StatefulWidget {
  final String animeId;

  const AnimePage({Key? key, required this.animeId}) : super(key: key);

  @override
  State<AnimePage> createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  late Future<AnimeData> futureAnimeData;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    futureAnimeData = getAnimeInfo(widget.animeId);
    checkBookmarkStatus();
  }

  Future<void> checkBookmarkStatus() async {
    final bookmarked = await checkAnimeExistence(widget.animeId);
    setState(() {
      isBookmarked = bookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_2,
      body: FutureBuilder(
        future: futureAnimeData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                iconTheme: const IconThemeData(color: color_1),
                centerTitle: false,
                expandedHeight: 450,
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () async {
                        if (!isBookmarked) {
                          var animeData = snapshot.data!;
                          await writeBookmark(animeData.id, animeData.title,
                              animeData.url, animeData.image, context);
                        }
                        checkBookmarkStatus();
                      },
                      icon: isBookmarked
                          ? const Icon(
                              Icons.bookmark,
                              color: color_1,
                            )
                          : const Icon(
                              Icons.bookmark_border,
                              color: color_1,
                            ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Cover(imgUrl: snapshot.data!.image),
                  expandedTitleScale: 1,
                  titlePadding:
                      const EdgeInsetsDirectional.fromSTEB(25, 50, 0, 16),
                  title: Text(
                    snapshot.data!.title,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  const AnimeHeadingText(
                    text: 'Other Name:',
                  ),
                  AnimeSubHeadingText(
                    text: snapshot.data!.otherName,
                    size: 12,
                  ),
                  const AnimeHeadingText(text: 'Genre:'),
                  AnimeSubHeadingText(
                    text: snapshot.data!.genres.length >= 5
                        ? snapshot.data!.genres.join('•')
                        : snapshot.data!.genres.join('•'),
                    size: 12,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AnimeHeadingText(
                        text: 'Release Date:',
                      ),
                      AnimeSubHeadingText(
                        text: snapshot.data!.releaseDate,
                        size: 14,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AnimeHeadingText(
                        text: 'Status:',
                      ),
                      AnimeSubHeadingText(
                        text: snapshot.data!.status,
                        size: 14,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AnimeHeadingText(
                        text: 'Total Episodes:',
                      ),
                      AnimeSubHeadingText(
                        text: snapshot.data!.totalEpisodes.toString(),
                        size: 14,
                      ),
                    ],
                  ),
                  const AnimeHeadingText(
                    text: 'Description:',
                  ),
                  AnimeSubHeadingText(
                    text: snapshot.data!.description,
                    size: 12,
                  ),
                  const AnimeHeadingText(text: 'Episodes'),
                ]),
              ),
              EpisodeList(data: snapshot.data!)
            ]);
          } else if (snapshot.hasError) {
            return Text("Something Wrong!\n ${snapshot.error}");
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class EpisodeList extends StatelessWidget {
  final AnimeData data;
  const EpisodeList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(childCount: data.episodes.length,
            (context, index) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: color_3,
          onTap: () => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    "Servers",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: color_1, fontSize: 18),
                  ),
                  backgroundColor: color_3,
                  actionsPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  actions: [
                    ElevatedButton(
                        onPressed: () async {
                          await writeRecentWatch(data.id, data.title,
                              data.image, data.episodes[index].id, 'gogocdn');
                          watchEpisode(context, data.episodes[index].id,
                              'gogocdn', data.id);
                        },
                        child: const Text(
                          "GogoServer",
                          style: TextStyle(color: color_4),
                        )),
                    ElevatedButton(
                        onPressed: () async {
                          await writeRecentWatch(
                              data.id,
                              data.title,
                              data.image,
                              data.episodes[index].id,
                              'vidstreaming');
                          watchEpisode(context, data.episodes[index].id,
                              'vidstreaming', data.id);
                        },
                        child: const Text("Vidstreaming",
                            style: TextStyle(color: color_4))),
                  ],
                );
              }),
          title: Text('Episode ${data.episodes[index].number.toString()}'),
        ),
      );
    }));
  }
}

class AnimeSubHeadingText extends StatelessWidget {
  const AnimeSubHeadingText(
      {super.key, required this.text, required this.size});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Text(
        text,
        style: TextStyle(fontSize: size, color: Colors.white54),
        softWrap: true,
      ),
    );
  }
}

class AnimeHeadingText extends StatelessWidget {
  const AnimeHeadingText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8, 0, 0),
      child: Text(text, style: const TextStyle(fontSize: 18, color: color_1)),
    );
  }
}

class Cover extends StatelessWidget {
  const Cover({
    super.key,
    required this.imgUrl,
  });

  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(imgUrl,
            height: 500,
            width: MediaQuery.of(context).size.width,
            filterQuality: FilterQuality.medium,
            fit: BoxFit.cover),
        BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(color: Colors.black.withOpacity(0))),
        const TopGradient(gradientLength: 0.25),
        const BottomGradient(),
        Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            children: [
              Card(
                  elevation: 28,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      width: 200,
                      height: 300,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
