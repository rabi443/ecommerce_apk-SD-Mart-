import 'dart:convert';
import 'package:http/http.dart' as http;
import '../AdModel/AdModel.dart';
import 'package:pp/core/BaseUrl.dart';

class AdService {
  static const String _adUrl = '${BaseUrl.baseurl_api}/discovery/ads';

  static Future<List<AdModel>> fetchAds() async {
    final response = await http.get(Uri.parse(_adUrl));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => AdModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load ads');
    }
  }
}