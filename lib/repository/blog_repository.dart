import 'dart:io';
import 'package:http/io_client.dart';
import '../models/blog.dart';

class BlogRepository {
  final String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
  final String adminSecret = '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';

  Future<List<Blog>> fetchBlogs() async {
    final ioc = HttpClient();
    ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final httpClient = IOClient(ioc);

    final response = await httpClient.get(Uri.parse(url), headers: {
      'x-hasura-admin-secret': adminSecret,
    });

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        return Blog.fromJsonList(response.body);
      } catch (e) {
        print('Error parsing response: $e');
        throw Exception('Failed to parse blogs');
      }
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load blogs');
    }
  }
}
