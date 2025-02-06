import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImageSelect extends StatefulWidget{
  ImageSelect({Key? key}) : super(key: key);

  @override
  State<ImageSelect> createState() => _ImageSelectState();
}

class _ImageSelectState extends State<ImageSelect>{

  XFile? image;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void ImagePressed() async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return(
   ImagePressed(),
    );

  }


}
