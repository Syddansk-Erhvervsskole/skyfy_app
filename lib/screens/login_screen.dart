import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyfy_app/helpers/login_helper.dart';
import 'package:skyfy_app/screens/main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();

  final loginHelper = LoginHelper();

  bool isLogin = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Color?> _bgAnim;

  late Animation<Offset> _logoOffset;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Logo moves UP
    _logoOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0, 2), // tweak for position
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _logoScale = Tween<double>(
      begin: 1.0,
      end: 0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bgAnim = ColorTween(
      begin: const Color(0xFF003366),
      end: const Color(0xFF000000),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  bool isLoading = false;
  Future<void> Login() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    String username = _usernameController.text;
    String password = _passwordController.text;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final response;
    try {
      response = await loginHelper.login(username, password);
      print('Login successful: $response');
    } catch (e) {
      final errorMessage = e.toString().contains('HandshakeException') ||
              e.toString().contains('SocketException') ||
              e.toString().contains('Connection timed out')
          ? 'Server is not responding. Please try again later.'
          : 'Login failed. Please check your credentials.';

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => isLoading = false);
      return;
    }

    await storage.write(key: "auth_token", value: response['token']);

    // Play animation before navigation
    await _controller.forward();

    sleep(Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => isLoading = false);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const MainLayout(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF000000),
                  const Color(0xFF000000),
                  _bgAnim.value ?? const Color(0xFF003366),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Spacer(),
                      Transform.translate(
                        offset: Offset(
                          _logoOffset.value.dx * 80,
                          _logoOffset.value.dy * 80,
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'lib/assets/SmallWithNoSubtitle.png',
                              width: 300,
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "The weather based music app",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Transform.scale(
                        scale: _logoScale.value,
                        alignment: Alignment.center,
                        child: Opacity(
                          opacity: 1 - _fadeAnim.value,
                          child: Column(
                            children: [
                              if (!isLogin) ...[
                                _inputField(
                                  controller: _emailController,
                                  label: "Email",
                                  validator: (v) =>
                                      !isLogin && (v == null || v.isEmpty)
                                          ? "Enter email"
                                          : null,
                                ),
                                const SizedBox(height: 16),
                              ],
                              _inputField(
                                controller: _usernameController,
                                label: "Username",
                              ),
                              const SizedBox(height: 16),
                              _inputField(
                                controller: _passwordController,
                                label: "Password",
                                obscure: true,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLogin
                                        ? "Don't have an account? "
                                        : "Already have an account? ",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() => isLogin = !isLogin);
                                    },
                                    child: Text(
                                      isLogin ? "Register" : "Login",
                                      style: const TextStyle(
                                        color: Color.fromRGBO(79, 152, 255, 1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          Login();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor:
                                      const Color.fromRGBO(79, 152, 255, 0.192),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        isLogin ? "Login" : "Register",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(79, 152, 255, 1),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
