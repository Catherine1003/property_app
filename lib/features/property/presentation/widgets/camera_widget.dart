import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MobileCameraCapturePage extends StatelessWidget {
  final Function(String path) onCaptured;

  const MobileCameraCapturePage({super.key, required this.onCaptured});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.camera);

      if (img != null) {
        onCaptured(img.path);
      }

      if (context.mounted) Navigator.pop(context);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class WebCameraCapturePage extends StatefulWidget {
  final Function(Uint8List bytes) onCaptured;

  const WebCameraCapturePage({super.key, required this.onCaptured});

  @override
  State<WebCameraCapturePage> createState() => _WebCameraCapturePageState();
}

class _WebCameraCapturePageState extends State<WebCameraCapturePage> {
  CameraController? controller;
  Uint8List? capturedBytes;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Webcam")),
      body: controller == null || !controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: capturedBytes == null
                ? CameraPreview(controller!)
                : Image.memory(capturedBytes!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (capturedBytes == null)
                ElevatedButton(
                  onPressed: () async {
                    final file = await controller!.takePicture();
                    final bytes = await file.readAsBytes();
                    setState(() => capturedBytes = bytes);
                  },
                  child: const Text("Capture"),
                )
              else ...[
                TextButton(
                  onPressed: () => setState(() => capturedBytes = null),
                  child: const Text("Retake"),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onCaptured(capturedBytes!);
                    Navigator.pop(context);
                  },
                  child: const Text("Use Image"),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}