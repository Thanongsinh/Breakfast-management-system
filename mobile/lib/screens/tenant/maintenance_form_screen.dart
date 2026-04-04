import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/role_aware_scaffold.dart';
import '../../providers/maintenance_provider.dart';
import '../../app/constants.dart';

class MaintenanceFormScreen extends ConsumerStatefulWidget {
  const MaintenanceFormScreen({super.key});

  @override
  ConsumerState<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends ConsumerState<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'plumbing';
  String _selectedPriority = 'medium';
  final List<String> _imagePaths = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    // Simulated image picker - in a real app, use image_picker package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image picker would open here'),
        backgroundColor: AppConstants.infoColor,
      ),
    );

    // Simulate adding an image
    setState(() {
      _imagePaths.add('image_${_imagePaths.length + 1}.jpg');
    });
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(maintenanceProvider.notifier).createRequest(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            priority: _selectedPriority,
            images: _imagePaths,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maintenance request created successfully'),
          backgroundColor: AppConstants.successColor,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create request: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoleAwareScaffold(
      title: 'New Maintenance Request',
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              const SizedBox(height: AppConstants.spacingLg),
              _buildDescriptionField(),
              const SizedBox(height: AppConstants.spacingLg),
              _buildCategoryDropdown(),
              const SizedBox(height: AppConstants.spacingLg),
              _buildPriorityDropdown(),
              const SizedBox(height: AppConstants.spacingLg),
              _buildImageSection(),
              const SizedBox(height: AppConstants.spacingXl),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Brief title for your request',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            if (value.trim().length < 3) {
              return 'Title must be at least 3 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Describe the issue in detail',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: AppConstants.maintenanceCategories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(_formatCategory(category)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        DropdownButtonFormField<String>(
          value: _selectedPriority,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.priority_high),
          ),
          items: AppConstants.maintenancePriorities.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: _getPriorityColor(priority),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(_formatPriority(priority)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPriority = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Images (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Images'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        if (_imagePaths.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingXl),
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.borderColor),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              color: AppConstants.backgroundColor,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.image,
                  size: 48,
                  color: AppConstants.textDisabled,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  'No images added',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            children: _imagePaths.asMap().entries.map((entry) {
              final index = entry.key;
              final path = entry.value;
              return _buildImageChip(path, index);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildImageChip(String path, int index) {
    return Chip(
      avatar: const Icon(Icons.image, size: 18),
      label: Text(path),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeImage(index),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.tenantPrimary,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Submit Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _formatCategory(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return 'Plumbing';
      case 'electrical':
        return 'Electrical';
      case 'furniture':
        return 'Furniture';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  String _formatPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return AppConstants.infoColor;
      case 'medium':
        return AppConstants.warningColor;
      case 'high':
        return Colors.deepOrange;
      case 'urgent':
        return AppConstants.errorColor;
      default:
        return AppConstants.textSecondary;
    }
  }
}
