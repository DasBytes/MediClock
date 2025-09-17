import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticating = false;
  bool hasBiometrics = false;
  String? error;

  @override
  void initState() {
    super.initState();
    checkBiometrics();
  }

  Future<void> checkBiometrics() async {
    try {
      final bool canCheck = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();
      setState(() {
        hasBiometrics = canCheck && isDeviceSupported;
      });
    } catch (e) {
      setState(() {
        hasBiometrics = false;
      });
    }
  }

  Future<void> authenticate() async {
    setState(() {
      isAuthenticating = true;
      error = null;
    });

    try {
      bool authenticated = false;
      if (hasBiometrics) {
        authenticated = await auth.authenticate(
          localizedReason: 'Use Face ID/Touch ID to access your medications',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
      } else {
        // Fallback: PIN authentication can be implemented here
        authenticated = true; // For demo purposes
      }

      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          error = 'Authentication failed. Please try again.';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        error = 'An error occurred. Please try again.';
      });
      print(e);
    } finally {
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(Icons.medical_services,
                      size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'MedRemind',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 3,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your Personal Medication Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hasBiometrics
                              ? 'Use Face ID/Touch ID or PIN to access your medications'
                              : 'Enter your PIN to access your medications',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed:
                              isAuthenticating ? null : () => authenticate(),
                          icon: Icon(
                            hasBiometrics
                                ? Icons.fingerprint
                                : Icons.vpn_key,
                            color: Colors.white,
                          ),
                          label: Text(
                            isAuthenticating
                                ? 'Verifying...'
                                : hasBiometrics
                                    ? 'Authenticate'
                                    : 'Enter PIN',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            minimumSize: Size(width - 80, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
