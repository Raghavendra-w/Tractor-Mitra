import 'package:flutter/material.dart';
import 'package:tractor_mitra/services/api_service.dart';
import 'package:tractor_mitra/utils/owner_session.dart';
import 'owner_main_screen.dart'; // ✅ CORRECT IMPORT

class OwnerOtpScreen extends StatefulWidget {
  final String mobile; // ✅ FIX 1: ADD MOBILE FIELD

  const OwnerOtpScreen({super.key, required this.mobile});

  @override
  State<OwnerOtpScreen> createState() => _OwnerOtpScreenState();
}

class _OwnerOtpScreenState extends State<OwnerOtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool loading = false;

  // ✅ VERIFIED & CORRECT METHOD
  void verifyOtp() async {
    if (otpController.text.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid 6-digit OTP")));
      return;
    }

    setState(() => loading = true);

    try {
      final data = await ApiService.verifyOtp(
        widget.mobile,
        otpController.text,
      );

      // ✅ SAVE OWNER SESSION
      OwnerSession.ownerId = data['owner_id'];

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful")));

      // ✅ GO TO OWNER MAIN SCREEN (WITH BOTTOM TABS)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OwnerMainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            Text(
              "OTP sent to ${widget.mobile}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : verifyOtp,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify & Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
