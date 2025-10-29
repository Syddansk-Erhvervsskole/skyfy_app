import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skyfy_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Logo moves UP
    _logoOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.49, -2.68), // tweak for position
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );


    _logoScale = Tween<double>(
      begin: 1.0,
      end: 0.33,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bgAnim = ColorTween(
      begin: const Color(0xFF003366),
      end: const Color(0xFF000000),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  Future<void> Login() async {
    await storage.write(key: "auth_token", value: "dummy_token");

    // Play animation before navigation
    await _controller.forward();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const HomeScreen(),
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
                        child: Transform.scale(
                          scale: _logoScale.value,
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              Image.asset(
                                'lib/assets/SmallWithNoSubtitle.png',
                                width: 300,
                              ),
                              const SizedBox(height: 8),
                              Opacity(
                                opacity: 1 - _fadeAnim.value,
                                child: const Text(
                                  "The weather based music app",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),


                      Opacity(
                        opacity: 1 - _fadeAnim.value,
                        child: Column(
                          children: [
                            if (!isLogin) ...[
                              _inputField(
                                controller: _emailController,
                                label: "Email",
                                validator: (v) => !isLogin &&
                                        (v == null || v.isEmpty)
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
                                  style:
                                      const TextStyle(color: Colors.white),
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
                              onPressed: () {
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
                              child: Text(
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
