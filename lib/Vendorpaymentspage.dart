import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'VendorNav.dart';

// ── Payment Model ──────────────────────────────────────────────────────────
class PaymentModel {
  final String id;
  final String description;
  final String date;
  final double amount;
  final String status; // 'Completed' | 'Pending' | 'Refunded'

  const PaymentModel({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
    required this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      description: json['description'] ?? json['title'] ?? '',
      date: json['date'] ?? '',
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      status: json['status'] ?? 'Pending',
    );
  }
}

// ── Payments Summary Model ────────────────────────────────────────────────
class PaymentsSummary {
  final double netEarnings;
  final double grossRevenue;
  final double commissionPaid;
  final double pendingPayments;
  final List<PaymentModel> history;

  const PaymentsSummary({
    required this.netEarnings,
    required this.grossRevenue,
    required this.commissionPaid,
    required this.pendingPayments,
    required this.history,
  });

  factory PaymentsSummary.fromJson(Map<String, dynamic> json) {
    final list = (json['history'] ?? json['payments'] ?? []) as List;
    return PaymentsSummary(
      netEarnings: ((json['net_earnings'] ?? json['netEarnings'] ?? 0) as num).toDouble(),
      grossRevenue: ((json['gross_revenue'] ?? json['grossRevenue'] ?? 0) as num).toDouble(),
      commissionPaid: ((json['commission_paid'] ?? json['commissionPaid'] ?? 0) as num).toDouble(),
      pendingPayments: ((json['pending_payments'] ?? json['pendingPayments'] ?? 0) as num).toDouble(),
      history: list.map((e) => PaymentModel.fromJson(e)).toList(),
    );
  }

  factory PaymentsSummary.empty() {
    return const PaymentsSummary(
      netEarnings: 0,
      grossRevenue: 0,
      commissionPaid: 0,
      pendingPayments: 0,
      history: [],
    );
  }
}

// ── Payments Page ──────────────────────────────────────────────────────────
class VendorPaymentsPage extends StatefulWidget {
  const VendorPaymentsPage({super.key});

  @override
  State<VendorPaymentsPage> createState() => _VendorPaymentsPageState();
}

class _VendorPaymentsPageState extends State<VendorPaymentsPage> {
  bool _loading = true;
  String? _error;
  PaymentsSummary _summary = PaymentsSummary.empty();
  String _filter = 'All Payments';

  final List<String> _filters = [
    'All Payments',
    'Completed',
    'Pending',
    'Refunded',
  ];

  // ── API Endpoint ──────────────────────────────────
  // TODO: Replace with your real payments endpoint
  static const String _paymentsUrl = 'https://your-api.com/api/vendor/payments';

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // TODO: Replace with your real API call
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('userToken') ?? '';
      // final response = await http.get(
      //   Uri.parse(_paymentsUrl),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // if (response.statusCode == 200) {
      //   _summary = PaymentsSummary.fromJson(jsonDecode(response.body));
      // } else {
      //   _error = 'Failed to load payments.';
      // }

      await Future.delayed(const Duration(milliseconds: 700));
      _summary = PaymentsSummary.empty(); // placeholder until API is wired

    } catch (e) {
      _error = 'Connection error. Please try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PaymentModel> get _filteredHistory {
    if (_filter == 'All Payments') return _summary.history;
    return _summary.history.where((p) => p.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const VendorNav(activeTab: 'Payments'),
      body: RefreshIndicator(
        color: kGold,
        onRefresh: _fetchPayments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Title ─────────────────────────────
              const Text(
                'Payments',
                style: TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track revenue, completed payments, and downloadable invoices.',
                style: TextStyle(color: kGray, fontSize: 14, height: 1.5),
              ),

              const SizedBox(height: 20),

              if (_loading)
                _buildLoading()
              else if (_error != null)
                _buildError()
              else
                _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: CircularProgressIndicator(color: kGold, strokeWidth: 2.5),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_outlined, color: kGray, size: 36),
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: kGray, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: _fetchPayments,
            style: OutlinedButton.styleFrom(
              foregroundColor: kNavy,
              side: const BorderSide(color: kBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Summary Cards ──────────────────────
        _SummaryCard(
          label: 'Net Earnings',
          value: '\$${_summary.netEarnings.toStringAsFixed(0)}',
          valueColor: const Color(0xFF22C55E),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          label: 'Gross Revenue',
          value: '\$${_summary.grossRevenue.toStringAsFixed(0)}',
          valueColor: kGold,
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          label: 'Commission Paid',
          value: '\$${_summary.commissionPaid.toStringAsFixed(0)}',
          valueColor: const Color(0xFFDC2626),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          label: 'Pending Payments',
          value: '\$${_summary.pendingPayments.toStringAsFixed(0)}',
          valueColor: kGold,
        ),

        const SizedBox(height: 20),

        // ── Payment History Card ────────────────
        FarhaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment History',
                style: TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 14),

              // Filter dropdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filter,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kGray),
                    style: const TextStyle(color: kNavy, fontSize: 14, fontWeight: FontWeight.w500),
                    items: _filters.map((f) {
                      return DropdownMenuItem(value: f, child: Text(f));
                    }).toList(),
                    onChanged: (v) => setState(() => _filter = v!),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_filteredHistory.isEmpty)
                const Text(
                  'No payments found.',
                  style: TextStyle(color: kGray, fontSize: 14),
                )
              else
                Column(
                  children: _filteredHistory.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PaymentItem(payment: p),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment Item ──────────────────────────────────────────────────────────
class _PaymentItem extends StatelessWidget {
  final PaymentModel payment;
  const _PaymentItem({required this.payment});

  Color get _statusColor {
    switch (payment.status) {
      case 'Completed':
        return const Color(0xFF16A34A);
      case 'Pending':
        return const Color(0xFFD97706);
      case 'Refunded':
        return const Color(0xFFDC2626);
      default:
        return kGray;
    }
  }

  Color get _statusBg {
    switch (payment.status) {
      case 'Completed':
        return const Color(0xFFDCFCE7);
      case 'Pending':
        return const Color(0xFFFEF3C7);
      case 'Refunded':
        return const Color(0xFFFEE2E2);
      default:
        return kBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.description,
                  style: const TextStyle(
                    color: kNavy,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  payment.date,
                  style: const TextStyle(color: kGray, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${payment.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  payment.status,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}