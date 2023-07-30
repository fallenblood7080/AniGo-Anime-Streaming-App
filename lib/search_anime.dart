import 'app_colors.dart';
import 'fetch_anime.dart';
import 'package:flutter/material.dart';

class SearchAnimePage extends StatefulWidget {
  const SearchAnimePage({super.key});

  @override
  State<SearchAnimePage> createState() => _SearchAnimePageState();
}

class _SearchAnimePageState extends State<SearchAnimePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _animeList = [];
  int _currentPage = 0;
  bool _hasNextPage = true;

  void _searchAnime(String query) async {
    if (query.isNotEmpty) {
      _currentPage = 1;
      _hasNextPage = hasMoreAnime;
      final animeData = await searchAnime(query, _currentPage);
      setState(() {
        _animeList = animeData;
      });
    }
  }

  Future<void> _loadMoreAnime() async {
    if (_hasNextPage) {
      _currentPage++;
      final animeData = await searchAnime(_searchController.text, _currentPage);
      setState(() {
        _animeList.addAll(animeData);
        _hasNextPage = hasMoreAnime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_2,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            backgroundColor: color_2,
            floating: true,
            pinned: false,
            snap: true,
            centerTitle: true,
            iconTheme: IconThemeData(color: color_1),
            title: Text("Anime Search", style: TextStyle(color: color_1)),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _searchAnime(value);
                },
                decoration: const InputDecoration(
                  fillColor: color_1,
                  hoverColor: color_1,
                  focusColor: color_1,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: color_1),
                      borderRadius: BorderRadius.all(Radius.circular(28))),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: color_3),
                      borderRadius: BorderRadius.all(Radius.circular(28))),
                  hintText: 'Search Anime...',
                ),
              ),
            )
          ])),
          SliverList.builder(
              itemCount: _animeList.isNotEmpty ? _animeList.length + 1 : 1,
              itemBuilder: (context, index) {
                if (index < _animeList.length) {
                  final anime = _animeList[index];
                  return ListTile(
                    leading: Image.network(anime['image']),
                    title: Text(anime['title']),
                    subtitle: Text(anime['releaseDate'] ?? ''),
                    onTap: () => openAnime(context, anime['id']),
                  );
                }
                if (_searchController.text.isEmpty) {
                  return const Center(child: Text("Search Something"));
                } else if (_animeList.isEmpty) {
                  return const Center(child: Text("Nothing!"));
                }
                return null;
              }),
          SliverList(
              delegate: SliverChildListDelegate([
            if (_hasNextPage && _animeList.isNotEmpty)
              SizedBox(
                height: 500,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loadMoreAnime,
                        child: const Text('Load More'),
                      ),
                    ),
                  ),
                ),
              ),
          ])),
        ],
      ),
    );
  }
}
