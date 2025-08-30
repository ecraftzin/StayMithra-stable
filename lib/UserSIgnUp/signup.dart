import 'package:flutter/material.dart';
import 'package:staymitra/UserLogin/login.dart';
import 'package:staymitra/UserSIgnUp/email_verification_page.dart';
import 'package:staymitra/services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
bool _isPasswordHidden = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    // Validate form fields manually since we don't have a Form widget
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Basic email validation
    if (!_emailController.text.trim().contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Password length validation
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if username is available
    final isUsernameAvailable =
        await _authService.isUsernameAvailable(_usernameController.text.trim());
    if (!isUsernameAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username is already taken'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        location: _locationController.text.trim(),
      );

      if (response.user != null && mounted) {
        // Show success toast
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Account created successfully! Please verify your email to continue.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Wait a moment for user to see the toast, then navigate
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerificationPage(
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Stack(
                  children: [
                    // Background
                    SizedBox(
                      width: width,
                      height: height,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/signinup.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Foreground
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header: logo on top-left (replaces texts)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.06,
                            vertical: height * 0.03,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/logo/staymithra_logo.png', // <- your logo
                              height: height * 0.06,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        // Card
                        Container(
                          width: width * 0.9,
                          padding: EdgeInsets.all(width * 0.06),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(width * 0.06),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Let’s ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2D5948),
                                        fontSize: width * 0.06,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Travel you in.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF007F8C),
                                        fontSize: width * 0.06,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              Text(
                                "Discover the World with Every Sign Up",
                                style: TextStyle(
                                  fontSize: width * 0.04,
                                  color: const Color(0xFF2D5948),
                                ),
                              ),
                              SizedBox(height: height * 0.03),

                              _buildInputField(
                                  "Username", width, _usernameController),
                              SizedBox(height: height * 0.02),
                              _buildInputField("Email/Phone Number", width,
                                  _emailController),
                              SizedBox(height: height * 0.02),
                              _buildInputField(
                                  "Full Name", width, _fullNameController),
                              SizedBox(height: height * 0.02),
                              _buildInputField(
                                  "Location/Place", width, _locationController),
                              SizedBox(height: height * 0.02),
                              _buildInputField(
                                  "Password", width, _passwordController,
                                  isPassword: true,
                                  isHidden: _isPasswordHidden,
                                  onToggle: (){
                                    setState(() {
                                      _isPasswordHidden = !_isPasswordHidden;
                                    });
                                  }),

                              SizedBox(height: height * 0.02),

                              // Sign Up
                              SizedBox(
                                width: double.infinity,
                                height: height * 0.065,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF007F8C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(width * 0.07),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _signUp,
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : Text(
                                          "Sign Up",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: width * 0.045,
                                          ),
                                        ),
                                ),
                              ),

                              SizedBox(height: height * 0.025),

                              // Center(
                              //   child: Text(
                              //     "or sign in with",
                              //     style: TextStyle(fontSize: width * 0.04),
                              //   ),
                              // ),
                              SizedBox(height: height * 0.02),

                              // Social

                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     for (final asset in const [
                              //       'google.png',
                              //       'apple.png',
                              //       'facebook.png',
                              //     ])
                              //       Padding(
                              //         padding: EdgeInsets.symmetric(
                              //             horizontal: width * 0.02),
                              //         child: Container(
                              //           padding: EdgeInsets.all(width * 0.025),
                              //           decoration: BoxDecoration(
                              //             color: Colors.white,
                              //             borderRadius: BorderRadius.circular(
                              //                 width * 0.03),
                              //             boxShadow: [
                              //               BoxShadow(
                              //                 color:
                              //                     Colors.grey.withOpacity(0.3),
                              //                 blurRadius: 6,
                              //                 offset: const Offset(0, 4),
                              //               ),
                              //             ],
                              //           ),
                              //           child: Image.asset(
                              //             'assets/Signinwith/$asset',
                              //             width: width * 0.08,
                              //             height: width * 0.08,
                              //           ),
                              //         ),
                              //       ),
                              //   ],
                              // ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (final asset in const [
                                    'google.png',
                                    'facebook.png',
                                  ])
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.02),
                                      child: Container(
                                        padding: EdgeInsets.all(width * 0.025),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                              width * 0.03),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Image.asset(
                                          'assets/Signinwith/$asset',
                                          width: width * 0.08,
                                          height: width * 0.08,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        // Bottom "Sign In" button
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.06),
                          child: SizedBox(
                            width: double.infinity,
                            height: height * 0.06,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF007F8C),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(width * 0.07),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign In",
                                style: TextStyle(fontSize: width * 0.045),
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
          },
        ),
      ),
    );
  }

  // Keep helpers INSIDE the class
Widget _buildInputField(
  String hint,
  double width,
  TextEditingController controller, {
  bool isPassword = false,
  bool isHidden = false,
  VoidCallback? onToggle,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword ? isHidden : false,
    style: TextStyle(fontSize: width * 0.04),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: width * 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.035),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                isHidden ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onToggle,
            )
          : null,
    ),
  );
}
}