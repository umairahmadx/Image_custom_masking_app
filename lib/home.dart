import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'all_color.dart';
import 'dialog_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? image;
  String? imagePath; // To track and update the image path

  Future<void> pickImage(BuildContext context) async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    File? img = File(pickedImage.path);
    img = await _cropImage(img);
    if (img == null) return;

    if (context.mounted) {
      File? img2 = await customCrop(context, img);
      if (img2 == null) return;
      img = img2;
    }

    // Save and update state
    setState(() {
      image = img;
      imagePath = "${img?.path}?v=${DateTime.now().millisecondsSinceEpoch}";
    });

    // Clear Flutter's image cache to ensure a fresh image load
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedImage =
    await ImageCropper().cropImage(sourcePath: imageFile.path, uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Adjust',
        toolbarColor: overAllColor,
        toolbarWidgetColor: Colors.white,
      )
    ]);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: overAllColor,
        title: const Center(
          child: Text(
            "Add Image/Icon",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: overAllColor),
          ),
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Upload Image",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => pickImage(context),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.all(overAllColor),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Text(
                  "Choose from Device",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              if (image != null)
                Image.file(
                  File(image!.path), // Use the file directly without caching
                  fit: BoxFit.cover,
                  key: ValueKey(imagePath), // Force widget rebuild
                )
              else
                const Text("No image selected"),
            ],
          ),
        ),
      ),
    );
  }
}
