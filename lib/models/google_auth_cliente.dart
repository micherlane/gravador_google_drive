import 'package:http/http.dart' as http;

class GoogleAuthCliente extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = http.Client();
  GoogleAuthCliente(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
