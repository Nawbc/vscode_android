import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'config_model.dart';
import 'constant.dart';
import 'droid_pty.dart';

class VscPage extends StatefulWidget {
  const VscPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VscPageState();
  }
}

class _VscPageState extends State<VscPage> {
  VSDroidPty? _pty;
  late ConfigModel _cm;
  late bool _init;

  @override
  void initState() {
    super.initState();
    _init = false;
  }

  @override
  void dispose() {
    super.dispose();
    _pty?.kill();
    WakelockPlus.disable();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _cm = Provider.of<ConfigModel>(context);
    if (!await WakelockPlus.enabled) {
      WakelockPlus.enable();
    }

    if (!_init) {
      _pty = VSDroidPty(
        _cm.termuxUsr.path,
      );
      await _pty?.startCodeServer(
        name: _cm.currentRootfsId!,
      );

      if (mounted) {
        setState(() {
          _init = true;
        });
      }
      // _pty = await launchCodeServerStage(_cm.termuxUsr.path, _cm.currentRootfsId!);
    }
  }

  KeyEventResult handleKeyEvent(node, event) {
    // Allow webview to handle cursor keys. Without this, the
    // arrow keys seem to get "eaten" by Flutter and therefore
    // never reach the webview.
    // (https://github.com/flutter/flutter/issues/102505).
    print("========================");
    if ({
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown
    }.contains(event.logicalKey)) {
      return KeyEventResult.skipRemainingHandlers;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   color: Colors.white,
    // );
    return Focus(
      onKey: handleKeyEvent,
      child: SafeArea(
        child: _init
            ? InAppWebView(
                initialSettings: InAppWebViewSettings(
                    useHybridComposition: true, iframeAllowFullscreen: true, hardwareAcceleration: true),
                initialUrlRequest: URLRequest(
                  url: WebUri(LOCAL_CODE_SERVER_URL),
                ),
              )
            : Container(
                color: Colors.white,
              ),
      ),
    );
  }
}
