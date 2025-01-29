import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImageSelect extends StatefulWidget{
  ImageSelect({Key? key}) : super(key: key);

  @override
  State<ImageSelect> creatState() => _ImageSelectState();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _ImageSelectState extends State<ImageSelect>{

  XFile? image;

  @override
  void initstate() {
    super.initState();
  }

  @override
  void dispose() {
    super.initState();
  }

  void ImagePressed() async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}