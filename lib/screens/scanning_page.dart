// import 'dart:typed_data'; // Ensure this is imported
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
//
// class ScanningPage extends StatefulWidget {
//   const ScanningPage({super.key});
//
//   @override
//   _ScanningPageState createState() => _ScanningPageState();
// }
//
// class _ScanningPageState extends State<ScanningPage> {
//   late CameraController _cameraController;
//   late Future<void> _initializeControllerFuture;
//   final _imageLabeler = GoogleMlKit.vision.imageLabeler();
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }
//
//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final firstCamera = cameras.first;
//
//       _cameraController = CameraController(
//         firstCamera,
//         ResolutionPreset.high,
//       );
//
//       _initializeControllerFuture = _cameraController.initialize();
//       _cameraController.startImageStream((CameraImage image) async {
//         if (image == null) return;
//         await _processImage(image);
//       });
//     } catch (e) {
//       print('Error initializing camera: $e');
//     }
//   }
//
//   Future<void> _processImage(CameraImage image) async {
//     final inputImage = _convertCameraImageToInputImage(image);
//     final labels = await _imageLabeler.processImage(inputImage);
//
//     // Display the labels
//     for (var label in labels) {
//       print('${label.label}, ${label.confidence}');
//     }
//   }
//
//   InputImage _convertCameraImageToInputImage(CameraImage image) {
//     final size = Size(image.width.toDouble(), image.height.toDouble());
//     final inputImageData = InputImageData(
//       size: size,
//       imageRotation: InputImageRotation.rotation0deg,
//       inputImageFormat: InputImageFormat.nv21, // Correct format
//       planeData: image.planes.map((plane) {
//         return InputImagePlaneMetadata(
//           bytesPerRow: plane.bytesPerRow,
//           height: plane.height,
//           width: plane.width,
//         );
//       }).toList(),
//     );
//     final inputImage = InputImage.fromBytes(
//       bytes: _concatenatePlanes(image.planes),
//       inputImageData: inputImageData,
//     );
//     return inputImage;
//   }
//
//   Uint8List _concatenatePlanes(List<Plane> planes) {
//     return planes
//         .map((plane) => plane.bytes)
//         .fold(Uint8List(0), (a, b) => Uint8List.fromList(a + b));
//   }
//
//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _imageLabeler.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scanning Page'),
//       ),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return CameraPreview(_cameraController);
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }
