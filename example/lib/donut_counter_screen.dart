import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:square_mobile_payments_sdk_example/auth_state.dart';
import 'package:square_mobile_payments_sdk/square_mobile_payments_sdk.dart';
import 'package:square_mobile_payments_sdk/src/models.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid(); 

class DonutCounterScreen extends StatefulWidget {
  const DonutCounterScreen({super.key});

  @override
  State<DonutCounterScreen> createState() => _DonutCounterScreenState();
}

class _DonutCounterScreenState extends State<DonutCounterScreen> {
  final _squareMobilePaymentsSdkPlugin = SquareMobilePaymentsSdk();
  var amount = 100;

  _onBuy(BuildContext context, int amount) async {
    try {
      String idempotencyKey = uuid.v4();

      Payment? payment = await _squareMobilePaymentsSdkPlugin.startPayment(
          PaymentParameters(
              amountMoney: Money(amount: amount, currencyCode: CurrencyCode.eur),
              idempotencyKey: idempotencyKey,
              note: "test note"
          )
          , PromptParameters(additionalPaymentMethods: List.empty(), mode: PromptMode.defaultMode));
      if (context.mounted && payment != null) {
        showPaymentDialog(context, payment);
      }
    } on Exception catch (e) {
      print(e);
      if (context.mounted) {
        showCanceledDialog(context);
      }
    }
  }

  void showPaymentDialog(BuildContext context,Payment payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Completed"),
          content:  Text(payment.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showCanceledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Canceled"),
          content: const Text("The payment was canceled."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> showReader() async {
    try {
      await _squareMobilePaymentsSdkPlugin.showMockReaderUI();
      print("Show Reader");
    } on Exception {
      print("Exception reader");
    }
  }

  Future<void> showSettings() async {
    try {
      await _squareMobilePaymentsSdkPlugin.showSettings();
    } on Exception {
      print("Exception in show settings");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthorized = Provider.of<AuthState>(context).isAuthorized;
    if (isAuthorized) {
      showReader();
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 50,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  showSettings();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/permissions');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text(
                  'Permissions',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/donut.svg',
                  width: 250.0, // Adjust size as needed
                  height: 250.0,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Donut Counter',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAuthorized ? () => _onBuy(context, amount) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade200,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Text(
                    "Buy for \$${(amount / 100).toStringAsFixed(2)}",
                    style: TextStyle(
                      color: isAuthorized ? Colors.black : Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!isAuthorized)
                const Text(
                  "Device not authorized. Open permissions to authorize.",
                  style: TextStyle(color: Color.fromARGB(255, 187, 122, 24)),
                )
            ],
          ),
        ));
  }
}
