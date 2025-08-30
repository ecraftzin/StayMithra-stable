import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:staymitra/services/auth_service.dart';
import 'package:staymitra/ForgotPassword/reset_password_page.dart';
import 'package:staymitra/UserLogin/login.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;
  
  const OTPVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) {
      _showMessage('Please enter the complete 6-digit OTP', false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.verifyPasswordResetOTP(widget.email, _otpCode);

      if (mounted) {
        if (result['success'] == true) {
          _showMessage('OTP verified successfully!', true);
          await Future.delayed(const Duration(seconds: 1));
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  email: widget.email,
                  otpToken: result['token'] ?? _otpCode,
                ),
              ),
            );
          }
        } else {
          _showMessage(result['message'] ?? 'Invalid OTP. Please try again.', false);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error: ${e.toString()}', false);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResending = true);

    try {
      final result = await _authService.sendPasswordResetOTP(widget.email);

      if (mounted) {
        _showMessage(
          result['success'] == true 
            ? 'New OTP sent to your email' 
            : result['message'] ?? 'Failed to resend OTP',
          result['success'] == true,
        );
        
        // Clear current OTP
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error: ${e.toString()}', false);
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-verify when all digits are entered
    if (_otpCode.length == 6) {
      _verifyOTP();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007F8C), Color(0xFF2D5948)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Logo Section
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.08),
              child: const Logo(),
            ),

            // OTP Verification Form Section
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: SizedBox(
                    height: size.height * 0.70,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D5948),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter the 6-digit code sent to\n${widget.email}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2D5948),
                            ),
                          ),
                          SizedBox(height: size.height * 0.04),
                          
                          // OTP Input Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: 45,
                                height: 55,
                                child: TextFormField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF007F8C)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF007F8C), width: 2),
                                    ),
                                  ),
                                  onChanged: (value) => _onOTPChanged(value, index),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: size.height * 0.04),
                          
                          // Verify Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007F8C),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isLoading ? null : _verifyOTP,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          
                          // Resend OTP
                          TextButton(
                            onPressed: _isResending ? null : _resendOTP,
                            child: _isResending
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007F8C)),
                                    ),
                                  )
                                : const Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: Color(0xFF007F8C),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          
                          // Back to Login Link
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const SignInPage()),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Back to Sign In',
                              style: TextStyle(
                                color: Color(0xFF007F8C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'staymithra',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
