import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_pret_flutter/abstract/widget_view.dart';

class Camera extends StatefulWidget {
  Camera({ @required this.saveImage });

  final Function saveImage;

  @override
  CameraWidgetController createState() => CameraWidgetController();
}

class CameraWidgetController extends State<Camera> {
  PickedFile imageFile;
  dynamic pickImageError;
  String retrieveDataError;

  final ImagePicker picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  @override
  void initState() {
    try {
      picker.getImage(
        source: ImageSource.camera,
        maxWidth: null,
        maxHeight: null,
        imageQuality: null,
      ).then((pickedFile) {
        widget.saveImage(File(pickedFile.path));
      });
    } catch (e) {
      setState(() {
        pickImageError = e;
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }


  Text getRetrieveErrorWidget() {
    if (retrieveDataError != null) {
      final Text result = Text(retrieveDataError);
      retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      retrieveDataError = response.exception.code;
    }
  }

  @override
  Widget build(BuildContext context) => CameraView(this);
}

class CameraView extends WidgetView<Camera, CameraWidgetController> {
  CameraView(CameraWidgetController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
