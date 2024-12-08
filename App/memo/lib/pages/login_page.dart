import 'package:flutter/material.dart';
import 'package:memo/components/authButton.dart';
import 'package:memo/components/googleLog.dart';
import 'package:memo/components/textField.dart';

void loginPage() {
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  LoginPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 160),
            //Logo
            Image.asset(
              "assets/images/BrandingImage.png",
              width: 350,
            ),

            const SizedBox(height: 30),

            //Username textfield
            TextFieldComponent(
              hintText: "Username",
              obscureText: false,
              controller: usernameController,
            ),

            //Password textfield
            TextFieldComponent(
              hintText: "Password",
              obscureText: true,
              controller: passwordController,
            ),
            //Forgot password
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color.fromARGB(255, 86, 174, 247),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            //Login button
            Authbutton(buttonText: "LOGIN", onTap: () {}),

            const SizedBox(
              height: 10,
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
                      'or Login using',
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

            const Googlelog(),
            //Signup link

            const SizedBox(
              height: 70,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Color.fromARGB(255, 160, 160, 160),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color.fromARGB(255, 86, 174, 247),
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
