import 'package:alirin/service/api_service.dart';
import 'package:flutter/material.dart';
import 'customer_dashboard_view.dart';
import 'login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerLoginView extends StatefulWidget {
  const CustomerLoginView({super.key});

  @override
  State<CustomerLoginView> createState() =>
      _CustomerLoginViewState();
}

class _CustomerLoginViewState
    extends State<CustomerLoginView> {

  final email = TextEditingController();
  final password = TextEditingController();

  bool obscure = true;
  bool loading = false;

    void loginCustomer() async {
    if (email.text.isEmpty || password.text.isEmpty) return;
    setState(() {
      loading = true;
    });

    final result = await ApiService.login(email.text.trim(), password.text.trim());

    if (!mounted) return;
    setState(() {
      loading = false;
    });

    if (result['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerDashboardView(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login failed')),
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

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              IconButton(

                onPressed: () {
                  Navigator.pop(context);
                },

                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                  size: 22,
                ),
              ),

              const SizedBox(height: 25),


              const Text(

                "Hai Selamat\ndatang kembali",

                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 10),

              const Text(

                "Masuk sebagai customer PDAM",

                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 40),

              field(
                email,
                "Email Customer",
                Icons.person_outline,
              ),

              const SizedBox(height: 18),

              field(
                password,
                "Password",
                Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 28),

              SizedBox(

                width: double.infinity,
                height: 56,

                child: ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color(0xff2563EB),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),

                  onPressed: loginCustomer,

                  child: loading

                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )

                      : const Text(

                          "Login Customer",

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 35),

              Row(
                children: [

                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  const Padding(

                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 12,
                    ),

                    child: Text(

                      "Atau login sebagai admin",

                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              GestureDetector(

                onTap: () {

                  Navigator.pushReplacement(

                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          const LoginView(
                         
                      ),
                    ),
                  );
                },

                child: ClipRRect(

                  borderRadius:
                      BorderRadius.circular(24),

                  child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LoginView(
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/Frame 652.png',
                  ),
                ),
              ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget field(
    TextEditingController c,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {

    return Container(

      height: 58,

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: Colors.black12,
        ),
      ),

      child: TextField(

        controller: c,

        obscureText:
            isPassword ? obscure : false,

        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
        ),

        decoration: InputDecoration(

          border: InputBorder.none,

          hintText: hint,

          hintStyle: const TextStyle(
            color: Colors.black45,
          ),

          prefixIcon: Icon(
            icon,
            color: Colors.black87,
          ),

          suffixIcon: isPassword

              ? IconButton(

                  onPressed: () {

                    setState(() {
                      obscure = !obscure;
                    });
                  },

                  icon: Icon(

                    obscure
                        ? Icons.visibility
                        : Icons.visibility_off,

                    color: Colors.black87,
                  ),
                )

              : null,
        ),
      ),
    );
  }
}