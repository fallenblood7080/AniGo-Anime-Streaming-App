import 'anime_page.dart';
import 'anime_watch.dart';
import 'recent_watch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const String baseUrl = "https://api.consumet.org/" +
    "anime/gogoanime"; // your consument api + anime/gogoanime

//Replace "https://api.consumet.org" this with your consument api

bool hasMoreAnime = true;

void openAnime(BuildContext context, String animeId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AnimePage(
        animeId: animeId,
      ),
    ),
  );
}

void watchEpisode(
    BuildContext context, String epissodeId, String server, String animeid) {
  updateRecentWatch(animeid, epissodeId);
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => StreamAnimeEpisode(
                episodeId: epissodeId,
                server: server,
                selectedQuality: "default",
                animeId: animeid,
              )));
}

void rewatchEpisode(BuildContext context, String epissodeId, String server,
    String quality, String animeid) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => StreamAnimeEpisode(
            episodeId: epissodeId,
            server: server,
            selectedQuality: quality,
            animeId: animeid,
          )));
}

Future<AnimeEpisodeData> fetchAnimeEpisode(
    String episodeId, String server) async {
  final url = '$baseUrl/watch/$episodeId?server=$server';

  try {
    final response = await Dio().get(url);
    final data = response.data;

    return AnimeEpisodeData.fromJson(data);
  } catch (error) {
    print('Error fetching anime episode: $error');
    return AnimeEpisodeData(
      referer: '',
      sources: [],
    );
  }
}

Future<List<RecentAnime>> fetchRecentAnime({int page = 1}) async {
  final response = await Dio().get('$baseUrl/recent-episodes?page=$page');

  final List<dynamic> results = response.data['results'];
  final List<RecentAnime> recentAnime =
      results.map((json) => RecentAnime.fromJson(json)).toList();

  return recentAnime;
}

Future<List<TopAnime>> getTopAnimes({int pageNo = 1}) async {
  try {
    // Make the API request using Dio
    final response = await Dio().get("$baseUrl/top-airing?page=$pageNo");

    // Extract the list of results from the API response
    List<dynamic> jsonList = response.data['results'];

    // Create a list of Anime objects
    List<TopAnime> animeList = jsonList.map((json) {
      return TopAnime(
        id: json['id'],
        title: json['title'],
        image: json['image'],
        url: json['url'],
        genres: List<String>.from(json['genres']),
      );
    }).toList();

    return animeList;
  } catch (error) {
    throw Exception('Failed to fetch anime data: $error');
  }
}

Future<RandomAnime> getRandomAnime() async {
  try {
    final response = await Dio().get("$baseUrl/top-airing");
    List<dynamic> jsonList = response.data['results'];

    // Select a random anime from the list
    int randomIndex = DateTime.now().millisecondsSinceEpoch % jsonList.length;
    Map<String, dynamic> animeJson = jsonList[randomIndex];

    // Create the Anime object
    RandomAnime anime = RandomAnime(
      id: animeJson['id'],
      title: animeJson['title'],
      image: animeJson['image'],
      url: animeJson['url'],
      genres: List<String>.from(animeJson['genres']),
    );

    return anime;
  } catch (error) {
    throw Exception('Failed to fetch anime data: $error');
  }
}

