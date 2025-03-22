import "dart:convert";
import "package:http/http.dart" as http;

class XCloundApiV2 {
  String token;
  String WlToken;
  late String sessionPath;

  XCloundApiV2(this.token, this.WlToken);

  static getUserToken(String gssvToken) async {

  }

  getDevices() async {

  }

  startSession(String serverId) async {

  }

  Future isProvisioningReady(String url, {int retries = 0}) async {

  }

  isExchangeReady(String url, {int retries = 0}) async {

  }

  sendSdp(String sdp) async {
    var body = {
      "messageType": "offer",
      "sdp": sdp,
      "configuration": {
        "chatConfiguration": {
          "bytesPerSample": 2,
          "expectedClipDurationMs": 20,
          "format": {"codec": "opus", "container": "webm"},
          "numChannels": 1,
          "sampleFrequencyHz": 24000
        },
        "chat": {"minVersion": 1, "maxVersion": 1},
        "control": {"minVersion": 1, "maxVersion": 3},
        "input": {"minVersion": 1, "maxVersion": 7},
        "message": {"minVersion": 1, "maxVersion": 1},
      }
    };

    var response = await http.post(
        Uri.parse(
            "https://uks.gssv-play-prodxhome.xboxlive.com/$sessionPath/sdp"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body));

    //debugPrint("XCloudApi sendSdp() Status: ${response.statusCode}");
    if (response.statusCode == 202) {
      //debugPrint("XCloudApi sendSdp() body: ${response.body}");
      var exchangeReady = await isExchangeReady("sdp");
      if (exchangeReady != null) {
        //debugPrint("Loop done? resolve now...");
        return exchangeReady["exchangeResponse"];
      }
    }
    return null;
  }

  sendIce(String ice) async {
    var body = {"messageType": "iceCandidate", "candidate": ice};

    var response = await http.post(
        Uri.parse(
            "https://uks.gssv-play-prodxhome.xboxlive.com/$sessionPath/ice"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body));

    //debugPrint("XCloudApi sendIce() Status: ${response.statusCode}");
    if (response.statusCode == 202) {
      //debugPrint("XCloudApi sendIce() body: ${response.body}");
      var exchangeReady = await isExchangeReady("ice");
      if (exchangeReady != null) {
        //debugPrint("Loop done? resolve now...");
        return exchangeReady["exchangeResponse"];
      }
    }
    return null;
  }

  xcloudAuth() async {
    var body = {"userToken": WlToken};

    var response = await http.post(
        Uri.parse(
            "https://uks.gssv-play-prodxhome.xboxlive.com/$sessionPath/connect"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body));

    //debugPrint("XCloudApi xcloudAuth() Status: ${response.statusCode}");
    if (response.statusCode == 200 || response.statusCode == 202) {
      //debugPrint("XCloudApi sendIce() body: ${response.body}");
      return true;
    }
    return false;
  }

  KeepAlive() async {
    try {
      var response = await http.post(
          Uri.parse(
              "https://uks.gssv-play-prodxhome.xboxlive.com/$sessionPath/keepalive"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: json.encode(""));

      //debugPrint("XCloudApi KeepAlive() Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        //debugPrint("XCloudApi KeepAlive() body: ${response.body}");
        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }
}
