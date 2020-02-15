import 'package:dio/dio.dart';

import 'movie.dart';

class MyServices {
  Future search(String movie) async {
    if (movie.isEmpty) {
      return '';
    } else {
      try {
        List<Movie> list = List();
        Response response = await Dio().get("http://www.omdbapi.com/?apikey=bae1b13e&t=" + movie);
        list.add(Movie.fromJson(response.data));
        return list;
      } catch (e) {
        print(e);
      }
    }
  }
}
