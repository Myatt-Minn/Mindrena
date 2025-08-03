import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/m_category_selection_controller.dart';

class MCategorySelectionView extends GetView<MCategorySelectionController> {
  const MCategorySelectionView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCategorySelectionView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MCategorySelectionView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
