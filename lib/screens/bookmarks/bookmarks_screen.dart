import 'package:flutter/material.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('북마크')), // Bookmarks
      body: const Center(child: Text('북마크 화면 준비 중')),
    );
  }
}
