import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_gate_controller.dart';

class AuthGateView extends GetView<AuthGateController> {
  const AuthGateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/loading.gif', width: 100, height: 100),
              const SizedBox(height: 20),
              Text(
                controller.hasInternet.value
                    ? 'Checking authentication...'
                    : 'Checking connection...',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
