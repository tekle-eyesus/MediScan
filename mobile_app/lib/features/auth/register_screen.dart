import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _hospitalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      // Same Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF438EA5), Color(0xFF4DA49C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Doctor Registration",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF438EA5)),
                    ),
                    const SizedBox(height: 20),

                    // FORM FIELDS
                    _buildField(_nameController, "Full Name", Icons.person),
                    const SizedBox(height: 15),
                    _buildField(_hospitalController, "Hospital/Clinic",
                        Icons.local_hospital),
                    const SizedBox(height: 15),
                    _buildField(_emailController, "Email", Icons.email),
                    const SizedBox(height: 15),
                    _buildField(_passController, "Password", Icons.lock,
                        isPass: true),

                    const SizedBox(height: 20),
                    if (auth.errorMessage != null)
                      Text(auth.errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFF4DA49C), // Slightly different green for register
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                bool success = await auth.register(
                                  _emailController.text.trim(),
                                  _passController.text.trim(),
                                  _nameController.text.trim(),
                                  _hospitalController.text.trim(),
                                );
                                if (success && mounted) {
                                  Navigator.pop(
                                      context); // Go back to login or auto-login
                                }
                              },
                        child: auth.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("CREATE ACCOUNT",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back to Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller, String label, IconData icon,
      {bool isPass = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
    );
  }
}
