// lib/widgets/book_card.dart

import 'package:flutter/material.dart';
import '../models/book_model.dart';  // 需要创建这个模型

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  
  const BookCard({
    Key? key,
    required this.book,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            book.coverUrl != null 
              ? Image.network(
                  book.coverUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    Container(height: 120, color: Colors.grey[300]),
                ) 
              : Container(color: Colors.grey[300], height: 120),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title, 
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    book.author ?? '未知作者',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: book.tags?.map((tag) => 
                      Chip(
                        label: Text(tag),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )
                    ).toList() ?? [],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}