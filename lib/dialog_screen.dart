import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widget_mask/widget_mask.dart';
import 'all_color.dart'; // Your custom colors

String clipOutImg = '';
bool original = true;

Widget imageIcon(double usableHeight, String imageLocation, StateSetter setDialogState) {
  return IconButton(
    style: ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    onPressed: () {
      setDialogState(() {
        original = false;
        clipOutImg = imageLocation;
      });
    },
    icon: Container(
      height: usableHeight / 20,
      width: usableHeight / 20,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: overAllColor),
      ),
      child: ImageIcon(
        AssetImage(imageLocation),
      ),
    ),
  );
}

Future<File> captureWidget(GlobalKey globalKey) async {
  RenderRepaintBoundary boundary =
  globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  Directory directory = await getTemporaryDirectory();
  String filePath = '${directory.path}/captured_image.png';
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List pngBytes = byteData!.buffer.asUint8List();

  print(filePath);
  // Save the captured image to the provided file path, overwriting the old file.
  File file = File(filePath);
  await file.writeAsBytes(pngBytes);
  return file;
}

Future<File?> customCrop(BuildContext context, File image) {
  clipOutImg = '';
  original = true;
  GlobalKey globalKey = GlobalKey();

  return showDialog<File>(
    useSafeArea: true,
    context: context,
    builder: (BuildContext context) {
      MediaQueryData mQ = MediaQuery.of(context);
      double usableHeight = mQ.size.height - mQ.padding.top - mQ.padding.bottom;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: Center(
              child: Text(
                'Uploaded Image',
                style: TextStyle(fontWeight: FontWeight.bold, color: overAllColor),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  key: globalKey,
                  child: original
                      ? SizedBox(
                    height: usableHeight / 3,
                    width: usableHeight / 3,
                    child: Image.file(
                      image,
                      fit: BoxFit.contain,
                    ),
                  )
                      : SizedBox(
                    height: usableHeight / 3,
                    width: usableHeight / 3,
                    child: WidgetMask(
                      blendMode: BlendMode.srcATop,
                      childSaveLayer: true,
                      mask: Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
                      child: clipOutImg.isNotEmpty
                          ? Image.asset(
                        clipOutImg,
                        fit: BoxFit.contain,
                      )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setDialogState(() {
                          original = true;
                          clipOutImg = '';
                        });
                      },
                      icon: Container(
                        height: usableHeight / 20,
                        width: usableHeight / 20,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: overAllColor),
                        ),
                        child: const FittedBox(child: Text("Original")),
                      ),
                    ),
                    imageIcon(usableHeight, 'assets/images/user_image_frame_1.png', setDialogState),
                    imageIcon(usableHeight, 'assets/images/user_image_frame_2.png', setDialogState),
                    imageIcon(usableHeight, 'assets/images/user_image_frame_3.png', setDialogState),
                    imageIcon(usableHeight, 'assets/images/user_image_frame_4.png', setDialogState),
                  ],
                ),
              ],
            ),
            actions: <Widget>[
              Center(
                child: ElevatedButton(
                  onPressed: () async {

                    File capturedImage = await captureWidget(globalKey); // Overwrite the image
                    File selectedImage = original ? image : capturedImage;

                    if (context.mounted) {
                      Navigator.pop(context, selectedImage); // Close the dialog
                    }
                  },
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(overAllColor),
                    shape: WidgetStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text(
                      "Use This Image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
