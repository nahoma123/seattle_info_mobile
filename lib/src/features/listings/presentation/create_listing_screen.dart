import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/application/auth_controller.dart';
import '../../categories/application/category_controller.dart';
import '../../categories/domain/category.dart' as domain_category; // Aliased
import '../application/listing_controller.dart';
import '../domain/listing.dart' as domain_listing; // Aliased
import '../domain/listing_details_models.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // Category specific controllers
  final _propertyTypeController = TextEditingController(); // For Housing
  final _rentDetailsController = TextEditingController(); // For Housing
  final _languagesSpokenController = TextEditingController(); // For Babysitting

  domain_category.Category? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _propertyTypeController.dispose();
    _rentDetailsController.dispose();
    _languagesSpokenController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final String? token = await ref.read(authControllerProvider.notifier).getCurrentUserToken();
      if (token == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication token not found. Please log in.')));
        return;
      }

      // Construct Listing object
      final listingToCreate = domain_listing.Listing(
        // id, userId, status, createdAt, updatedAt, expiresAt are set by backend
        id: '', // Placeholder, backend will generate
        userId: '', // Placeholder, backend will associate with authenticated user
        status: 'pending_approval', // Or 'active' depending on first post approval logic
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategory!.id,
        price: double.tryParse(_priceController.text),
        latitude: double.tryParse(_latitudeController.text),
        longitude: double.tryParse(_longitudeController.text),
        contactName: _contactNameController.text,
        contactEmail: _contactEmailController.text,
        contactPhone: _contactPhoneController.text,
        addressLine1: _addressLine1Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        housingDetails: _selectedCategory?.name == 'Housing' // Assuming name check for now
            ? HousingDetails(
                propertyType: _propertyTypeController.text,
                rentDetails: _rentDetailsController.text,
              )
            : null,
        babysittingDetails: _selectedCategory?.name == 'Baby Sitting' // Assuming name check
            ? BabysittingDetails(
                languagesSpoken: _languagesSpokenController.text.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList(),
              )
            : null,
      );

      final success = await ref.read(createListingControllerProvider.notifier).createListing(listingToCreate, token);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing created successfully!')));
        context.pop(); // Go back after successful creation
      } else if (mounted) {
        // Error is handled by watching the provider, but can show generic message here if needed
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create listing.')));
      }
    } else if (_selectedCategory == null) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final createListingState = ref.watch(createListingControllerProvider);

    ref.listen<AsyncValue<domain_listing.Listing?>>(createListingControllerProvider, (_, state) {
      if (state is AsyncError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString()), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price (USD)'), keyboardType: TextInputType.number),

              categoriesAsyncValue.when(
                data: (categories) => DropdownButtonFormField<domain_category.Category>(
                  value: _selectedCategory,
                  hint: const Text('Select Category'),
                  items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error loading categories: $e'),
              ),

              if (_selectedCategory != null) ..._buildConditionalFields(_selectedCategory!),

              TextFormField(controller: _contactNameController, decoration: const InputDecoration(labelText: 'Contact Name')),
              TextFormField(controller: _contactEmailController, decoration: const InputDecoration(labelText: 'Contact Email'), keyboardType: TextInputType.emailAddress),
              TextFormField(controller: _contactPhoneController, decoration: const InputDecoration(labelText: 'Contact Phone'), keyboardType: TextInputType.phone),
              TextFormField(controller: _addressLine1Controller, decoration: const InputDecoration(labelText: 'Address Line 1')),
              TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'City')),
              TextFormField(controller: _stateController, decoration: const InputDecoration(labelText: 'State')),
              TextFormField(controller: _zipCodeController, decoration: const InputDecoration(labelText: 'Zip Code')),
              TextFormField(controller: _latitudeController, decoration: const InputDecoration(labelText: 'Latitude (Optional)'), keyboardType: TextInputType.number),
              TextFormField(controller: _longitudeController, decoration: const InputDecoration(labelText: 'Longitude (Optional)'), keyboardType: TextInputType.number),

              const SizedBox(height: 20),
              createListingState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: _submitForm, child: const Text('Create Listing')),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConditionalFields(domain_category.Category category) {
    // Using category name for conditions. Ideally, use IDs or a more robust type check.
    // These names ("Housing", "Baby Sitting") must match exactly what's in your DB / Category model.
    if (category.name == 'Housing') {
      return [
        TextFormField(controller: _propertyTypeController, decoration: const InputDecoration(labelText: 'Property Type (e.g., For Rent, For Sale)')),
        TextFormField(controller: _rentDetailsController, decoration: const InputDecoration(labelText: 'Rent/Sale Details (e.g., 2-bed, 1-bath)')),
      ];
    } else if (category.name == 'Baby Sitting') {
      return [
        TextFormField(controller: _languagesSpokenController, decoration: const InputDecoration(labelText: 'Languages Spoken (comma-separated)')),
      ];
    }
    // TODO: Add fields for "Business" (subcategories might need another dropdown) and "Events"
    return []; // No specific fields for other categories yet
  }
}
