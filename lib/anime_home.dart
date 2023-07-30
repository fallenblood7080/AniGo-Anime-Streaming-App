import 'dart:ui';
import 'package:flutter/services.dart';

import 'bookmark.dart';
import 'recent_watch.dart';
import 'search_anime.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'fetch_anime.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Future<RandomAnime> futureRandomAnimeId;
  late Future<List<TopAnime>> futureTopAnimes;
  late Future<List<RecentAnime>> futureRecentAnimes;
  late Future<List<Map<String, dynamic>>> futureBookmarkData;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final List<Widget> _widgetOptions = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(systemNavigationBarColor: color_3));
    });
    futureRandomAnimeId = getRandomAnime();
    futureTopAnimes = getTopAnimes();
    futureRecentAnimes = fetchRecentAnime();
    futureBookmarkData = readBookmarks();
    _widgetOptions.add(
      Home(
          futureRandomAnimeId: futureRandomAnimeId,
          futureTopAnimes: futureTopAnimes,
          futureRecentAnimes: futureRecentAnimes),
    );
    _widgetOptions.add(const SearchAnimePage());
    _widgetOptions.add(const BookMarkPage());
    _widgetOptions.add(const RecentWatchPage());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: color_2,
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: color_3,
          unselectedItemColor: color_4,
          currentIndex: _selectedIndex,
          selectedItemColor: color_1,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.live_tv_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border),
              label: 'Bookmark',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.watch_later_outlined),
              label: 'History',
            ),
          ]),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    super.key,
    required this.futureRandomAnimeId,
    required this.futureTopAnimes,
    required this.futureRecentAnimes,
  });

  final Future<RandomAnime> futureRandomAnimeId;
  final Future<List<TopAnime>> futureTopAnimes;
  final Future<List<RecentAnime>> futureRecentAnimes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_2,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("AniGo", style: TextStyle(color: color_1)),
        backgroundColor: Colors.black.withOpacity(0),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            SizedBox(
                height: 550,
                child: RandomAnimeWigdet(
                    futureRandomAnimeId: futureRandomAnimeId)),
            AnimeColummList(futureFunc: futureTopAnimes, rowName: "Top Animes"),
            const SizedBox(
              height: 10,
            ),
            AnimeColummList(
                futureFunc: futureRecentAnimes, rowName: "New Anime"),
          ],
        ),
      ),
    );
  }
}

class AnimeColummList extends StatelessWidget {
  const AnimeColummList(
      {super.key, required this.futureFunc, required this.rowName});

  final Future<List<dynamic>> futureFunc;
  final String rowName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rowName, style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),
        FutureBuilder(
            future: futureFunc,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 270,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var anime = snapshot.data![index];
                        return AnimeCard(animeData: anime);
                      }),
                );
              } else {
                return const CircularProgressIndicator();
              }
            }),
      ],
    );
  }
}

class AnimeCard extends StatefulWidget {
  const AnimeCard({
    Key? key,
    required this.animeData,
  }) : super(key: key);

  final dynamic animeData;

  @override
  // ignore: library_private_types_in_public_api
  _AnimeCardState createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> {
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    checkBookmarkStatus();
  }

  Future<void> checkBookmarkStatus() async {
    final bookmarked = await checkAnimeExistence(widget.animeData.id);
    setState(() {
      isBookmarked = bookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 270,
      child: InkWell(
        onTap: () => openAnime(context, widget.animeData.id),
        child: Card(
          color: color_3,
          elevation: 28,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  image: DecorationImage(
                    image: NetworkImage(widget.animeData.image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () async {
                      if (!isBookmarked) {
                        await writeBookmark(
                            widget.animeData.id,
                            widget.animeData.title,
                            widget.animeData.url,
                            widget.animeData.image,
                            context);
                      }
                      checkBookmarkStatus();
                    },
                    icon: isBookmarked
                        ? const Icon(
                            Icons.check,
                            color: color_1,
                          )
                        : const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.animeData.title.length > 30
                      ? '${widget.animeData.title.substring(0, 30)}...'
                      : widget.animeData.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RandomAnimeWigdet extends StatelessWidget {
  const RandomAnimeWigdet({
    super.key,
    required this.futureRandomAnimeId,
  });

  final Future<RandomAnime> futureRandomAnimeId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureRandomAnimeId,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Image.network(snapshot.data!.image,
                    height: 525,
                    width: MediaQuery.of(context).size.width,
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover),
                BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(color: Colors.black.withOpacity(0))),
                const TopGradient(gradientLength: 0.25),
                const BottomGradient(),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Card(
                          elevation: 28,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.network(
                              snapshot.data!.image,
                              fit: BoxFit.cover,
                              width: 200,
                              height: 300,
                            ),
                          )),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: FittedBox(
                          child: Text(
                            snapshot.data!.title,
                            overflow: TextOverflow.fade,
                            softWrap: true,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      FilledButton(
                          onPressed: () =>
                              openAnime(context, snapshot.data!.id),
                          child: const Text("Watch")),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                          snapshot.data!.genres.length >= 5
                              ? snapshot.data!.genres.take(5).join('•')
                              : snapshot.data!.genres.join('•'),
                          style: const TextStyle(fontSize: 12))
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(
              child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(),
          ));
        });
  }
}

class BottomGradient extends StatelessWidget {
  const BottomGradient({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.35,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [color_2, Colors.black.withOpacity(0)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter)),
      ),
    );
  }
}

class TopGradient extends StatelessWidget {
  final double gradientLength;
  const TopGradient({super.key, required this.gradientLength});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * gradientLength,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [color_2, Colors.black.withOpacity(0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
      ),
    );
  }
}
