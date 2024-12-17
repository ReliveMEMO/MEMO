import 'package:flutter/material.dart';
import 'package:memo/components/authButton.dart';
import 'package:memo/components/googleLog.dart';
import 'package:memo/components/textField.dart';
import 'package:memo/services/auth_service.dart';

void signupPage() {
  runApp(SignupPage());
}

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final authService = AuthService();

  void signup() async {
    final email = emailController.text;
    final userName = usernameController.text;
    final fullName = fullnameController.text;
    final password = passwordController.text;

    try {
      await authService.signUpWithEmailPassword(
          email, password, userName, fullName);

      Navigator.pushNamed(context, '/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
             SizedBox(height: screenHeight * 0.11),
            //Logo
            Image.asset(
              "assets/images/BrandingImage.png",
              width: 350,
            ),

            const SizedBox(height: 10),

            const Googlelog(),

            const SizedBox(
              height: 20,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Expanded(
                      child: Divider(
                    thickness: 0.5,
                    color: Color.fromARGB(255, 207, 207, 207),
                  )),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Color.fromARGB(255, 160, 160, 160),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Divider(
                    thickness: 0.5,
                    color: Color.fromARGB(255, 207, 207, 207),
                  )),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            //Username textfield
            TextFieldComponent(
              hintText: "Email",
              obscureText: false,
              controller: emailController,
            ),
            TextFieldComponent(
              hintText: "Username",
              obscureText: false,
              controller: usernameController,
            ),
            TextFieldComponent(
              hintText: "Full Name",
              obscureText: false,
              controller: fullnameController,
            ),

            //Password textfield
            TextFieldComponent(
              hintText: "Password",
              obscureText: true,
              controller: passwordController,
            ),

            //Login button
            Authbutton(buttonText: "LOGIN", onTap: signup),

            const SizedBox(
              height: 30,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already Registered?",
                  style: TextStyle(
                    color: Color.fromARGB(255, 160, 160, 160),
                  ),
                ),
                GestureDetector.new(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Color.fromARGB(255, 86, 174, 247),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
