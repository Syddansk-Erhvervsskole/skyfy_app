import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyfy_app/helpers/content_helper.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final contentHelper = ContentHelper();
  final TextEditingController _songNameController = TextEditingController();

  bool isUploading = false;
  bool uploadComplete = false;

  Uint8List? coverBytes;
  Uint8List? songBytes;
  String? songFileName;

  Future<void> pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() => coverBytes = result.files.first.bytes);
    }
  }

  Future<void> pickSong() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        songBytes = result.files.first.bytes;
        songFileName = result.files.first.name;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(79, 152, 255, 1)),
      ),
    );
  }

  Future<void> uploadSong() async {
    if (!_formKey.currentState!.validate()) return;

    if (coverBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select a cover image")));
      return;
    }

    if (songBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select an MP3 file")));
      return;
    }

    setState(() {
      isUploading = true;
      uploadComplete = false;
    });

    try {
      await contentHelper.uploadAllContent(
        _songNameController.text,
        songBytes!,
        coverBytes!,
      );

      setState(() {
        isUploading = false;
        uploadComplete = true;
      });
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double w = constraints.maxWidth;

            double padding = w < 400 ? 12 : w < 700 ? 20 : 40;
            double spacing = w < 400 ? 12 : 20;
            double buttonHeight = w < 400 ? 48 : 55;

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Center(
                child: SizedBox(
                  width: w < 600 ? double.infinity : 500,
                  child: Form(
                    key: _formKey,
                    child: uploadComplete
                        ? _buildSuccess(buttonHeight)
                        : isUploading
                            ? _buildUploading()
                            : _buildForm(spacing, buttonHeight),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUploading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(height: 10),
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 15),
          Text("Uploading...", style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSuccess(double buttonHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
        const SizedBox(height: 16),
        const Text("Upload complete!", style: TextStyle(fontSize: 20, color: Colors.white)),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () {
            setState(() {
              uploadComplete = false;
              _songNameController.clear();
              songBytes = null;
              coverBytes = null;
              songFileName = null;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            minimumSize: Size.fromHeight(buttonHeight),
          ),
          child: const Text("Upload Another", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildForm(double spacing, double buttonHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: spacing),
       GestureDetector(
        onTap: pickCover,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            child: coverBytes == null
                ? const Center(
                    child: Icon(Icons.image, color: Colors.white54, size: 40),
                  )
                : Center(
                    child: Image.memory(
                      coverBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ),
      ),

        SizedBox(height: spacing),
        ElevatedButton(
          onPressed: pickSong,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            minimumSize: Size.fromHeight(buttonHeight),
          ),
          child: Text(
            songFileName ?? "Select MP3 File",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(height: spacing),
        TextFormField(
          controller: _songNameController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("Track Name"),
          validator: (v) => v!.isEmpty ? "Enter a track name" : null,
        ),
        SizedBox(height: spacing * 2),
        ElevatedButton(
          onPressed: uploadSong,
          style: ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(buttonHeight),
            backgroundColor: const Color.fromRGBO(79, 152, 255, 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("Upload", style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ],
    );
  }
}
