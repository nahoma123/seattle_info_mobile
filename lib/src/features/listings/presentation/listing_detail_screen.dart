import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // For navigation (e.g., to login)
import '../../auth/application/auth_controller.dart'; // To check auth state
import '../application/listing_controller.dart'; // For listingDetailsProvider
import '../domain/listing.dart'; // For Listing type

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsyncValue = ref.watch(listingDetailsProvider(listingId));
    final authState = ref.watch(authStateChangesProvider);
    final bool isLoggedIn = authState.asData?.value != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
      ),
      body: listingAsyncValue.when(
        data: (listing) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(listing.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Price: \$${listing.price?.toStringAsFixed(2) ?? 'N/A'}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                // TODO: Display category name by fetching category details or if included in listing
                Text('Category ID: ${listing.categoryId}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(listing.description, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),

                if (listing.latitude != null && listing.longitude != null)
                  Text('Location: (${listing.latitude}, ${listing.longitude})'), // Basic location display
                const SizedBox(height: 16),

                // Display other details like address if available
                if (listing.addressLine1 != null) Text('Address: ${listing.addressLine1}'),
                if (listing.city != null) Text('City: ${listing.city}'),
                if (listing.state != null) Text('State: ${listing.state}'),
                if (listing.zipCode != null) Text('Zip: ${listing.zipCode}'),
                const SizedBox(height: 16),

                const Divider(),
                const SizedBox(height: 16),
                Text('Contact Information', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (isLoggedIn) ...[
                  if (listing.contactName != null && listing.contactName!.isNotEmpty)
                     Text('Name: ${listing.contactName}'),
                  if (listing.contactEmail != null && listing.contactEmail!.isNotEmpty)
                     Text('Email: ${listing.contactEmail}'),
                  if (listing.contactPhone != null && listing.contactPhone!.isNotEmpty)
                     Text('Phone: ${listing.contactPhone}'),
                  if ((listing.contactName == null || listing.contactName!.isEmpty) &&
                      (listing.contactEmail == null || listing.contactEmail!.isEmpty) &&
                      (listing.contactPhone == null || listing.contactPhone!.isEmpty))
                     const Text('No contact information provided.'),
                ] else ...[
                  const Text('You must be logged in to view contact details.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen
                      // Assuming your login route is named '/login'
                      context.go('/login');
                    },
                    child: const Text('Login to View Contacts'),
                  )
                ],
                const SizedBox(height: 20),
                Text('Posted on: ${listing.createdAt?.toLocal().toString().split(' ')[0] ?? 'N/A'}'),
                Text('Expires on: ${listing.expiresAt?.toLocal().toString().split(' ')[0] ?? 'N/A'}'),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading listing: $err')),
      ),
    );
  }
}
