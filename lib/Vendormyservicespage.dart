import 'dart:io';
import 'package:farha/Vendoraddservicepage.dart';
import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'VendorNav.dart';
import 'Vendoraddservicepage.dart';
import 'Vendor_services_service.dart';

// ── Data Model ────────────────────────────────────────────────────────────────
class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String capacity;
  final String location;
  final double price;
  final String imageUrl;       // can be a network URL ("http...") OR a local file path
  final List<String> galleryUrls; // same: each entry can be a URL or a local path
  bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    this.description = '',
    this.category = '',
    this.capacity = '',
    required this.location,
    required this.price,
    required this.imageUrl,
    this.galleryUrls = const [],
    this.isActive = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id:          json['id']?.toString() ?? '',
      name:        json['name'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      category:    json['category'] ?? '',
      capacity:    json['capacity']?.toString() ?? '',
      location:    json['location'] ?? json['city'] ?? '',
      price:       (json['price'] ?? 0).toDouble(),
      imageUrl:    json['image_url'] ?? json['image'] ?? '',
      galleryUrls: (json['gallery'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      isActive: (json['status'] ?? json['is_active'] ?? true) == true ||
          (json['status'] ?? '').toString().toLowerCase() == 'active',
    );
  }

  // 🔑 NEW: needed to send this model as JSON to the API (POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'capacity': capacity,
      'location': location,
      'price': price,
      'image_url': imageUrl,
      'gallery': galleryUrls,
      'is_active': isActive,
    };
  }

  ServiceModel copyWith({
    String? name,
    String? description,
    String? category,
    String? capacity,
    String? location,
    double? price,
    String? imageUrl,
    List<String>? galleryUrls,
    bool? isActive,
  }) {
    return ServiceModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      capacity: capacity ?? this.capacity,
      location: location ?? this.location,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      isActive: isActive ?? this.isActive,
    );
  }
}

// ── Smart image widget: works for both network URLs and local file paths ─────
class ServiceImage extends StatelessWidget {
  final String path;
  final double? height;
  final double? width;
  final BoxFit fit;

