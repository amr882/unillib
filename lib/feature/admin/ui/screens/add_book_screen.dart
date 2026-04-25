import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/admin/logic/book_management_provider.dart';
import 'package:unilib/feature/login/ui/widgets/app_input_field.dart';
import 'package:unilib/feature/login/ui/widgets/app_dropdown_field.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _copiesController = TextEditingController(text: '1');

  String _selectedCategory = 'Technology';
  String _selectedFaculty = 'Computing';

  final List<String> _categories = [
    'Technology',
    'Science',
    'History',
    'Fiction',
    'Business',
    'Art',
  ];
  final List<String> _faculties = [
    'Computing',
    'Engineering',
    'Science',
    'Arts',
    'Business',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _copiesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BookManagementProvider>();

    final newBook = Book(
      id: '??', // Will be set by Firestore
      rawId: '??',
      title: _titleController.text.trim(),
      titleLower: _titleController.text.trim().toLowerCase(),
      author: _authorController.text.trim(),
      authorLower: _authorController.text.trim().toLowerCase(),
      description: _descriptionController.text.trim(),
      isbn: _isbnController.text.trim(),
      year: _yearController.text.trim(),
      language: 'English', // Default
      category: _selectedCategory,
      faculty: _selectedFaculty,
      facultySlug: _selectedFaculty.toLowerCase(),
      coverUrl: 'NO_IMAGE_PLACEHOLDER',
      sourceUrl: '??',
      createdAt: '',
      updatedAt: '',
      availableCopies: int.parse(_copiesController.text),
      totalCopies: int.parse(_copiesController.text),
      borrowCount: 0,
      isAvailable: true,
      tags: [],
      reservedBy: [],
      borrowedBy: [],
      location: BookLocation(building: 'Main', floor: '1', shelf: 'A1'),
    );

    final success = await provider.addBook(newBook);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Book added successfully!',
            style: GoogleFonts.dmSans(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? 'Failed to add book',
            style: GoogleFonts.dmSans(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070E18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white70,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Book',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 32),

              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),
              AppInputField(
                label: 'Title',
                hint: 'Book Title',
                prefixIcon: Icons.title_rounded,
                controller: _titleController,
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: 'Author',
                hint: 'Author Name',
                prefixIcon: Icons.person_outline_rounded,
                controller: _authorController,
                validator: (v) => v!.isEmpty ? 'Author is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppInputField(
                      label: 'ISBN',
                      hint: 'ISBN Number',
                      prefixIcon: Icons.qr_code_rounded,
                      controller: _isbnController,
                      validator: (v) => v!.isEmpty ? 'ISBN required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildScanButton(),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Classification'),
              const SizedBox(height: 16),
              AppDropdownField<String>(
                label: 'Category',
                hint: 'Select Category',
                value: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
                prefixIcon: Icons.category_outlined,
              ),
              const SizedBox(height: 16),
              AppDropdownField<String>(
                label: 'Faculty',
                hint: 'Select Faculty',
                value: _selectedFaculty,
                items: _faculties
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedFaculty = v!),
                prefixIcon: Icons.business_rounded,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Details & Stock'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppInputField(
                      label: 'Year',
                      hint: 'Pub. Year',
                      prefixIcon: Icons.calendar_today_rounded,
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppInputField(
                      label: 'Copies',
                      hint: 'Total Stock',
                      prefixIcon: Icons.copy_rounded,
                      controller: _copiesController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: 'Description',
                hint: 'Book Description',
                prefixIcon: Icons.description_outlined,
                controller: _descriptionController,
                maxLines: 4,
              ),

              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gold.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.library_add_rounded,
              color: AppColors.gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book Registration',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Enter details to expand the library collection.',
                  style: GoogleFonts.dmSans(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white54,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildScanButton() {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(Icons.center_focus_weak_rounded, color: AppColors.gold),
        onPressed: () {
          // Future: ISBN Scanner implementation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ISBN Scanner coming soon!')),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isLoading = context.watch<BookManagementProvider>().isLoading;

    return GestureDetector(
      onTap: isLoading ? null : _submit,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'REGISTER BOOK',
                  style: GoogleFonts.dmSans(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }
}
