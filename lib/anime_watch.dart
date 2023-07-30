import 'app_colors.dart';
import 'fetch_anime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'recent_watch.dart';

class StreamAnimeEpisode extends StatefulWidget {
  final String animeId;
  final String episodeId;
  final String server;
  final String selectedQuality;

  const StreamAnimeEpisode(
      {super.key,
      required this.episodeId,
      required this.server,
      required this.selectedQuality,
      required this.animeId});

  @override
  State<StreamAnimeEpisode> createState() => _StreamAnimeEpisodeState();
}

class _StreamAnimeEpisodeState extends State<StreamAnimeEpisode> {
  late Future<AnimeEpisodeData> futureEpisodes;

  List<String> episodeIds = [];
  bool isFirstEpisode = false;
  bool isLastEpisode = false;
  int current = 0;

  String animeName = '';
  String episodeName = '';
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions settings = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
  );
  @override
  void initState() {
    super.initState();
    futureEpisodes = fetchAnimeEpisode(widget.episodeId, widget.server);

    List<String> animeNameSplit = widget.episodeId.split('-');
    episodeName += '${animeNameSplit.removeLast()} ';
    episodeName += animeNameSplit.removeLast();
    episodeName = episodeName.split(' ').reversed.join(' ').trim();
    episodeName =
        episodeName.toString()[0].toUpperCase() + episodeName.substring(1);

    for (var i = 0; i < animeNameSplit.length; i++) {
      if (animeNameSplit[i].isNotEmpty) {
        animeNameSplit[i] =
            animeNameSplit[i][0].toUpperCase() + animeNameSplit[i].substring(1);
      }
    }

    animeName = animeNameSplit.join(' ');
  }

  Future<void> fetechEpisodeids() async {
    final ids = await fetchEpisodeList(widget.animeId);
    setState(() {
      episodeIds = List.generate(ids.length, (index) => ids[index].id);
      current = episodeIds.indexOf(widget.episodeId);
      if (current == 0) {
        isFirstEpisode = true;
      }
      if (current == episodeIds.length - 1) {
        isLastEpisode = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        // ignore: unrelated_type_equality_checks
        title: Text(
          animeName,
          style: const TextStyle(color: color_1),
        ),
        foregroundColor: color_1,
      ),
      body: FutureBuilder(
          future: futureEpisodes,
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              final episodeData = snapshot.data!;
              final sources = episodeData.sources;
              final qualityOptions =
                  sources.map((source) => source.quality).toList();

              final source = sources.firstWhere(
                (source) => source.quality == widget.selectedQuality,
                orElse: () =>
                    AnimeEpisodeSource(url: '', quality: '', isM3U8: true),
              );

              return SingleChildScrollView(
                child: Column(children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    child: InAppWebView(
                      initialOptions: settings,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      initialUrlRequest: URLRequest(
                          url: Uri.parse(source.url),
                          headers: {'Referer': snapshot.data!.referer}),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          episodeName,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 20, color: color_1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.high_quality_rounded,
                              color: color_1),
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                    title: const Text("Quality"),
                                    content: SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.2,
                                      height: 500,
                                      child: ListView.builder(
                                        itemCount: qualityOptions.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(
                                              sources[index].quality,
                                              style: const TextStyle(
                                                  fontSize: 12, color: color_1),
                                            ),
                                            onTap: () {
                                              rewatchEpisode(
                                                  context,
                                                  widget.episodeId,
                                                  widget.server,
                                                  sources[index].quality,
                                                  widget.animeId);
                                            },
                                          );
                                        },
                                      ),
                                    ));
                              }),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 120,
                            height: 50,
                            child: ElevatedButton.icon(
                              label: const Text("Prev"),
                              onPressed: () async {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    "Loading...",
                                    style: TextStyle(color: color_1),
                                  ),
                                  backgroundColor: color_3,
                                ));
                                await fetechEpisodeids();
                                if (!isFirstEpisode) {
                                  updateRecentWatch(
                                      widget.animeId, episodeIds[current - 1]);
                                  rewatchEpisode(
                                      context,
                                      episodeIds[current - 1],
                                      widget.server,
                                      widget.selectedQuality,
                                      widget.animeId);
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                      "This is the First Episode",
                                      style: TextStyle(color: color_1),
                                    ),
                                    backgroundColor: color_3,
                                  ));
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: color_4,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 120,
                            height: 50,
                            child: ElevatedButton.icon(
                                label: const Text("Next"),
                                onPressed: () async {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                      "Loading...",
                                      style: TextStyle(color: color_1),
                                    ),
                                    backgroundColor: color_3,
                                  ));
                                  await fetechEpisodeids();
                                  if (!isLastEpisode) {
                                    updateRecentWatch(widget.animeId,
                                        episodeIds[current + 1]);
                                    rewatchEpisode(
                                        context,
                                        episodeIds[current + 1],
                                        widget.server,
                                        widget.selectedQuality,
                                        widget.animeId);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                        "This is the Last Episode",
                                        style: TextStyle(color: color_1),
                                      ),
                                      backgroundColor: color_3,
                                    ));
                                  }
                                },
                                icon: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: color_4,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            return const Center(child: CircularProgressIndicator());
          })),
    );
  }
}
