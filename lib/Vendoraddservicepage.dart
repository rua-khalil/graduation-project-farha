import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'farha_shared.dart';
import 'Vendormyservicespage.dart'; // for ServiceModel
import 'Vendor_services_service.dart';

/// Add / Edit Service dialog.
/// - Pass `service: null` to ADD a new service.
/// - Pass `service: existingService` to EDIT it (main image + gallery + fields
///   are pre-filled from the existing data — this is the part that was missing
///   before and caused images to show empty in Edit mode).
class VendorAddServicePage extends StatefulWidget {
  final ServiceModel? service;

  const VendorAddServicePage({super.key, this.service});

  @override
  State<VendorAddServicePage> createState() => _VendorAddServicePageState();
}

class _VendorAddServicePageState extends State<VendorAddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _capacityController;
  late TextEditingController _locationController;

  String _selectedCategory = 'Wedding Hall Reservations';
  final List<String> _categories = const [
    'Wedding Hall Reservations',
    'Photography',
    'Catering',
    'Decoration',
    'Music & Entertainment',
  ];

  // Main image can be: an existing network URL (edit mode) OR a freshly picked local file.
  String? _existingMainImageUrl;
  File? _newMainImageFile;

  // Gallery: existing network urls (edit mode) + newly picked local files.
  List<String> _existingGalleryUrls = [];
  final List<File> _newGalleryFiles = [];

  bool _saving = false;
  String? _saveError;

  bool get _isEditMode => widget.service != null;

  @override
  void initState() {
    super.initState();
    final service = widget.service;

    _nameController = TextEditingController(text: service?.name ?? '');
    _descController = TextEditingController(text: service?.description ?? '');
    _priceController = TextEditingController(
      text: service != null && service.price > 0 ? service.price.toStringAsFixed(0) : '',
    );
    _capacityController = TextEditingController(text: service?.capacity ?? '');
    _locationController = TextEditingController(text: service?.location ?? '');

    if (service != null) {
      if (service.category.isNotEmpty) _selectedCategory = service.category;

      // 🔑 THE FIX: actually populate the existing image data when editing,
      // instead of leaving these null/empty.
      _existingMainImageUrl = service.imageUrl.isNotEmpty ? service.imageUrl : null;
      _existingGalleryUrls = List<String>.from(service.galleryUrls);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ── Main image actions ──────────────────────────────
  Future<void> _pickMainImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _newMainImageFile = File(picked.path);
      _existingMainImageUrl = null; // replaced by the new pick
    });
  }

  void _removeMainImage() {
    setState(() {
      _newMainImageFile = null;
      _existingMainImageUrl = null;
    });
  }

  // ── Gallery actions ─────────────────────────────────
  Future<void> _addGalleryPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _newGalleryFiles.add(File(picked.path)));
  }

  void _removeExistingGalleryImage(int index) {
    setState(() => _existingGalleryUrls.removeAt(index));
  }

  void _removeNewGalleryImage(int index) {
    setState(() => _newGalleryFiles.removeAt(index));
  }

  // ── Save / Update ───────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });

    // TODO: if you have a real backend, upload _newMainImageFile and
    // _newGalleryFiles here first, then use the returned URLs below instead
    // of the local file paths.
    final draft = ServiceModel(
      id: widget.service?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      capacity: _capacityController.text.trim(),
      location: _locationController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      imageUrl: _newMainImageFile?.path ?? _existingMainImageUrl ?? '',
      galleryUrls: [
        ..._existingGalleryUrls,
        ..._newGalleryFiles.map((f) => f.path),
      ],
      isActive: widget.service?.isActive ?? true,
    );

    try {
      final saved = _isEditMode
          ? await VendorServicesApi.updateService(draft)
          : await VendorServicesApi.addService(draft);

      if (mounted) Navigator.pop(context, saved);
    } catch (e) {
      if (mounted) {
        setState(() => _saveError = 'Failed to save service. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 660),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildSectionLabel('Main Image'),
                  const SizedBox(height: 8),
                  _buildMainImagePicker(),
                  const SizedBox(height: 18),
                  _buildSectionLabel('Gallery Images'),
                  const SizedBox(height: 8),
                  _buildGalleryPicker(),
                  const SizedBox(height: 18),
                  _buildTextField(controller: _nameController, hint: 'Service Name'),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _descController, hint: 'Description', maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _priceController,
                    hint: 'Price',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _capacityController,
                    hint: 'Approximate Capacity (e.g. 500 Guests)',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _locationController,
                    hint: 'Service Location (City, Street)',
                  ),
                  if (_saveError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _saveError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildSaveButton(),
                  const SizedBox(height: 10),
                  _buildCancelButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? 'Edit Service' : 'Add Service',
                style: const TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 19),
              ),
              const SizedBox(height: 4),
              const Text(
                'Fill in the service details to match your admin style.',
                style: TextStyle(color: kGray, fontSize: 12.5),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: kGray, size: 22),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: const TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 14));
  }

  // ── Main Image Picker (this is the part that was returning empty) ───
  Widget _buildMainImagePicker() {
    final hasNewFile = _newMainImageFile != null;
    final hasExistingUrl = _existingMainImageUrl != null && _existingMainImageUrl!.isNotEmpty;

    if (!hasNewFile && !hasExistingUrl) {
      return GestureDetector(
        onTap: _pickMainImage,
        child: Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFFFAFAFA),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, color: kGray.withOpacity(0.6), size: 30),
              const SizedBox(height: 8),
              Text('Upload Image', style: TextStyle(color: kGray.withOpacity(0.8), fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            // hasNewFile  -> show the freshly picked local image
            // otherwise   -> show the existing network image (edit mode)
            child: hasNewFile
                ? Image.file(_newMainImageFile!, fit: BoxFit.cover)
                : Image.network(
              _existingMainImageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: kNavy,
                  child: const Center(
                    child: CircularProgressIndicator(color: kGold, strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: kNavy,
                child: const Center(
                  child: Icon(Icons.broken_image_outlined, color: kWhite, size: 32),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _removeMainImage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gallery Picker ───────────────────────────────────
  Widget _buildGalleryPicker() {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < _existingGalleryUrls.length; i++)
            _galleryThumb(
              child: Image.network(
                _existingGalleryUrls[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: kNavy,
                  child: const Icon(Icons.image_outlined, color: kWhite, size: 20),
                ),
              ),
              onRemove: () => _removeExistingGalleryImage(i),
            ),
          for (int i = 0; i < _newGalleryFiles.length; i++)
            _galleryThumb(
              child: Image.file(_newGalleryFiles[i], fit: BoxFit.cover),
              onRemove: () => _removeNewGalleryImage(i),
            ),
          GestureDetector(
            onTap: _addGalleryPhoto,
            child: Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: kGray.withOpacity(0.7), size: 18),
                  const SizedBox(height: 2),
                  Text('Add Photo', style: TextStyle(color: kGray.withOpacity(0.7), fontSize: 9)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _galleryThumb({required Widget child, required VoidCallback onRemove}) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 64, height: 64, child: child),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: kWhite, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Text Field ───────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kGray.withOpacity(0.7), fontSize: 13.5),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kBorder)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: kGold)),
      ),
    );
  }

  // ── Category Dropdown ────────────────────────────────
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: _categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13.5))))
          .toList(),
      onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kBorder)),
      ),
    );
  }

  // ── Save Button ──────────────────────────────────────
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saving ? null : _save,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _saving ? kGold.withOpacity(0.6) : kGold,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _saving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(color: kWhite, strokeWidth: 2.2),
          )
              : Text(
            _isEditMode ? 'Update' : 'Save',
            style: const TextStyle(color: kWhite, fontWeight: FontWeight.w800, fontSize: 14.5),
          ),
        ),
      ),
    );
  }

  // ── Cancel Button ────────────────────────────────────
  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _saving ? null : () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: const Center(
          child: Text('Cancel', style: TextStyle(color: kGray, fontWeight: FontWeight.w700, fontSize: 14.5)),
        ),
      ),
    );
  }
}