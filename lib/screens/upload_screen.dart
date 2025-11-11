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
  bool isLoading = false;

  Uint8List? coverBytes;
  Uint8List? songBytes;
  String? songFileName;

  @override
  void initState() {
    super.initState();
  }

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

  void uploadSong() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
    });

    if (coverBytes == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select a cover image")));
      return;
    }
    if (songBytes == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select an MP3 file")));
      return;
    }

    // await Future.delayed(const Duration(seconds: 10));
    await contentHelper.uploadContent(_songNameController.text, songBytes);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Uploading...",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 250,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: pickCover,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white24),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white10,
                                    image: coverBytes != null
                                        ? DecorationImage(
                                            image: MemoryImage(coverBytes!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: coverBytes == null
                                      ? const Center(
                                          child: Icon(Icons.image,
                                              color: Colors.white54),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: pickSong,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Text(
                          songFileName ?? "Select MP3 File",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _songNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Track Name"),
                        validator: (v) =>
                            v!.isEmpty ? "Enter a track name" : null,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: uploadSong,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor:
                              const Color.fromRGBO(79, 152, 255, 0.192),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Upload",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
