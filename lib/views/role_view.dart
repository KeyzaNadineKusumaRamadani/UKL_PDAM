import 'package:alirin/views/customer_loginView.dart';
import 'package:flutter/material.dart';

import 'login_view.dart';

class RoleView extends StatefulWidget {
  const RoleView({super.key});

  @override
  State<RoleView> createState() =>
      _RoleViewState();
}

class _RoleViewState extends State<RoleView>
    with TickerProviderStateMixin {

  late AnimationController entrance;

  late Animation<double> fade;

  late Animation<Offset> slide;

  @override
  void initState() {

    super.initState();

    entrance = AnimationController(

      vsync: this,

      duration: const Duration(
        milliseconds: 700,
      ),
    );

    fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(

      CurvedAnimation(
        parent: entrance,
        curve: Curves.easeIn,
      ),
    );

    slide = Tween<Offset>(

      begin: const Offset(0, 0.1),
      end: Offset.zero,

    ).animate(

      CurvedAnimation(
        parent: entrance,
        curve: Curves.easeOut,
      ),
    );

    entrance.forward();
  }

  @override
  void dispose() {

    entrance.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [
              Color(0xff4DBCF2),
              Color(0xff025CA8),
            ],
          ),
        ),

        child: SafeArea(

          child: FadeTransition(

            opacity: fade,

            child: SlideTransition(

              position: slide,

              child: SingleChildScrollView(

                child: Padding(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),

                  child: Column(

                    children: [

                      const SizedBox(height: 30),

                      Image.asset(

                        'assets/Alirin logo.png',

                        width: 130,
                      ),

                      const SizedBox(height: 40),

                      const Text(

                        "Pilih Peran",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(

                        "Masuk sebagai customer atau admin",

                        textAlign: TextAlign.center,

                        style: TextStyle(

                          color:
                              Colors.white.withOpacity(
                            0.85,
                          ),

                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 55),

                      GestureDetector(

                        onTap: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  const CustomerLoginView(),
                            ),
                          );
                        },

                        child: ClipRRect(

                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),

                          child: Image.asset(

                            'assets/Frame 651.png',

                            width: double.infinity,

                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      GestureDetector(

                        onTap: () {

                          Navigator.push(

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
                              BorderRadius.circular(
                            30,
                          ),

                          child: Image.asset(

                            'assets/Frame 652.png',

                            width: double.infinity,

                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}