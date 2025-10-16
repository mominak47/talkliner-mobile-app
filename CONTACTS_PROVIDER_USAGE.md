# Contacts Provider Usage Guide

This comprehensive guide covers how to use the new Contacts Provider in your Talkliner app for managing contacts with Riverpod state management.

## Table of Contents
1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [Available Providers](#available-providers)
4. [Contact Management](#contact-management)
5. [Search and Filtering](#search-and-filtering)
6. [Pagination](#pagination)
7. [Caching](#caching)
8. [Error Handling](#error-handling)
9. [Integration Examples](#integration-examples)
10. [Best Practices](#best-practices)

## Overview

The Contacts Provider manages all contact-related state including:
- Loading and caching contacts from the API
- Pagination support
- Search functionality
- Selected contact management
- Integration with PushToTalkService
- Automatic refresh and cache management

## Basic Usage

### 1. Import the Provider

```dart
import 'package:talkliner/providers/contacts_provider.dart';
```

### 2. Basic Widget Setup

```dart
class ContactsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsState = ref.watch(contactsProvider);
    
    if (contactsState.isLoading && contactsState.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (contactsState.hasError) {
      return Center(child: Text('Error: ${contactsState.errorMessage}'));
    }
    
    return ListView.builder(
      itemCount: contactsState.contacts.length,
      itemBuilder: (context, index) {
        final contact = contactsState.contacts[index];
        return ListTile(
          title: Text(contact.displayName),
          subtitle: Text(contact.status),
          onTap: () => ref.read(contactsProvider.notifier).selectContact(contact),
        );
      },
    );
  }
}
```

## Available Providers

### Main Provider
- `contactsProvider` - Main state provider with full ContactsState

### Convenience Providers
- `selectedContactProvider` - Currently selected contact
- `contactsListProvider` - List of all contacts
- `contactsLoadingProvider` - Loading state
- `contactsErrorProvider` - Error message (null if no error)
- `filteredContactsProvider` - Filtered contacts based on search
- `contactCountProvider` - Total number of contacts
- `canLoadMoreContactsProvider` - Whether more contacts can be loaded

### Search Provider
- `contactSearchProvider` - Search query state

## Contact Management

### Loading Contacts

```dart
class ContactsWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<ContactsWidget> createState() => _ContactsWidgetState();
}

class _ContactsWidgetState extends ConsumerState<ContactsWidget> {
  @override
  void initState() {
    super.initState();
    // Load contacts on widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactsProvider);
    
    return RefreshIndicator(
      onRefresh: () => ref.read(contactsProvider.notifier).refreshContacts(),
      child: ListView.builder(
        itemCount: contactsState.contacts.length,
        itemBuilder: (context, index) {
          final contact = contactsState.contacts[index];
          return ContactTile(contact: contact);
        },
      ),
    );
  }
}
```

### Selecting Contacts

```dart
// Select a contact
await ref.read(contactsProvider.notifier).selectContact(contact);

// Clear selection
await ref.read(contactsProvider.notifier).clearSelectedContact();

// Watch selected contact
final selectedContact = ref.watch(selectedContactProvider);
if (selectedContact != null) {
  // Use selected contact
}
```

### Updating Contact Status

```dart
// Update a contact's status
ref.read(contactsProvider.notifier).updateContactStatus(contactId, 'online');
```

## Search and Filtering

### Search Implementation

```dart
class ContactSearchWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(contactSearchProvider);
    final filteredContacts = ref.watch(filteredContactsProvider);
    
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            ref.read(contactSearchProvider.notifier).state = value;
          },
          decoration: InputDecoration(
            hintText: 'Search contacts...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredContacts.length,
            itemBuilder: (context, index) {
              return ContactTile(contact: filteredContacts[index]);
            },
          ),
        ),
      ],
    );
  }
}
```

### Manual Search

```dart
// Search contacts manually
final results = ref.read(contactsProvider.notifier).searchContacts('john');
```

## Pagination

### Load More Contacts

```dart
class ContactsListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsState = ref.watch(contactsProvider);
    final canLoadMore = ref.watch(canLoadMoreContactsProvider);
    
    return ListView.builder(
      itemCount: contactsState.contacts.length + (canLoadMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == contactsState.contacts.length) {
          // Load more button or loading indicator
          return canLoadMore
              ? LoadMoreButton(
                  onPressed: () => ref.read(contactsProvider.notifier).loadMoreContacts(),
                  isLoading: contactsState.isLoading,
                )
              : SizedBox.shrink();
        }
        
        return ContactTile(contact: contactsState.contacts[index]);
      },
    );
  }
}
```

### Infinite Scroll

```dart
class InfiniteScrollContacts extends ConsumerStatefulWidget {
  @override
  ConsumerState<InfiniteScrollContacts> createState() => _InfiniteScrollContactsState();
}

class _InfiniteScrollContactsState extends ConsumerState<InfiniteScrollContacts> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final canLoadMore = ref.read(canLoadMoreContactsProvider);
      if (canLoadMore) {
        ref.read(contactsProvider.notifier).loadMoreContacts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsListProvider);
    
    return ListView.builder(
      controller: _scrollController,
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return ContactTile(contact: contacts[index]);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

## Caching

### Cache Management

```dart
// Clear cache manually
await ref.read(contactsProvider.notifier).clearCache();

// Force refresh (bypass cache)
await ref.read(contactsProvider.notifier).loadContacts(forceRefresh: true);
```

### Cache Information

The provider automatically:
- Caches contacts for 1 hour
- Auto-refreshes every 5 minutes if data is stale
- Loads from cache on app startup
- Saves selected contact persistently

## Error Handling

### Error Display

```dart
class ContactsWithErrorHandling extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsState = ref.watch(contactsProvider);
    final errorMessage = ref.watch(contactsErrorProvider);
    
    return Column(
      children: [
        if (errorMessage != null)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.red[100],
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
                TextButton(
                  onPressed: () => ref.read(contactsProvider.notifier).loadContacts(forceRefresh: true),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ContactsList(),
        ),
      ],
    );
  }
}
```

## Integration Examples

### Complete Contact Screen

```dart
class ContactScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  @override
  void initState() {
    super.initState();
    // Load contacts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactsProvider);
    final selectedContact = ref.watch(selectedContactProvider);
    final isLoading = ref.watch(contactsLoadingProvider);
    final errorMessage = ref.watch(contactsErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts (${ref.watch(contactCountProvider)})'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.read(contactsProvider.notifier).refreshContacts(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => ref.read(contactSearchProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
          // Selected contact display
          if (selectedContact != null)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Selected: ${selectedContact.displayName}'),
                  Spacer(),
                  TextButton(
                    onPressed: () => ref.read(contactsProvider.notifier).clearSelectedContact(),
                    child: Text('Clear'),
                  ),
                ],
              ),
            ),
          
          // Error display
          if (errorMessage != null)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.red[100],
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text(errorMessage)),
                  TextButton(
                    onPressed: () => ref.read(contactsProvider.notifier).loadContacts(forceRefresh: true),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          
          // Contacts list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(contactsProvider.notifier).refreshContacts(),
              child: Builder(
                builder: (context) {
                  if (isLoading && contactsState.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  final filteredContacts = ref.watch(filteredContactsProvider);
                  
                  if (filteredContacts.isEmpty) {
                    return Center(
                      child: Text('No contacts found'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: filteredContacts.length + (contactsState.canLoadMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredContacts.length) {
                        return Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: contactsState.isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () => ref.read(contactsProvider.notifier).loadMoreContacts(),
                                    child: Text('Load More'),
                                  ),
                          ),
                        );
                      }
                      
                      final contact = filteredContacts[index];
                      final isSelected = selectedContact?.id == contact.id;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(contact.getInitials()),
                        ),
                        title: Text(contact.displayName),
                        subtitle: Text(contact.status),
                        trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
                        selected: isSelected,
                        onTap: () => ref.read(contactsProvider.notifier).selectContact(contact),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Best Practices

### 1. Loading Strategy
- Load contacts on app startup or screen initialization
- Use pull-to-refresh for user-initiated updates
- Implement infinite scroll for better UX

### 2. Error Handling
- Always check for errors and provide retry mechanisms
- Show user-friendly error messages
- Provide fallback states

### 3. Performance
- Use convenience providers to avoid unnecessary rebuilds
- Implement proper search debouncing
- Cache contacts appropriately

### 4. State Management
- Don't manually modify the contacts list
- Use the provider methods for all state changes
- Watch specific providers instead of the full state when possible

### 5. Memory Management
- The provider automatically disposes resources
- Cancel timers and listeners in your widgets' dispose methods

## Troubleshooting

### Common Issues

1. **Contacts not loading**
   - Check internet connection
   - Verify user authentication
   - Check API endpoint availability

2. **Search not working**
   - Ensure search query is properly set
   - Use `filteredContactsProvider` instead of `contactsListProvider`

3. **Pagination issues**
   - Check `canLoadMoreContactsProvider` before loading more
   - Ensure proper scroll controller setup

4. **Cache issues**
   - Clear cache if data seems stale
   - Force refresh to bypass cache

### Debug Information

```dart
// Get debug information
final contactsState = ref.read(contactsProvider);
print('Contacts loaded: ${contactsState.contacts.length}');
print('Current page: ${contactsState.currentPage}');
print('Total pages: ${contactsState.totalPages}');
print('Has more data: ${contactsState.hasMoreData}');
print('Last updated: ${contactsState.lastUpdated}');
```

This contacts provider provides a robust, feature-rich solution for managing contacts in your Talkliner app with proper caching, pagination, search, and error handling capabilities.
