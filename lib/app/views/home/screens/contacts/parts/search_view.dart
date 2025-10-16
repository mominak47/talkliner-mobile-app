import 'package:flutter/material.dart';

class SearchView extends StatelessWidget {
  final String searchQuery;
  final void Function(String) onSearch;
  const SearchView({
    super.key,
    required this.searchQuery,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: onSearch,
            decoration: InputDecoration(hintText: 'Search'),
          ),
        ],
      ),
    );
  }
}
