import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../config/constants.dart';
import '../../widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.state(context);
    final auth = AppScope.authService(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Text(
                kAppName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login with your email and password',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
                      CustomButton(
                        label: isLoading ? 'Logging in...' : 'Login',
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  await _login(context, auth, state);
                                }
                              },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _login(
    BuildContext context,
    auth,
    state,
  ) async {
    setState(() => isLoading = true);
    
    await auth.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
      onSuccess: () async {
        if (mounted) {
          final email = emailController.text;
          await state.upsertUserProfile(email: email);
          state.completeLogin(email);
        }
      },
      onError: (e) {
        if (mounted) {
          _toast(context, e.message ?? 'Login failed');
          setState(() => isLoading = false);
        }
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

