import 'dart:io';

import 'package:flutter/material.dart';

class CacheImageCustom extends StatelessWidget {
  final String path;
  const CacheImageCustom(this.path, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: BackButton(),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: Hero(
        tag: path,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
