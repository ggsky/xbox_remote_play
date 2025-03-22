import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xbox_remote_play/config.dart';
import 'package:xbox_remote_play/data_channels/input_channel.dart';
import 'package:xbox_remote_play/key_code.dart';

import 'xbox/x_cloud_api.dart';
import 'xbox/x_cloud_client.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (args.length > 0) {
    var _args = args.join(' ').split('--');
    for (var arg in _args) {
      //debugPrint(arg);
      var kv = arg.trim().split(' ');
      if (kv[0] == "user") {
        Config.UserIndex = int.parse(kv[1].trim());
      } else if (kv[0] == "width") {
        Config.Width = double.parse(kv[1].trim());
      } else if (kv[0] == "height") {
        Config.Height = double.parse(kv[1].trim());
      } else if (kv[0] == "request_width") {
        Config.RequestWIdth = int.parse(kv[1].trim());
      } else if (kv[0] == "request_height") {
        Config.RequestHeight = int.parse(kv[1].trim());
      } else if (kv[0] == "quality") {
        var quality = double.parse(kv[1].trim());
        Config.Quality = quality == 1
            ? FilterQuality.low
            : quality == 2
                ? FilterQuality.medium
                : quality == 3
                    ? FilterQuality.high
                    : FilterQuality.none;
      }
    }
  }

  // WindowOptions windowOptions = WindowOptions(
  //   size: Size(Config.Width, Config.Height),
  //   center: true,
  //   title: Config.UserIndex != 999 ? "窗口_${Config.UserIndex}" : "xbox远程游玩",
  //   backgroundColor: Colors.transparent,
  //   skipTaskbar: false,
  //   titleBarStyle: TitleBarStyle.normal,
  // );
  //
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {}

    return MaterialApp(
      title: 'xbox远程游玩',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  RTCVideoRenderer videoRenderer = RTCVideoRenderer();
  String hintText = "初始化";
  bool firstFrameRenderered = false;

  XCloudClient xCloudClient = XCloudClient();
  late XCloundApi xCloundApi;
  late String userToken;
  late String wlToken;
  late InputChannel inputChannel;
  late String workingDirectory;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    videoRenderer.initialize();
    videoRenderer.onFirstFrameRendered = () {
      setState(() => firstFrameRenderered = true);
    };
    initialize();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    xCloudClient.close();
    super.onWindowClose();
  }

  void initialize() async {
    if (await xboxAuth()) {
      startStreaming();
    } else {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text("异常"),
                content: const Text("认证失败, 程序退出!"),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        exit(0);
                      },
                      child: const Text("确认"))
                ]);
          });
    }
  }

  Future<bool> xboxAuth() async {
    if (kDebugMode) {
      workingDirectory =
          "${Directory.current.path}\\build\\windows\\runner\\Debug";
    } else {
      workingDirectory = Directory.current.path;
    }

    var tokensPath =
        "${workingDirectory}\\auth\\user_${Config.UserIndex}\\tokens.json";

    await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
    try {
      {
        var file = File(tokensPath);
        if (await file.exists()) {
          if (await RequestToken(file)) {
            return true;
          } else {
            file.delete();
          }
        }
      }

      var userDir =
          Directory("${workingDirectory}\\auth\\user_${Config.UserIndex}\\");
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }
      var authExePath = File(
          "${workingDirectory}\\auth\\user_${Config.UserIndex}\\auth-webview.exe");
      if (!await authExePath.exists()) {
        var localAuthExePath =
            File("${workingDirectory}\\auth\\auth-webview.exe");
        var localCryptoLibPath =
            File("${workingDirectory}\\auth\\libcrypto-3-x64.dll");
        var localSSlLibPath =
            File("${workingDirectory}\\auth\\libssl-3-x64.dll");
        await localAuthExePath.copy(
            "${workingDirectory}\\auth\\user_${Config.UserIndex}\\auth-webview.exe");
        await localCryptoLibPath.copy(
            "${workingDirectory}\\auth\\user_${Config.UserIndex}\\libcrypto-3-x64.dll");
        await localSSlLibPath.copy(
            "${workingDirectory}\\auth\\user_${Config.UserIndex}\\libssl-3-x64.dll");
      }

      var result = Process.runSync(
          "${workingDirectory}\\auth\\user_${Config.UserIndex}\\auth-webview.exe",
          ["tokens_file_path=${tokensPath}"],
          workingDirectory:
              "${workingDirectory}\\auth\\user_${Config.UserIndex}");

      if (result.exitCode == 0) {
        var tokenFile = File(tokensPath);
        if (await tokenFile.exists()) {
          if (await RequestToken(tokenFile)) {
            return true;
          } else {
            tokenFile.delete();
          }
        }
      }
    } catch (ex) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text("异常"),
                content: Text(ex.toString()),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        exit(0);
                      },
                      child: const Text("确认"))
                ]);
          });
    }
    return false;
  }

  RequestToken(File file) async {
    if (await file.exists()) {
      Map<String, dynamic> tokens = json.decode(await file.readAsString());
      if (tokens.containsKey("gssv_token")) {
        var userToken =
            await XCloundApi.getUserToken(tokens["gssv_token"]["Token"]);
        var wlToken = tokens["wl_token"]["access_token"];
        if (userToken != null) {
          this.userToken = userToken;
          this.wlToken = wlToken;
          return true;
        }
      }
    }
    return false;
  }

  bool isConnected = false;

  void startStreaming() async {
    try {
      xCloundApi = XCloundApi(userToken, wlToken);
      await xCloudClient.initialize();
      xCloudClient.onAddStream = (stream) {
        videoRenderer.srcObject = stream;
      };

      xCloudClient.onConnectionState = (state) async {
        debugPrint("onConnectionState: ${state}");
        if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
          isConnected = true;
        } else if (state ==
            RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
            state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
          isConnected = false;
          await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text("异常"),
                    content: Text("串流关闭: ${state}!"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            xCloudClient.close();
                            exit(0);
                          },
                          child: const Text("确认"))
                    ]);
              });
        }
      };

      var devices = await xCloundApi.getDevices();

      if (devices == null || devices!.length == 0) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: const Text("异常"),
                  content: const Text("设备列表为空, 请检查后重试, 程序退出!"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          exit(0);
                        },
                        child: const Text("确认"))
                  ]);
            });
      } else {
        setState(() => hintText = "发起会话");
        var sessionState =
            await xCloundApi.startSession(devices[0]["serverId"]);
        if (sessionState == null || sessionState["state"] != "Provisioned") {
          await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text("异常"),
                    content: Text(
                        "会话失败: ${(sessionState != null ? json.encode(sessionState) : "error")}!"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            exit(0);
                          },
                          child: const Text("确认"))
                    ]);
              });
        } else {
          setState(() => hintText = "第一次握手");
          var offer = await xCloudClient.createOffer();
          var sendSdpResponse = await xCloundApi.sendSdp(offer.sdp!);
          if (sendSdpResponse["status"] == "success") {
            setState(() => hintText = "第二次握手");
            xCloudClient.setRemoteOffer(sendSdpResponse["sdp"]);
            var iceCandidates = xCloudClient.iceCandidates;
            List<dynamic> iceList = [];
            for (var candidate in iceCandidates) {
              iceList.add(candidate.toMap());
            }
            var icce = json.encode(iceList);
            var sendIceResponse = await xCloundApi.sendIce(icce);
            if (sendIceResponse != null) {
              setState(() => hintText = "第三次握手");
              for (var candidate in sendIceResponse) {
                if (candidate["candidate"] != "a=end-of-candidates") {
                  // await showDialog(
                  //     context: context,
                  //     builder: (context) {
                  //       return AlertDialog(
                  //           title: Text("Ip地址"),
                  //           content: Text(candidate["candidate"]),
                  //           actions: <Widget>[
                  //             TextButton(
                  //                 onPressed: () {
                  //                   Navigator.pop(context);
                  //                 },
                  //                 child: Text("确认"))
                  //           ]);
                  //     });

                  await xCloudClient.pc.addCandidate(RTCIceCandidate(
                      candidate["candidate"],
                      candidate["sdpMid"],
                      int.parse(candidate["sdpMLineIndex"]!)));
                }
              }
              inputChannel =
                  xCloudClient.getLocalChannel("input") as InputChannel;
              setState(() => hintText = "握手成功");

              Future(() async {
                while (true) {
                  xCloundApi.KeepAlive();
                  await Future.delayed(const Duration(milliseconds: 30000));
                  return isConnected;
                }
              });
            }
          }
        }
      }
    } catch (e) {
      //debugPrint("throw: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event.data is RawKeyEventDataWindows) {
            RawKeyEventDataWindows data = event.data as RawKeyEventDataWindows;
            if (data.keyCode == Keycode.f12) {
              windowManager.close();
            } else {
              inputChannel.onKey(data.keyCode, event is RawKeyDownEvent);
            }
          }
        },
        child: Stack(children: <Widget>[
          SizedBox(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(color: Colors.black87),
              child: RTCVideoView(videoRenderer, filterQuality: Config.Quality),
            ),
          ),
        ]),
      ),
    );
  }
}
