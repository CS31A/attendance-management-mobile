import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';
import 'admin_dashboard.dart';
import 'app_data.dart'
;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  final loggedIn = await AppStorage.isLoggedIn();
  runApp(MyApp(startLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool startLoggedIn;
  const MyApp({super.key, required this.startLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: startLoggedIn ? const AdminDashboard() : const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  
  late AnimationController _buttonAnimationController;
  late AnimationController _formAnimationController;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Start form animation
    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _buttonAnimationController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Trigger button animation
      _buttonAnimationController.forward().then((_) {
        _buttonAnimationController.reverse();
      });
      
      // Hard-coded credentials
      const String hardcodedUsername = 'admin';
      const String hardcodedPassword = 'password123';
      
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();
      
      if (username == hardcodedUsername && password == hardcodedPassword) {
        // Successful login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear the form
        _usernameController.clear();
        _passwordController.clear();
        // Navigate to admin dashboard with custom transition and persist session
        AppStorage.setLoggedIn(true);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AdminDashboard(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              
              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        // Failed login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid username or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo with animation
                  FadeTransition(
                    opacity: _formAnimationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _formAnimationController,
                        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
                      )),
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/acla logo.png', // Your logo filename with space
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to custom logo if image fails to load
                              return Container(
                                color: Colors.red,
                                child: CustomPaint(
                                  painter: LogoPainter(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  FadeTransition(
                    opacity: _formAnimationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _formAnimationController,
                        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                      )),
                      child: const Text(
                        'ATTENDANCE MONITORING',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Username with animation
                  FadeTransition(
                    opacity: _formAnimationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _formAnimationController,
                        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                      )),
                      child: _buildTextField(
                        label: 'Username',
                        controller: _usernameController,
                        obscureText: false,
                        validatorMsg: 'Please enter username',
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Password with animation
                  FadeTransition(
                    opacity: _formAnimationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _formAnimationController,
                        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
                      )),
                      child: _buildTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        validatorMsg: 'Please enter password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Animated Login button
                  FadeTransition(
                    opacity: _formAnimationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _formAnimationController,
                        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                      )),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 8,
                            shadowColor: Colors.blue.withOpacity(0.3),
                          ),
                          child: const Text(
                            'LOG IN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required String validatorMsg,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validatorMsg;
            }
            return null;
          },
        ),
      ],
    );
  }
}

// Optional: Your original logo painter
class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.3, size.width * 0.8, size.height * 0.7);
    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.2, size.height * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