Future<AnimeData> getAnimeInfo(String id) async {
  try {
    // Make the API request using Dio
    final response = await Dio().get("$baseUrl/info/$id");

    // Check the response status
    if (response.statusCode == 200) {
      // Extract the anime data from the response
      final json = response.data;

      // Create an Anime object with the extracted data
      final anime = AnimeData(
        id: json['id'],
        title: json['title'],
        url: json['url'],
        image: json['image'],
        releaseDate: json['releaseDate'],
        description: json['description'],
        genres: List<String>.from(json['genres']),
        subOrDub: json['subOrDub'],
        type: json['type'],
        status: json['status'],
        otherName: json['otherName'],
        totalEpisodes: json['totalEpisodes'],
        episodes: List<Episode>.from(json['episodes'].map((episodeJson) {
          return Episode(
            id: episodeJson['id'],
            number: episodeJson['number'],
            url: episodeJson['url'],
          );
        })),
      );

      return anime;
    } else {
      throw Exception(
          'Failed to fetch anime data. Status Code: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Failed to fetch anime data: $error');
  }
}

Future<List<Map<String, dynamic>>> searchAnime(String query, int page) async {
  final url = '$baseUrl/$query?page=$page';

  try {
    final response = await Dio().get(url);
    final data = response.data;
    hasMoreAnime = response.data['hasNextPage'];
    if (data['results'] != null && data['results'] is List<dynamic>) {
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      return [];
    }
  } catch (error) {
    return [];
  }
}

Future<List<Episode>> fetchEpisodeList(String id) async {
  final url = '$baseUrl/info/$id';

  try {
    final response = await Dio().get(url);
    final data = response.data;

    final List<dynamic> episodesData = data['episodes'];
    final List<Episode> episodes = episodesData.map((episodeData) {
      return Episode(
        id: episodeData['id'],
        number: episodeData['number'],
        url: episodeData['url'],
      );
    }).toList();

    return episodes;
  } catch (error) {
    print('Error fetching episode list: $error');
    return [];
  }
}

class TopAnime {
  final String id;
  final String title;
  final String image;
  final String url;
  final List<String> genres;

  TopAnime({
    required this.id,
    required this.title,
    required this.image,
    required this.url,
    required this.genres,
  });
}

class AnimeData {
  final String id;
  final String title;
  final String url;
  final String image;
  final String releaseDate;
  final String description;
  final List<String> genres;
  final String subOrDub;
  final String type;
  final String status;
  final String otherName;
  final int totalEpisodes;
  final List<Episode> episodes;

  AnimeData({
    required this.id,
    required this.title,
    required this.url,
    required this.image,
    required this.releaseDate,
    required this.description,
    required this.genres,
    required this.subOrDub,
    required this.type,
    required this.status,
    required this.otherName,
    required this.totalEpisodes,
    required this.episodes,
  });
}

class Episode {
  final String id;
  final dynamic number;
  final String url;

  Episode({
    required this.id,
    required this.number,
    required this.url,
  });
}

class RandomAnime {
  final String id;
  final String title;
  final String image;
  final String url;
  final List<String> genres;

  RandomAnime({
    required this.id,
    required this.title,
    required this.image,
    required this.url,
    required this.genres,
  });
}

class RecentAnime {
  final String id;
  final String title;
  final String image;
  final String url;

  RecentAnime({
    required this.id,
    required this.title,
    required this.image,
    required this.url,
  });

  factory RecentAnime.fromJson(Map<String, dynamic> json) {
    return RecentAnime(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      url: json['url'],
    );
  }
}

class AnimeEpisodeData {
  final String referer;
  final List<AnimeEpisodeSource> sources;

  AnimeEpisodeData({
    required this.referer,
    required this.sources,
  });

  factory AnimeEpisodeData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sourceList = json['sources'];
    final List<AnimeEpisodeSource> sources = sourceList
        .map((source) => AnimeEpisodeSource.fromJson(source))
        .toList();

    return AnimeEpisodeData(
      referer: json['headers']['Referer'] as String,
      sources: sources,
    );
  }
}

class AnimeEpisodeSource {
  final String url;
  final String quality;
  final bool isM3U8;

  AnimeEpisodeSource({
    required this.url,
    required this.quality,
    required this.isM3U8,
  });

  factory AnimeEpisodeSource.fromJson(Map<String, dynamic> json) {
    return AnimeEpisodeSource(
      url: json['url'] as String,
      quality: json['quality'] as String,
      isM3U8: json['isM3U8'] as bool,
    );
  }
}
