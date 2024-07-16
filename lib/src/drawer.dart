import 'package:apex_dart/src/controllers/apex_controller.dart';
import 'package:apex_dart/src/renderer/index.html.dart';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class ApexDart extends StatefulWidget {
  const ApexDart({
    super.key,
    required this.options,
    this.controller,
    this.onPageStarted,
    this.onPageFinished,
    this.width = 800,
    this.height = 400,
  });

  final String options;
  final ApexController? controller;
  final double width;
  final double height;

  /// Callback for when the page starts loading.
  final ValueChanged<String>? onPageStarted;

  /// Callback for when the page has finished loading (i.e. is shown on screen).
  final ValueChanged<String>? onPageFinished;

  @override
  State<ApexDart> createState() => _ApexDartState();
}

class _ApexDartState extends State<ApexDart> {
  late final ApexController controller;

  @override
  void initState() {
    super.initState();

    // if (widget.controller != null && widget.controller!.initialized) {
    //   throw FlutterError(
    //     "ApexDart: You cannot use the same controller for multiple charts."
    //   );
    // }

    controller = widget.controller ?? ApexController();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return WebViewX(
          initialContent: render(widget.options),
          initialSourceType: SourceType.html,
          onWebViewCreated: (controller) => this.controller.init(controller),
          onPageFinished: (src) {
            widget.onPageFinished?.call(src);
          },
          onPageStarted: (src) {
            widget.onPageStarted?.call(src);
          },
          height: widget.height,
          width: widget.width,
        );
      },
    );
  }
}
