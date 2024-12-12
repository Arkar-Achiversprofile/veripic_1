import 'dart:developer' as prefix;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:veripic_1/camera_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // late List<CameraDescription> _cameras;
  // late CameraController _controller;
  final CameraService _cameraService = CameraService();

  @override
  void initState() {
    super.initState();
    // _requestPermissions();
    initializeCamera();
  }

  // Future<void> _requestPermissions() async {
  //   // Request camera permission
  //   var cameraStatus = await Permission.camera.request();

  //   // Request storage permission
  //   var storageStatus = await Permission.storage.request();

  //   if (cameraStatus.isGranted && storageStatus.isGranted) {
  //     initializeCamera();
  //   } else {
  //     prefix.log("Permission denied!");
  //   }
  // }

  Future<void> initializeCamera() async {
    await _cameraService.initializeCamera();
    // _cameras = await availableCameras();
    // _controller = CameraController(_cameras[0], ResolutionPreset.medium);
    // await _controller.initialize();
    setState(() {});
  }

  Future<void> captureAndSaveImage() async {
    try {
      XFile picture = await _cameraService.controller!.takePicture();
      File imageFile = File(picture.path);
      // final exif = await Exif.fromPath(picture.path);
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image != null) {
        // String hash = generatePerceptualHash(image);
        // prefix.log(hash);

        img.JpegEncoder encoder = img.JpegEncoder(quality: 100);
        // await exif.writeAttribute('VeriKey', hash);
        // image.exif = {'VeriKey': hash}

        final directory = await getTemporaryDirectory();
        String path = '${directory.path}/veripic_hashed.jpg';
        File hashedImageFile = File(path)
          ..writeAsBytesSync(encoder.encode(image));

        await ImageGallerySaverPlus.saveFile(hashedImageFile.path);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved with pHash')));
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  String generatePerceptualHash(img.Image image) {
    img.Image resized = img.copyResize(image, width: 32, height: 32);
    img.Image grayscale = img.grayscale(resized);
    List<int> dctValues = performDCT(grayscale);
    int median = dctValues.reduce((a, b) => a + b) ~/ dctValues.length;
    return dctValues.map((v) => v > median ? '1' : '0').join();
  }

  List<int> performDCT(img.Image image) {
    List<int> pixels = image.getBytes().buffer.asUint8List();
    List<double> dctCoefficients = List.filled(64, 0.0);

    for (int u = 0; u < 8; u++) {
      for (int v = 0; v < 8; v++) {
        double sum = 0.0;
        for (int x = 0; x < 8; x++) {
          for (int y = 0; y < 8; y++) {
            double pixelValue = pixels[y * image.width + x].toDouble();
            sum += pixelValue *
                cos((2 * x + 1) * u * pi / 16) *
                cos((2 * y + 1) * v * pi / 16);
          }
        }
        double coefficient =
            sum * (u == 0 ? 1 / sqrt(2) : 1) * (v == 0 ? 1 / sqrt(2) : 1);
        dctCoefficients[u * 8 + v] = coefficient;
      }
    }

    return dctCoefficients.map((e) => e.round()).toList();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VeriPic')),
      body: Column(
        children: [
          Expanded(
              child: _cameraService.controller == null ||
                      !_cameraService.controller!.value.isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : CameraPreview(_cameraService.controller!)),
          ElevatedButton(
            onPressed: captureAndSaveImage,
            child: const Text('Capture and Hash Image'),
          ),
        ],
      ),
    );
  }
}
