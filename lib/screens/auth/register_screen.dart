import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final villageController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.authService(context);
    final state = AppScope.state(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create your Agro-Rent account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: villageController,
                  decoration: const InputDecoration(
                    labelText: 'Village / Mandal',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your village/mandal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: isLoading ? 'Creating account...' : 'Register',
                  onPressed: isLoading
                      ? null
                      : () async {
                          print('Register button pressed');
                          
                          // Check if Firebase is available
                          if (!auth.isFirebaseAvailable) {
                            print('Firebase is not available');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Firebase is not configured. Please check your setup.',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
                          
                          print('Validating form...');
                          if (_formKey.currentState!.validate()) {
                            print('Form is valid, calling _register...');
                            await _register(context, auth, state);
                          } else {
                            print('Form validation failed');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields correctly'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                ),
                const SizedBox(height: 16),
                // Add a simple test button to verify the screen is working
                TextButton(
                  onPressed: () {
                    print('Test button pressed - Register screen is working');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Register screen is working!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text('Test: Tap to verify screen is working'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register(
    BuildContext context,
    auth,
    state,
  ) async {
    print('_register called');
    print('Email: ${emailController.text}');
    print('Password length: ${passwordController.text.length}');
    
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed in _register');
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    print('Calling createUserWithEmailAndPassword...');
    
    try {
      await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        onSuccess: () async {
          print('Registration successful!');
          if (mounted) {
            final email = emailController.text.trim();
            await state.upsertUserProfile(
              email: email,
              name: nameController.text.trim(),
              village: villageController.text.trim(),
            );
            state.completeLogin(email);
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Logging you in...'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // Pop register screen - app will automatically show HomeScreen
            // because state.loggedIn is now true
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
          }
        },
        onError: (e) {
          print('Registration error callback: ${e.code} - ${e.message}');
          if (mounted) {
            String errorMsg = e.message ?? 'Registration failed. Please try again.';
            
            // Provide more specific error messages
            if (e.code == 'email-already-in-use') {
              errorMsg = 'This email is already registered. Please sign in instead.';
            } else if (e.code == 'weak-password') {
              errorMsg = 'Password is too weak. Please use at least 6 characters.';
            } else if (e.code == 'invalid-email') {
              errorMsg = 'Invalid email address. Please check and try again.';
            } else if (e.code == 'operation-not-allowed') {
              errorMsg = 'Email/password authentication is not enabled in Firebase. Please enable it in Firebase Console.';
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
            setState(() {
              isLoading = false;
            });
          }
        },
      );
    } catch (e, stackTrace) {
      print('Registration exception caught: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    villageController.dispose();
    super.dispose();
  }
}