  const ServiceImage({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  bool get _isNetwork => path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return _placeholder();

    if (_isNetwork) {
      return Image.network(
        path,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    // Local file path (e.g. picked from gallery in Add/Edit Service)
    return Image.file(
      File(path),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      color: kNavy,
      child: const Center(child: Icon(Icons.image_outlined, color: kWhite, size: 40)),
    );
  }
}

// ── My Services Page ──────────────────────────────────────────────────────────
class VendorMyServicesPage extends StatefulWidget {
  const VendorMyServicesPage({super.key});

  @override
  State<VendorMyServicesPage> createState() => _VendorMyServicesPageState();
}

class _VendorMyServicesPageState extends State<VendorMyServicesPage> {
  bool _isLoading = false;
  List<ServiceModel> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  // ── Load Services ─────────────────────────────
  Future<void> _loadServices() async {
    setState(() => _isLoading = true);

    try {
      _services = await VendorServicesApi.getServices();
    } catch (e) {
      _showSnack('Failed to load services. Check your connection.', isError: true);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ── Add New Service ───────────────────────────
  Future<void> _openAddService() async {
    final result = await showDialog<ServiceModel>(
      context: context,
      builder: (_) => const VendorAddServicePage(), // service == null => Add mode
    );
    if (result != null) {
      // VendorAddServicePage already POSTed it via VendorServicesApi.
      setState(() => _services.add(result));
      _showSnack('Service added.');
    }
  }

  // ── Edit Existing Service ─────────────────────
  Future<void> _openEditService(ServiceModel service) async {
    final result = await showDialog<ServiceModel>(
      context: context,
      builder: (_) => VendorAddServicePage(service: service), // pre-filled, fixes empty images bug
    );
    if (result != null) {
      // VendorAddServicePage already PUT the update via VendorServicesApi.
      setState(() {
        final index = _services.indexWhere((s) => s.id == service.id);
        if (index != -1) _services[index] = result;
      });
      _showSnack('Service updated.');
    }
  }

  // ── Toggle Active / Disabled ──────────────────
  Future<void> _toggleService(ServiceModel service) async {
    final previous = service.isActive;
    setState(() => service.isActive = !service.isActive); // optimistic

    try {
      await VendorServicesApi.toggleService(service.id, service.isActive);
      _showSnack(service.isActive ? 'Service enabled' : 'Service disabled');
    } catch (e) {
      setState(() => service.isActive = previous); // rollback
      _showSnack('Failed to update status.', isError: true);
    }
  }

  // ── Delete Service ────────────────────────────
  Future<void> _deleteService(ServiceModel service) async {
    final confirmed = await _showConfirmDialog(
      title:        'Delete Service',
      message:      'Are you sure you want to delete "${service.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    // Optimistic remove + rollback on failure
    final index = _services.indexWhere((s) => s.id == service.id);
    setState(() => _services.removeWhere((s) => s.id == service.id));

    try {
      await VendorServicesApi.deleteService(service.id);
      _showSnack('Service deleted.');
    } catch (e) {
      if (mounted && index != -1) {
        setState(() => _services.insert(index, service));
      }
      _showSnack('Failed to delete service.', isError: true);
    }
  }

  // ── Confirm Dialog ────────────────────────────
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          message,
          style: const TextStyle(color: kGray, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kGray, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDestructive ? Colors.red : kGold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showSnack(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        right: 16,
        child: _ToastBubble(message: message, isError: isError),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  // ── Build ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const VendorNav(activeTab: 'My Services'),
      body: Column(
        children: [
          _buildPageHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── Page Header ───────────────────────────────
  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Services',
                style: TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 22),
              ),
              const SizedBox(height: 2),
              Text(
                'You have ${_services.length} listed service${_services.length == 1 ? '' : 's'}.',
                style: const TextStyle(color: kGray, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          // ── Add New Service Button ──
          GestureDetector(
            onTap: _openAddService,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: kWhite, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Add New Service',
                    style: TextStyle(color: kWhite, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kGold));
    }
    if (_services.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      color: kGold,
      onRefresh: _loadServices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (_, i) => _ServiceCard(
          service:  _services[i],
          onEdit:   () => _openEditService(_services[i]),
          onToggle: () => _toggleService(_services[i]),
          onDelete: () => _deleteService(_services[i]),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_outlined, size: 64, color: kGray.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text(
              'No services yet',
              style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap "Add New Service" to list your first venue or service.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kGray, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Service Card ──────────────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FarhaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status Badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: service.isActive ? const Color(0xFF2E7D32) : const Color(0xFF9E9E9E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              service.isActive ? 'active' : 'disabled',
              style: const TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),

          // ── Service Image ──
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                ServiceImage(
                  path: service.imageUrl,
                  height: 160,
                  width: double.infinity,
                ),
                if (!service.isActive)
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: const Color(0xFF4A4A4A).withOpacity(0.55),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Name ──
          Text(
            service.name,
            style: const TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 6),

          // ── Location ──
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: kGray, size: 15),
              const SizedBox(width: 4),
              Text(service.location, style: const TextStyle(color: kGray, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),

          // ── Price ──
          Text(
            '\$${service.price.toStringAsFixed(0)}',
            style: const TextStyle(color: kGold, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 18),

          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 14),

          // ── Edit Button ──
          _ActionButton(
            label: 'Edit',
            icon: Icons.edit_outlined,
            textColor: kNavy,
            borderColor: kBorder,
            onTap: onEdit,
          ),
          const SizedBox(height: 10),

          // ── Disable / Enable Button ──
          _ActionButton(
            label: service.isActive ? 'Disable' : 'Enable',
            icon: service.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            textColor: service.isActive ? const Color(0xFFB8860B) : const Color(0xFF2E7D32),
            fillColor: service.isActive ? const Color(0xFFFFF8E7) : const Color(0xFFEAF7EC),
            borderColor: service.isActive ? const Color(0xFFF0D080) : const Color(0xFFA9DDB4),
            onTap: onToggle,
          ),
          const SizedBox(height: 10),

          // ── Delete Button ──
          _ActionButton(
            label: 'Delete',
            icon: Icons.delete_outline_rounded,
            textColor: Colors.red,
            fillColor: const Color(0xFFFFF0F0),
            borderColor: const Color(0xFFFFCDD2),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color textColor;
  final Color? fillColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.textColor,
    this.fillColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: fillColor ?? kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toast Bubble (top success/error notification) ─────────────────────────────
class _ToastBubble extends StatelessWidget {
  final String message;
  final bool isError;

  const _ToastBubble({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.cancel : Icons.check_circle,
              color: isError ? Colors.red : const Color(0xFF2E7D32),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(
                color: kNavy,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}