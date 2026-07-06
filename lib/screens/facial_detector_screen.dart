import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/colors.dart';
import '../l10n/app_localizations.dart';
import '../singleton_class.dart';

enum FaceVerificationStep {
  align,
  lookStraight,
  turnSide1,
  turnSide2,
  captureStraight,
  completed
}

class FacialDetectorScreen extends StatefulWidget {
  const FacialDetectorScreen({super.key});

  @override
  State<FacialDetectorScreen> createState() => _FacialDetectorScreenState();
}

class _FacialDetectorScreenState extends State<FacialDetectorScreen>
    with SingleTickerProviderStateMixin {
  final SingletonClass singletonClass = SingletonClass();
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  bool _isProcessingImage = false;

  FaceVerificationStep _currentStep = FaceVerificationStep.align;
  String _statusMessage = "Align your face in the circle";
  double _progress = 0.0;

  // Sign tracker for turn side verification
  double? _firstTurnSign;
  int _consecutiveFrames = 0;
  static const int requiredFrames = 5;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: false,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _statusMessage = "No cameras found";
        });
        return;
      }

      final frontCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _startProcessingStream();
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = "Camera error: $e";
        });
      }
    }
  }

  void _startProcessingStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting || _isProcessingImage) return;
      _isDetecting = true;

      try {
        final inputImage = _inputImageFromCameraImage(image);
        if (inputImage != null) {
          final List<Face> faces = await _faceDetector.processImage(inputImage);
          if (mounted) {
            _processFaces(faces);
          }
        }
      } catch (e) {
        debugPrint("Error in stream face detection: $e");
      } finally {
        _isDetecting = false;
      }
    });
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final camera = _cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );
    final sensorOrientation = camera.sensorOrientation;

    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  void _processFaces(List<Face> faces) {
    if (faces.isEmpty) {
      _consecutiveFrames = 0;
      setState(() {
        _statusMessage = "No face detected. Please align your face inside the circle";
        if (_currentStep != FaceVerificationStep.align) {
          _progress = 0.0;
          _currentStep = FaceVerificationStep.align;
        }
      });
      return;
    }

    if (faces.length > 1) {
      _consecutiveFrames = 0;
      setState(() {
        _statusMessage = "Multiple faces detected. Please verify alone";
      });
      return;
    }

    final face = faces.first;
    final double? rotY = face.headEulerAngleY; // Left/right turn
    final double? rotZ = face.headEulerAngleZ; // Head tilt
    final double? leftEyeOpen = face.leftEyeOpenProbability;
    final double? rightEyeOpen = face.rightEyeOpenProbability;

    // 1. Immediate closed eyes check
    if (leftEyeOpen != null && leftEyeOpen < 0.45 || rightEyeOpen != null && rightEyeOpen < 0.45) {
      _consecutiveFrames = 0;
      setState(() {
        _statusMessage = "Please open your eyes";
      });
      return;
    }

    // 2. Immediate tilt/orientation check
    if (rotZ != null && rotZ.abs() > 12.0) {
      _consecutiveFrames = 0;
      setState(() {
        _statusMessage = "Please keep your head straight";
      });
      return;
    }

    switch (_currentStep) {
      case FaceVerificationStep.align:
        setState(() {
          _currentStep = FaceVerificationStep.lookStraight;
          _progress = 0.1;
          _consecutiveFrames = 0;
        });
        break;

      case FaceVerificationStep.lookStraight:
        if (rotY != null && rotY.abs() < 8.0) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= requiredFrames) {
            _consecutiveFrames = 0;
            _captureAnglePhoto(FaceVerificationStep.lookStraight);
          } else {
            setState(() {
              _statusMessage = "Hold still...";
            });
          }
        } else {
          _consecutiveFrames = 0;
          setState(() {
            _statusMessage = "Look straight at the camera";
          });
        }
        break;

      case FaceVerificationStep.turnSide1:
        if (rotY != null && rotY.abs() > 14.0) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= requiredFrames) {
            _consecutiveFrames = 0;
            _firstTurnSign = rotY.sign;
            _captureAnglePhoto(FaceVerificationStep.turnSide1);
          } else {
            setState(() {
              _statusMessage = "Keep turning...";
            });
          }
        } else {
          _consecutiveFrames = 0;
          setState(() {
            _statusMessage = "Please look to the left or right";
          });
        }
        break;

      case FaceVerificationStep.turnSide2:
        if (rotY != null && _firstTurnSign != null && rotY.sign != _firstTurnSign && rotY.abs() > 14.0) {
          _consecutiveFrames++;
          if (_consecutiveFrames >= requiredFrames) {
            _consecutiveFrames = 0;
            _captureAnglePhoto(FaceVerificationStep.turnSide2);
          } else {
            setState(() {
              _statusMessage = "Keep turning to the other side...";
            });
          }
        } else {
          _consecutiveFrames = 0;
          setState(() {
            _statusMessage = "Now look to the other side";
          });
        }
        break;

      case FaceVerificationStep.captureStraight:
      case FaceVerificationStep.completed:
        break;
    }
  }

  Future<void> _captureAnglePhoto(FaceVerificationStep step) async {
    if (_cameraController == null || _isProcessingImage) return;

    setState(() {
      _isProcessingImage = true;
      _statusMessage = "Capturing...";
    });

    try {
      await _cameraController!.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 150));
      
      final XFile photo = await _cameraController!.takePicture();
      
      String filename = "";
      String prefKey = "";

      if (step == FaceVerificationStep.lookStraight) {
        filename = "face_straight.jpg";
        prefKey = "face_straight_path";
      } else if (step == FaceVerificationStep.turnSide1) {
        filename = _firstTurnSign! > 0 ? "face_right.jpg" : "face_left.jpg";
        prefKey = _firstTurnSign! > 0 ? "face_right_path" : "face_left_path";
      } else if (step == FaceVerificationStep.turnSide2) {
        filename = _firstTurnSign! > 0 ? "face_left.jpg" : "face_right.jpg";
        prefKey = _firstTurnSign! > 0 ? "face_left_path" : "face_right_path";
      }

      final savedPath = await _cropAndSaveFace(photo.path, filename);

      if (savedPath != null) {
        final prefs = await SharedPreferences.getInstance();
        final employeeId = singletonClass.getJWTModel()?.employeeId ?? '';
        await prefs.setString('${prefKey}_$employeeId', savedPath);
        
        if (step == FaceVerificationStep.lookStraight) {
          setState(() {
            _currentStep = FaceVerificationStep.turnSide1;
            _progress = 0.33;
            _isProcessingImage = false;
          });
          _startProcessingStream();
        } else if (step == FaceVerificationStep.turnSide1) {
          setState(() {
            _currentStep = FaceVerificationStep.turnSide2;
            _progress = 0.66;
            _isProcessingImage = false;
          });
          _startProcessingStream();
        } else if (step == FaceVerificationStep.turnSide2) {
          setState(() {
            _currentStep = FaceVerificationStep.completed;
            _progress = 1.0;
            _statusMessage = "Enrolling face...";
          });

          final bool isEnrolled = await _enrollFaceApi();

          setState(() {
            _isProcessingImage = false;
          });

          if (isEnrolled) {
            final straightPath = prefs.getString('face_straight_path_$employeeId') ?? savedPath;
            _showSuccessDialog(straightPath);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Face enrollment failed. Please try again."),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() {
              _currentStep = FaceVerificationStep.turnSide2;
              _progress = 0.66;
            });
            _startProcessingStream();
          }
        }
      } else {
        // Crop failed, retry this angle step
        setState(() {
          _isProcessingImage = false;
        });
        _startProcessingStream();
      }
    } catch (e) {
      debugPrint("Error capturing angle photo: $e");
      setState(() {
        _isProcessingImage = false;
      });
      _startProcessingStream();
    }
  }

  Future<bool> _enrollFaceApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = singletonClass.getJWTModel()?.employeeId ?? '';
      
      final straightPath = prefs.getString('face_straight_path_$employeeId') ?? '';
      final leftPath = prefs.getString('face_left_path_$employeeId') ?? '';
      final rightPath = prefs.getString('face_right_path_$employeeId') ?? '';

      if (straightPath.isEmpty || leftPath.isEmpty || rightPath.isEmpty) {
        debugPrint("Error: Missing one of the angle photos");
        return false;
      }

      final jwt = singletonClass.getJWTModel();
      final String empId = jwt?.empId ?? '';
      final String name = jwt?.userName ?? '';
      final String branchId = jwt?.branchId ?? '';
      final String metadata = jsonEncode({
        "grade": jwt?.grade ?? '',
        "department": singletonClass.employeeDataList.first.data.first.employeeInfo!.first.depName ?? '',
        "companyId": jwt?.companyId ?? '',
      });

      final uri = Uri.parse('${singletonClass.baseURL}/enrollFace');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(singletonClass.getHeaders());

      request.fields['empId'] = empId;
      request.fields['name'] = name;
      request.fields['branchId'] = branchId;
      request.fields['metadata'] = metadata;

      // Add the 3 files
      final files = [straightPath, leftPath, rightPath];
      for (final filePath in files) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            filePath,
          ),
        );
      }

      debugPrint("Sending /enrollFace request to $uri with: empId=$empId, name=$name, branchId=$branchId");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Enroll face status code: ${response.statusCode}");
      debugPrint("Enroll face response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint("Error in _enrollFaceApi: $e");
    }
    return false;
  }

  Future<String?> _cropAndSaveFace(String tempPath, String filename) async {
    try {
      final bytes = await File(tempPath).readAsBytes();
      img.Image? imageObj = img.decodeImage(bytes);

      if (imageObj != null) {
        // 1. Bake EXIF orientation immediately to align pixels upright
        imageObj = img.bakeOrientation(imageObj);
        
        // Write baked image back to temporary file
        final bakedBytes = img.encodeJpg(imageObj, quality: 90);
        await File(tempPath).writeAsBytes(bakedBytes);

        // 2. Perform face detection directly on the baked upright file
        final inputImage = InputImage.fromFilePath(tempPath);
        final List<Face> faces = await _faceDetector.processImage(inputImage);

        if (faces.isNotEmpty) {
          final Face face = faces.first;
          final Rect box = face.boundingBox;

          // Crop a zoomed-in square centered around the face bounding box (1.4x scale factor)
          final double faceCenterX = box.left + box.width / 2;
          final double faceCenterY = box.top + box.height / 2;
          final double cropSize = math.max(box.width, box.height) * 1.4;

          final int left = (faceCenterX - cropSize / 2).round().clamp(0, imageObj.width - 1);
          final int top = (faceCenterY - cropSize / 2).round().clamp(0, imageObj.height - 1);
          final int width = cropSize.round().clamp(1, imageObj.width - left);
          final int height = cropSize.round().clamp(1, imageObj.height - top);

          final img.Image croppedImage = img.copyCrop(
            imageObj,
            x: left,
            y: top,
            width: width,
            height: height,
          );

          final croppedBytes = img.encodeJpg(croppedImage, quality: 90);
          
          // 3. Save to app documents directory (runtime storage)
          final appDir = await getApplicationDocumentsDirectory();
          final appFilePath = '${appDir.path}/$filename';
          await File(appFilePath).writeAsBytes(croppedBytes);

          debugPrint("Face saved locally at device path: $appFilePath");

          // Delete temporary camera file
          try {
            await File(tempPath).delete();
          } catch (_) {}

          return appFilePath;
        } else {
          debugPrint("ML Kit failed to find face in upright baked image");
        }
      }
    } catch (e) {
      debugPrint("Error cropping and saving face: $e");
    }
    return null;
  }

  void _showSuccessDialog(String path) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.success,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: NasColors.darkBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.facialRegistrationSuccessful,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NasColors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Dismiss Dialog
                  Navigator.of(context).pop(path); // Return photo path to profile
                },
                child: Text(
                  AppLocalizations.of(context)!.confirm,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.grey),
            ),

          // Face circular solid white overlay mask with Custom Painter
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: FaceCircleMaskPainter(
                    pulseScale: _pulseAnimation.value,
                    progress: _progress,
                  ),
                );
              },
            ),
          ),

          // Close button (Black color for solid white background visibility)
          Positioned(
            top: 40,
            left: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Light themed guidance panel
          Positioned(
            bottom: 60,
            left: 30,
            right: 30,
            child: SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: NasColors.darkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading cover
          if (_isProcessingImage)
            Container(
              color: Colors.white.withOpacity(0.75),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}

class FaceCircleMaskPainter extends CustomPainter {
  final double pulseScale;
  final double progress;

  FaceCircleMaskPainter({required this.pulseScale, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw solid white mask covering everything except the circular cutout
    final maskPaint = Paint()..color = Colors.white;
    final double radius = size.width * 0.38;
    final Offset center = Offset(size.width / 2, size.height * 0.4);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      ),
      maskPaint,
    );

    // 2. Draw circle thin grey border
    final bgRingPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius, bgRingPaint);

    // 3. Draw animated pulsing neon circle
    final borderPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius * pulseScale, borderPaint);

    // 4. Draw Apple Face ID style radial ticks around the circle
    const int totalTicks = 64;
    final double tickStartDistance = radius + 6;
    final double tickEndDistance = radius + 22;

    for (int i = 0; i < totalTicks; i++) {
      final double angle = (i * 2 * math.pi / totalTicks) - math.pi / 2;
      final double tickProgress = i / totalTicks;
      final bool isActive = tickProgress <= progress;

      final paint = Paint()
        ..color = isActive ? const Color(0xFF4CAF50) : Colors.grey[300]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final startOffset = Offset(
        center.dx + tickStartDistance * math.cos(angle),
        center.dy + tickStartDistance * math.sin(angle),
      );
      final endOffset = Offset(
        center.dx + tickEndDistance * math.cos(angle),
        center.dy + tickEndDistance * math.sin(angle),
      );

      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FaceCircleMaskPainter oldDelegate) {
    return oldDelegate.pulseScale != pulseScale || oldDelegate.progress != progress;
  }
}
