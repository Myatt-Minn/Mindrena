import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/modules/auth_gate/controllers/auth_gate_controller.dart';

class NoInternetScreen extends GetView<AuthGateController> {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No Internet Connection'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/no_connection.png', height: 200),
            const SizedBox(height: 20),
            const Text(
              'You are not connected to the internet.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.retryConnection();
              },
              child: Obx(
                () => (controller.isLoading.value)
                    ? const CircularProgressIndicator()
                    : const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
