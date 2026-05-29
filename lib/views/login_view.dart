import 'package:alirin/controllers/auth_controllers.dart';
import 'package:alirin/service/app_collors.dart';
import 'package:alirin/views/customer_loginView.dart';
import 'package:flutter/material.dart';


import 'main_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await authController.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainView(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Login gagal',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 20,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 10),

                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 22,
                  ),

                  padding: EdgeInsets.zero,
                ),

                const SizedBox(height: 35),

                const Text(
                  "Hai Selamat\ndatang kembali",

                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Masuk sebagai admin PDAM",

                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff8B8B8B),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 40),

                // EMAIL
                Container(
                  height: 58,

                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(14),

                    border: Border.all(
                      color: const Color(0xff8D8D8D),
                    ),
                  ),

                  child: TextFormField(
                    controller: _usernameCtrl,

                    style: const TextStyle(
                      color: Colors.black,
                    ),

                    decoration: InputDecoration(
                      border: InputBorder.none,

                      hintText: "Email",

                      hintStyle: const TextStyle(
                        color: Color(0xffAFAFAF),
                      ),

                      prefixIcon: const Icon(
                        Icons.mail_outline_rounded,
                        color: Color(0xff0066D6),
                      ),

                      contentPadding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),

                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Email wajib diisi';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // PASSWORD
                Container(
                  height: 58,

                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(14),

                    border: Border.all(
                      color: const Color(0xff8D8D8D),
                    ),
                  ),

                  child: TextFormField(
                    controller: _passwordCtrl,

                    obscureText: _obscure,

                    style: const TextStyle(
                      color: Colors.black,
                    ),

                    decoration: InputDecoration(
                      border: InputBorder.none,

                      hintText: "Password",

                      hintStyle: const TextStyle(
                        color: Color(0xffAFAFAF),
                      ),

                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xff0066D6),
                      ),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },

                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,

                          color: const Color(0xff0066D6),
                        ),
                      ),

                      contentPadding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),

                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password wajib diisi';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [

                    Row(
                      children: [

                        SizedBox(
                          width: 22,
                          height: 22,

                          child: Checkbox(
                            value: _rememberMe,

                            activeColor:
                                const Color(0xff0066D6),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(5),
                            ),

                            side: const BorderSide(
                              color: Color(0xff0066D6),
                              width: 1.5,
                            ),

                            onChanged: (v) {
                              setState(() {
                                _rememberMe = v ?? false;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        const Text(
                          "Remember me",

                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    TextButton(
                      onPressed: () {},

                      child: const Text(
                        "Forgot password?",

                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          decoration:
                              TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _login,

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xff0066D6),

                      elevation: 6,

                      shadowColor:
                          const Color(0xff0066D6)
                              .withOpacity(0.35),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),

                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Log in",

                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [

                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                    ),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 10,
                      ),

                      child: Text(
                        "Atau login sebagai customer",

                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // CUSTOMER CARD
                Center(
                  child: GestureDetector(

                    onTap: () {

                      Navigator.pushReplacement(

                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              const CustomerLoginView(),
                        ),
                      );
                    },

                    child: Container(
                      width: 290,

                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff0066D6)
                                .withOpacity(0.25),

                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),

                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(28),

                        child: Image.asset(
                          'assets/Frame 651.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}