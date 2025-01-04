import 'package:ecommerce_shopping/screens/login_screen.dart';
import 'package:ecommerce_shopping/themes/theme.dart';
import 'package:ecommerce_shopping/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptVerificationScreen extends StatefulWidget {
  const OptVerificationScreen({super.key});

  @override
  State<OptVerificationScreen> createState() => _OptVerificationScreenState();
}

class _OptVerificationScreenState extends State<OptVerificationScreen> {
  final int optLength = 6;
  final List<TextEditingController> _controller = [];
  final List<FocusNode> _focusNode = [];
  bool isVerifying = false;

  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < optLength; i++) {
      _controller.add(TextEditingController());
      _focusNode.add(FocusNode());
    }
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (!mounted) return;
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
            _startResendTimer();
          } else {
            _canResend = true;
          }
        });
      },
    );
  }

  void _verifyOTP() {
    String otp = _controller.map((controller) => controller.text).join();
    if (otp.length == optLength) {
      setState(() => isVerifying = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _controller) {
      controller.dispose();
    }
    for (var node in _focusNode) {
      node.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Verify Phone",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter 6-digit code sent +123 345 6789 000",
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  optLength,
                  (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controller[index],
                        focusNode: _focusNode[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 24),
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.textSecondary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (index < optLength - 1) {
                              _focusNode[index + 1].requestFocus();
                            } else {
                              _focusNode[index].unfocus();
                              _verifyOTP();
                            }
                          } else if (index > 0) {
                            _focusNode[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: isVerifying ? "Verifying..." : "Verify",
                onPressed: () {
                  if (!isVerifying) {
                    _verifyOTP();
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Didn't receive the code?",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _canResend
                          ? () {
                              setState(() {
                                _canResend = false;
                                _resendTimer = 30;
                              });
                              _startResendTimer();
                            }
                          : null,
                      child: Text(
                        _canResend
                            ? "Resend Code"
                            : "Resend code in ${_resendTimer}s",
                        style: TextStyle(
                          color: _canResend
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
