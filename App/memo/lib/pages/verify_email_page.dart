import 'package:flutter/material.dart';
import 'package:memo/components/authButton.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                size: 170,
                color: Colors.green[400],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'VERIFY YOUR ACCOUNT!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Check your email and verify your account to unlock your account. Once verified, click below to login to Relive every vibe with us!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              Authbutton(
                  buttonText: 'LOGIN',
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  })
            ],
          ),
        ),
      ),
    );
  }
}
