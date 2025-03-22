import 'dart:convert';
import 'channel_base.dart';
import '../xbox/x_cloud_client.dart';

class ControlChannel extends ChannelBase {
  ControlChannel(XCloudClient client, String clientName)
      : super(client, clientName);

  bool isRunning = true;

  Future<void> start() async {
    var keyframeRequest = json.encode({
      'message': 'videoKeyframeRequested',
      'ifrRequested': true,
    });

    var authRequest = json.encode({
      'message': 'authorizationRequest',
      'accessKey': '4BDB3609-C1F1-4195-9B37-FEFF45DA8B8E',
    });

    var gamepadRequest = json.encode({
      'message': 'gamepadChanged',
      'gamepadIndex': 0,
      'wasAdded': true,
    });

    sendMessage(authRequest);
    sendMessage(gamepadRequest);

    Future(() async {
      while (true){
      sendMessage(keyframeRequest);
      await Future.delayed(const Duration(milliseconds: 3000));
      }

    });
  }

  @override
  void onClose() {
    isRunning = false;
    super.onClose();
  }
}
