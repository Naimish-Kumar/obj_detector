import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:obj_detector/details_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';

class ObjectScanner extends StatefulWidget {
  @override
  _ObjectScannerState createState() => _ObjectScannerState();
}

class _ObjectScannerState extends State<ObjectScanner> {
  final ImagePicker _picker = ImagePicker();
  final FlutterTts flutterTts = FlutterTts();
  File? _imageFile;
  String? _objectDetails;
  String _objectName = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _previousDetails = <Map<String, dynamic>>[];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
      );
      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
          _objectDetails = null; // Reset details
        });
        _analyzeImage(_imageFile!);
      }
    }
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text.replaceAll('*', ''));
  }

  Future<void> _analyzeImage(File image) async {
    final imageLabeler =
        ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 1));
    final textRecognizer = TextRecognizer();
    try {
      final inputImage = InputImage.fromFile(image);

      // First try to recognize text
      final recognizedText = await textRecognizer.processImage(inputImage);
      if (recognizedText.text.isNotEmpty) {
        _objectName = recognizedText.text;
      } else {
        // If no text found, fallback to object detection
        final labels = await imageLabeler.processImage(inputImage);
        _objectName = labels.map((label) => label.label).join(", ");
      }

      setState(() {
        _isLoading = true;
      });

      final details = await _getTextDetails(_objectName);
      setState(() {
        _objectDetails = details;
        _isLoading = false;
      });

      if (details != null) {
        _speakText(details);
        _savePreviousDetails(_objectName, details, image);
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      imageLabeler.close();
      textRecognizer.close();
    }
  }

  Future<String?> _getTextDetails(String objectName) async {
    try {
      final prompt =
          "Describe $objectName in detail, focusing on its appearance, common uses, and interesting facts.";
      final response = await getTextDetails(prompt);
      return response?.replaceAll('"', '\\"');
    } catch (e) {
      print('Error generating details: $e');
      return 'Failed to retrieve details.';
    }
  }

  Future<String?> getTextDetails(String prompt) async {
    try {
      final generativeAi = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'AIzaSyANp4e5orVV5calEpa-JWM-JObeZaSIRfI',
      );

      final promptContent = Content.text(prompt);
      final response = await generativeAi.generateContent([promptContent]);
      return response.text;
    } catch (e) {
      print('Error: $e');
      return 'Error occurred during text generation.';
    }
  }

  Future<void> _savePreviousDetails(
      String objectName, String details, File image) async {
    final prefs = await SharedPreferences.getInstance();
    final previousDetails =
        prefs.getStringList('previous_details') ?? <String>[];
    previousDetails.add(
        '{"objectName": "$objectName", "details": "$details", "imagePath": "${image.path}"}');
    prefs.setStringList('previous_details', previousDetails);
    setState(() {
      _previousDetails = previousDetails
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList();
    });
  }

  Future<void> _deletePreviousDetails(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final previousDetails =
        prefs.getStringList('previous_details') ?? <String>[];
    previousDetails.removeAt(index);
    prefs.setStringList('previous_details', previousDetails);
    setState(() {
      _previousDetails = previousDetails
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text('AI Object Scanner',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_imageFile != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _imageFile!,
                        height: 300,
                        width: double.maxFinite,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 25),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    _imageFile != null
                        ? _objectName != ''
                            ? _objectName
                            : 'Object Scanned'
                        : 'No object scanned yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      label: const Text('Camera',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(
                        Icons.photo_library,
                        color: Colors.white,
                      ),
                      label: const Text('Gallery',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                if (_isLoading)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(20),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 200,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_objectDetails != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(20),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'Details: ${_imageFile != null ? _objectDetails : 'No object scanned yet'}',
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                if (_previousDetails.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _previousDetails.length,
                    itemBuilder: (context, index) {
                      final previousDetails = _previousDetails[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(previousDetails['objectName']),
                        subtitle: Text(previousDetails['details']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deletePreviousDetails(index);
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                objectName: previousDetails['objectName'],
                                details: previousDetails['details'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 35),
                if (_objectDetails != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Share.share(_objectDetails ?? '');
                        },
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Share Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(24),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _speakText(_objectDetails ?? '');
                        },
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Read Aloud',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
