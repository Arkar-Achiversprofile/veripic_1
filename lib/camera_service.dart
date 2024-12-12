import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription>? cameras;

  Future<void> initializeCamera() async {
    // Get a list of available cameras
    cameras = await availableCameras();
    // Initialize the camera controller
    controller = CameraController(
      cameras![0], // Use the first camera
      ResolutionPreset.high,
    );

    // Initialize the controller
    await controller!.initialize();
  }

  Future<void> takePicture() async {
    if (controller!.value.isInitialized) {
      await controller!.takePicture();
    }
  }

  void dispose() {
    controller?.dispose();
  }
}