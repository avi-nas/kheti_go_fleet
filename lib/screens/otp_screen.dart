import 'package:firebase_auth/firebase_auth.dart';
import '../provider/auth_provider.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import 'package:pinput/pinput.dart';
import 'package:kheti_go_fleet/firebase_operation/handle_user_data.dart';
import 'package:kheti_go_fleet/screens/register_screen.dart';
import 'package:kheti_go_fleet/screens/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumberEntered;
  const OtpScreen(
      {super.key,
      required this.verificationId,
      required this.phoneNumberEntered});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late String otpCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 203, 66, 1.0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  Container(
                    width: 300,
                    height: 200,
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      "assets/kheti_go_logo.png",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Verification",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Enter the OTP send to the registered phone number\n${widget.phoneNumberEntered}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Pinput(
                    length: 6,
                    showCursor: true,
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.purple.shade200,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onCompleted: (value) {
                      setState(() {
                        otpCode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 600,
                    height: 50,
                    child: CustomButton(
                      text: "Verify",
                      onPressed: () async {
                        PhoneAuthCredential creds =
                            PhoneAuthProvider.credential(
                          verificationId: widget.verificationId,
                          smsCode: otpCode,
                        );
                        await FirebaseAuth.instance
                            .signInWithCredential(creds)
                            .then(
                          (value) async {
                            setState(() async {
                              await AppAuthProvider.setCurrentUser(
                                  FirebaseAuth.instance.currentUser!.uid);
                              if (await HandleUserData.isNewUser(HandleUserData
                                  .firebaseAuthInstance
                                  .currentUser!
                                  .phoneNumber)) {
                                if (!mounted) return;
                                Navigator.of(context).pop();
                                gotoNextScreen( RegisterScreen(), context);
                              } else {
                                if (!mounted) return;
                                Navigator.of(context).pop();
                                gotoNextScreen(const HomeScreen(), context);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Didn't receive any code?",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Resend New Code",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
