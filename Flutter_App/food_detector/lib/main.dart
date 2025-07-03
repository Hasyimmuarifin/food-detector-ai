// main.dart versi dengan 3 halaman terstruktur: Onboarding, Kamera, Galeri
// Struktur:
// 1. OnboardingScreen: tombol SCAN menampilkan pilihan (kamera atau galeri)
// 2. CameraScreen: untuk pengambilan gambar
// 3. GalleryScreen: untuk memilih gambar dari galeri dan mendeteksi

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:convert';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Untuk indikator loading yang menarik

late List<CameraDescription> cameras;
Map<String, dynamic>? globalFoodData; // Data makanan global

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await loadGlobalFoodData(); // Muat data makanan di awal
  await loadTFLiteModel();    // Muat model TFLite di awal
  runApp(FoodLensApp());
}

Future<void> loadGlobalFoodData() async {
  try {
    String jsonString = await rootBundle.loadString('assets/food_info.json');
    globalFoodData = json.decode(jsonString);
  } catch (e) {
    print("Error loading global food data: $e");
  }
}

Future<void> loadTFLiteModel() async {
  try {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
    print("TFLite model loaded successfully.");
  } catch (e) {
    print("Failed to load TFLite model: $e");
  }
}

// Fungsi helper untuk menampilkan dialog info makanan (bisa dipanggil dari mana saja)
void showFoodInfoDialog(BuildContext context, String foodNameKey, {String? detectedOutputMessage}) {
  if (globalFoodData == null || !globalFoodData!.containsKey(foodNameKey)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Info untuk ${foodNameKey.replaceAll('_', ' ')} tidak ditemukan.')),
    );
    return;
  }

  final foodInfo = globalFoodData![foodNameKey];
  final String origin = foodInfo['origin'] ?? 'Tidak diketahui';
  final List<dynamic> ingredients = foodInfo['ingredients'] ?? [];
  final String readableFoodName = foodNameKey.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          readableFoodName,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Asal: $origin', style: TextStyle(color: Colors.black87, fontSize: 16, fontFamily: 'Poppins')),
              SizedBox(height: 10),
              Text('Komposisi:', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              if (ingredients.isEmpty)
                Text('Tidak ada informasi komposisi.', style: TextStyle(color: Colors.black54, fontFamily: 'Poppins'))
              else
                ...ingredients.map((ing) => Text('- $ing', style: TextStyle(color: Colors.black87, fontFamily: 'Poppins'))).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Opsional: Lakukan sesuatu setelah dialog ditutup,
              // misalnya membersihkan state gambar di CameraScreen/GalleryScreen
              // (ini akan ditangani di dalam masing-masing screen)
            },
            child: Text('OK', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          ),
        ],
      );
    },
  );
}

class FoodLensApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodLens',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red, // AppBar merah untuk konsistensi
          foregroundColor: Colors.white, // Warna ikon dan teks di AppBar
          elevation: 4, // Sedikit shadow
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300, color: Colors.black),
          displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w400, color: Colors.black),
          displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.w400, color: Colors.black),
          headlineMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w400, color: Colors.black),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Colors.black),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        ).apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red,
          onPrimary: Colors.white,
          secondary: Colors.orangeAccent,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ).copyWith(
          background: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  void _showScanOptionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih Sumber Gambar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.red),
              title: Text('Ambil dari Kamera', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                Navigator.push(context, MaterialPageRoute(builder: (_) => CameraScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.red),
              title: Text('Pilih dari Galeri', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryScreen()));
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/food_pattern.png',
              fit: BoxFit.cover,
              repeat: ImageRepeat.repeat,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'FoodLens',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/food_illustration.png',
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height * 0.25,
              ),
              SizedBox(height: 30),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          'Scan makananmu sekarang untuk mengetahui informasi lebih lanjut!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => _showScanOptionDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 70, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                          elevation: 8,
                          shadowColor: Colors.red.withOpacity(0.4),
                        ),
                        child: Text(
                          'SCAN',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isDetecting = false;
  String _outputMessage = 'Siap memotret...';
  File? _capturedImage; // Menyimpan gambar yang diambil

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      setState(() => _outputMessage = 'Tidak ada kamera ditemukan.');
      return;
    }
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off); // Opsional: nonaktifkan flash
      if (!mounted) return;
      setState(() {
        _outputMessage = 'Siap memotret...';
      });
    } catch (e) {
      print("Error initializing camera: $e");
      setState(() => _outputMessage = 'Gagal inisialisasi kamera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized || _isDetecting) return;

    _controller?.stopImageStream(); // Hentikan stream preview saat mengambil foto
    setState(() {
      _isDetecting = true;
      _outputMessage = 'Mengambil gambar...';
    });

    try {
      final XFile picture = await _controller!.takePicture();
      setState(() {
        _capturedImage = File(picture.path);
        _outputMessage = 'Gambar diambil, mendeteksi...';
      });
      await _runTfliteOnImage(_capturedImage!);
    } catch (e) {
      print("Error taking picture: $e");
      setState(() {
        _outputMessage = 'Gagal mengambil gambar: $e';
        _capturedImage = null; // Reset gambar yang diambil jika gagal
      });
      _initializeCamera(); // Inisialisasi ulang kamera untuk preview
    }
  }

  Future<void> _runTfliteOnImage(File imageFile) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imageFile.path,
      numResults: 1,
      threshold: 0.7,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    _processRecognitions(recognitions);
  }

  void _processRecognitions(List<dynamic>? recognitions) {
    if (recognitions != null && recognitions.isNotEmpty) {
      String detectedLabel = recognitions[0]['label']
          .toString()
          .replaceAll(RegExp(r'[0-9]'), '')
          .trim()
          .toLowerCase()
          .replaceAll(' ', '_');

      if (globalFoodData != null && globalFoodData!.containsKey(detectedLabel)) {
        setState(() {
          _isDetecting = false;
          _outputMessage = 'Terdeteksi: ${detectedLabel.replaceAll('_', ' ')}';
        });
        showFoodInfoDialog(context, detectedLabel); // Tampilkan dialog
      } else {
        setState(() {
          _outputMessage = 'Mendeteksi: ${detectedLabel.replaceAll('_', ' ')} (Info tidak ditemukan)';
        });
      }
    } else {
      setState(() {
        _outputMessage = 'Tidak terdeteksi. Coba lagi.';
      });
    }
    _isDetecting = false; // Pastikan state deteksi direset
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.red)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ambil dari Kamera'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke OnboardingScreen
          },
        ),
      ),
      body: Stack(
        children: [
          // Tampilkan gambar yang diambil atau preview kamera
          _capturedImage != null
              ? Positioned.fill(
                  child: Image.file(_capturedImage!, fit: BoxFit.cover),
                )
              : Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
          // Overlay gelap di atas gambar/kamera
          if (_capturedImage != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _outputMessage,
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Tombol ambil foto
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: _takePicture,
                backgroundColor: Colors.red,
                child: Icon(Icons.camera_alt, size: 30, color: Colors.white),
                shape: CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _outputMessage = 'Pilih gambar dari galeri.';
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _pickImage(); // Langsung pic gambar saat layar dibuka
  }

  Future<void> _pickImage() async {
    setState(() {
      _isDetecting = false;
      _outputMessage = 'Memilih gambar...';
      _image = null; // Reset gambar sebelumnya jika ada
    });

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _outputMessage = 'Gambar dipilih, mendeteksi...';
        _isDetecting = true;
      });
      await _runTfliteOnImage(_image!);
    } else {
      // Jika pemilihan dibatalkan, kembali ke OnboardingScreen
      Navigator.pop(context);
    }
  }

  Future<void> _runTfliteOnImage(File imageFile) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imageFile.path,
      numResults: 1,
      threshold: 0.7,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    _processRecognitions(recognitions);
  }

  void _processRecognitions(List<dynamic>? recognitions) {
    if (recognitions != null && recognitions.isNotEmpty) {
      String detectedLabel = recognitions[0]['label']
          .toString()
          .replaceAll(RegExp(r'[0-9]'), '')
          .trim()
          .toLowerCase()
          .replaceAll(' ', '_');

      if (globalFoodData != null && globalFoodData!.containsKey(detectedLabel)) {
        setState(() {
          _outputMessage = 'Terdeteksi: ${detectedLabel.replaceAll('_', ' ')}';
        });
        showFoodInfoDialog(context, detectedLabel); // Tampilkan dialog
      } else {
        setState(() {
          _outputMessage = 'Mendeteksi: ${detectedLabel.replaceAll('_', ' ')} (Info tidak ditemukan)';
        });
      }
    } else {
      setState(() {
        _outputMessage = 'Tidak terdeteksi. Coba lagi.';
      });
    }
    _isDetecting = false; // Reset state deteksi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih dari Galeri'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke OnboardingScreen
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_library), // Tombol untuk pick gambar lagi
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Tampilkan gambar yang dipilih, atau pesan/loading jika belum ada
          Positioned.fill(
            child: _image == null
                ? Center(
                    child: _isDetecting
                        ? SpinKitCircle(color: Colors.red, size: 50.0) // Indikator loading
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library, size: 80, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                _outputMessage,
                                style: TextStyle(fontSize: 18, color: Colors.black54, fontFamily: 'Poppins'),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.upload),
                                label: Text('Pilih Gambar', style: TextStyle(fontFamily: 'Poppins')),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                  )
                : Image.file(_image!, fit: BoxFit.cover),
          ),
          // Overlay gelap di atas gambar yang dipilih
          if (_image != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          // Kotak output pesan deteksi
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _outputMessage,
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}