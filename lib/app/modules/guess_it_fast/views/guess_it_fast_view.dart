import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/guess_it_fast_controller.dart';

class GuessItFastView extends GetView<GuessItFastController> {
  const GuessItFastView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GuessItFastView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'GuessItFastView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
