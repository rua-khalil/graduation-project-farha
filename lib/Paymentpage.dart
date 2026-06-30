import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'UserDashboardPage.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'card';
  final _cardController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const FarhaAppBar(),
      endDrawer: const FarhaDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Back Button ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back, color: kNavy, size: 18),
                      SizedBox(width: 6),
                      Text('Back', style: TextStyle(color: kNavy, fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),

            // ── Hero ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  FarhaBadge('Secure Payment'),
                  SizedBox(height: 16),
                  Text('Complete your payment', style: TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 26, height: 1.2)),
                  SizedBox(height: 10),
                  Text('Your booking will be confirmed once payment is processed.', style: TextStyle(color: kGray, fontSize: 14, height: 1.6)),
                ],
              ),
            ),

            // ── Order Summary ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FarhaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 16),
                    _SummaryRow(label: 'Grand Crystal Ballroom', value: '\$8,000'),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Event Date', value: 'June 15, 2026'),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Guests', value: '300 - 500'),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Service Fee', value: '\$400'),
                    const Divider(height: 20),
                    _SummaryRow(label: 'Total Amount', value: '\$8,400', isBold: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Payment Method ────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FarhaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Method', style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 16),

                    // Method options
                    _PaymentMethodOption(
                      value: 'card',
                      groupValue: _selectedMethod,
                      icon: Icons.credit_card_outlined,
                      label: 'Credit / Debit Card',
                      onChanged: (v) => setState(() => _selectedMethod = v!),
                    ),
                    const SizedBox(height: 10),
                    _PaymentMethodOption(
                      value: 'bank',
                      groupValue: _selectedMethod,
                      icon: Icons.account_balance_outlined,
                      label: 'Bank Transfer',
                      onChanged: (v) => setState(() => _selectedMethod = v!),
                    ),
                    const SizedBox(height: 10),
                    _PaymentMethodOption(
                      value: 'cash',
                      groupValue: _selectedMethod,
                      icon: Icons.payments_outlined,
                      label: 'Cash on Arrival',
                      onChanged: (v) => setState(() => _selectedMethod = v!),
                    ),

                    // Card form
                    if (_selectedMethod == 'card') ...[
                      const SizedBox(height: 20),
                      const Text('Card Number', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 8),
                      _PayInput(controller: _cardController, hint: '1234 5678 9012 3456', keyboardType: TextInputType.number),
                      const SizedBox(height: 14),
                      const Text('Cardholder Name', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 8),
                      _PayInput(controller: _nameController, hint: 'Name on card'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Expiry Date', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                                const SizedBox(height: 8),
                                _PayInput(controller: _expiryController, hint: 'MM/YY'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('CVV', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                                const SizedBox(height: 8),
                                _PayInput(controller: _cvvController, hint: '123', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _showSuccessDialog(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: kGold,
                          foregroundColor: kWhite,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Confirm Payment — \$8,400', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const FarhaFooter(),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.green, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Payment Successful!', style: TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 8),
            const Text('Your booking has been confirmed. You will receive a confirmation shortly.', textAlign: TextAlign.center, style: TextStyle(color: kGray, fontSize: 13, height: 1.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const UserDashboardPage()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: kGold, foregroundColor: kWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Go to Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _SummaryRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? kNavy : kGray, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, fontSize: isBold ? 15 : 13)),
        Text(value, style: TextStyle(color: kNavy, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, fontSize: isBold ? 16 : 13)),
      ],
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final IconData icon;
  final String label;
  final ValueChanged<String?> onChanged;
  const _PaymentMethodOption({required this.value, required this.groupValue, required this.icon, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kGoldBg : kBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? kGold : kBorder, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? kGold : kGray, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(color: selected ? kNavy : kGray, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 14))),
            Radio<String>(value: value, groupValue: groupValue, activeColor: kGold, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _PayInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  const _PayInput({required this.controller, required this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: kNavy, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kGray, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }
}