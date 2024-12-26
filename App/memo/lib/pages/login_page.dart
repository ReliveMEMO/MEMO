import 'package:flutter/material.dart';
import 'package:memo/components/authButton.dart';
import 'package:memo/components/googleLog.dart';
//import 'package:memo/components/textField.dart';
import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void loginPage() {
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  //final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? emailError;
  String? passwordError;

  void login() async {
    final email = usernameController.text;
    final password = passwordController.text;

    setState(() {
      emailError = email.isEmpty ? 'Email is required' : null;
      passwordError = password.isEmpty ? 'Password is required' : null;
    });

    if (emailError != null || passwordError != null) {
      return; // Stop login attempt if there's an error
    }

    try {
      await authService.signInWithEmailPassword(email, password);
      final userExist = await checkUserExist(authService.getCurrentUserID());

      if (userExist) {
        Navigator.pushNamed(context, '/profile');
      } else {
        Navigator.pushNamed(context, '/create-profile');
      }
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

  Future<bool> checkUserExist(String? userId) async {
    final response = await Supabase.instance.client
        .from('User_Info')
        .select()
        .eq('id', userId!)
        .maybeSingle();

    if (response != null) {
      return true;
    }
    return false;
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
            SizedBox(height: screenHeight * 0.10),
            //Logo
            Image.asset(
              "assets/images/BrandingImage.png",
              width: 350,
            ),

            const SizedBox(height: 30),

            //Username textfield
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: "Email",
                  errorText: emailError,
                  errorStyle: const TextStyle(color: Colors.red),
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                  ),
                  fillColor: const Color.fromARGB(255, 248, 240, 255),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: emailError == null
                          ? Colors.transparent
                          : Colors.red, // Red border if error
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: emailError == null
                          ? Colors.transparent
                          : Colors.red, // Red border when error is present
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: emailError == null
                          ? Colors.transparent
                          : Colors.red, // Red border when error
                    ),
                  ),
                ),
              ),
            ),

            //Password textfield
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: "Password",
                  errorText: passwordError,
                  errorStyle: const TextStyle(color: Colors.red),
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                  ),
                  fillColor: const Color.fromARGB(255, 248, 240, 255),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: passwordError == null
                          ? Colors.transparent
                          : Colors.red, // Red border if error
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: passwordError == null
                          ? Colors.transparent
                          : Colors.red, // Red border when error is present
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: passwordError == null
                          ? Colors.transparent
                          : Colors.red, // Red border when error
                    ),
                  ),
                ),
              ),
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
            Authbutton(buttonText: "LOGIN", onTap: login),

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

            

            // Google Sign-In button
          Authbutton(
            buttonText: "Sign in with Google",
            onTap: () async {
              try {
                await authService.signInWithGoogle();
                Navigator.pushNamed(context, '/profile');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          ),


            /*const*/ 
            Googlelog(),
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
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "Sign Up",
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
