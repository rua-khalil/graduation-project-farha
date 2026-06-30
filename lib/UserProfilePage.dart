import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'UserNav.dart';

// ── Profile Page ──────────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  bool _saving = false;
  String? _error;

  final _firstNameController    = TextEditingController();
  final _lastNameController     = TextEditingController();
  final _emailController        = TextEditingController();
  final _phoneController        = TextEditingController();
  final _addressController      = TextEditingController();
  final _currentPassController  = TextEditingController();
  final _newPassController      = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  // ── Fetch profile from API ────────────────────────
  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // TODO: Replace with your real API endpoint
      // final response = await http.get(Uri.parse('https://your-api.com/profile'));
      // final data = jsonDecode(response.body);
      // _firstNameController.text = data['first_name'] ?? '';
      // _lastNameController.text  = data['last_name'] ?? '';
      // _emailController.text     = data['email'] ?? '';
      // _phoneController.text     = data['phone'] ?? '';
      // _addressController.text   = data['address'] ?? '';

      await Future.delayed(const Duration(milliseconds: 600));

      // ── Static data for now ───────────────────
      _firstNameController.text = 'Mohammad';
      _lastNameController.text  = 'Nasir';
      _emailController.text     = 'mohammadnasir@farha.com';
      _phoneController.text     = '0593697228';
      _addressController.text   = '';

    } catch (e) {
      _error = 'Failed to load profile.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Save changes ──────────────────────────────────
  Future<void> _saveChanges() async {
    setState(() => _saving = true);
    try {
      // TODO: Replace with your real API endpoint
      // await http.put(Uri.parse('https://your-api.com/profile'), body: {
      //   'first_name': _firstNameController.text.trim(),
      //   'last_name':  _lastNameController.text.trim(),
      //   'email':      _emailController.text.trim(),
      //   'phone':      _phoneController.text.trim(),
      //   'address':    _addressController.text.trim(),
      //   if (_newPassController.text.isNotEmpty) ...{
      //     'current_password': _currentPassController.text,
      //     'new_password':     _newPassController.text,
      //   },
      // });

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully.'),
            backgroundColor: kGold,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save changes.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _initials {
    final f = _firstNameController.text;
    final l = _lastNameController.text;
    if (f.isNotEmpty && l.isNotEmpty) return '${f[0]}${l[0]}'.toUpperCase();
    if (f.isNotEmpty) return f[0].toUpperCase();
    return 'MN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const UserNav(activeTab: 'Profile'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGold, strokeWidth: 2.5))
          : _error != null
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: kGray)),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _fetchProfile,
              child: const Text('Try Again'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Title ───────────────────────
            const Text(
              'Edit Profile',
              style: TextStyle(
                color: kNavy,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your account details and password.',
              style: TextStyle(color: kGray, fontSize: 14, height: 1.5),
            ),

            const SizedBox(height: 24),

            // ── Profile Card ────────────────
            FarhaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: kGold,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // First Name
                  _fieldLabel('First Name'),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _firstNameController,
                    hint: 'First name',
                  ),

                  const SizedBox(height: 16),

                  // Last Name
                  _fieldLabel('Last Name'),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _lastNameController,
                    hint: 'Last name',
                  ),

                  const SizedBox(height: 16),

                  // Email
                  _fieldLabel('Email'),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _emailController,
                    hint: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // Phone
                  _fieldLabel('Phone'),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _phoneController,
                    hint: 'Phone number',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  // Address
                  _fieldLabel('Address'),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _addressController,
                    hint: 'Your address',
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: kBorder),
                  const SizedBox(height: 20),

                  // ── Change Password ──────────
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      color: kNavy,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Current Password
                  _fieldLabel('Current Password'),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _currentPassController,
                    hint: '••••••••••',
                    obscure: _obscureCurrent,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: kGray,
                        size: 18,
                      ),
                      onPressed: () => setState(
                              () => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // New Password
                  _fieldLabel('New Password'),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _newPassController,
                    hint: 'New password',
                    obscure: _obscureNew,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: kGray,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Buttons ──────────────────
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: kGold,
                              foregroundColor: kWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: kWhite,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _saving ? null : _fetchProfile,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kNavy,
                              side: const BorderSide(color: kBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Field Label ───────────────────────────────────
  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: kNavy,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }

  // ── Input Field ───────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: kNavy, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kGray, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}