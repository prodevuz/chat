import 'package:rtchat/imports.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _phoneNumberController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  String? _verificationId;
  final _auth = FirebaseAuth.instance;

  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(hintText: 'Phone Number'),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyPhone,
              child: Text(_isVerifying ? 'Verifying...' : 'Verify Phone'),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _verificationCodeController,
              decoration: const InputDecoration(hintText: 'Verification Code'),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _isVerifying ? null : _signInWithVerificationCode,
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPhone() async {
    setState(() {
      _isVerifying = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneNumberController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        setState(() {
          _isVerifying = false;
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        // ignore: avoid_print
        print(e.message);
        setState(() {
          _isVerifying = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isVerifying = false;
          _verificationId = verificationId; // Store verification ID
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout
      },
    );
  }

  Future<void> _signInWithVerificationCode() async {
    final smsCode = _verificationCodeController.text;

    // Use stored verification ID
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    await _auth.signInWithCredential(credential);
  }
}
