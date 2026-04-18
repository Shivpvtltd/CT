import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class HashtagGeneratorScreen extends StatefulWidget {
  const HashtagGeneratorScreen({super.key});

  @override
  State<HashtagGeneratorScreen> createState() => _HashtagGeneratorScreenState();
}

class _HashtagGeneratorScreenState extends State<HashtagGeneratorScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _selectedCategory = 'Trending';
  List<String> _generatedHashtags = [];

  final List<String> _categories = [
    'Trending',
    'Niche',
    'Branded',
    'Location',
  ];

  final Map<String, List<String>> _mockHashtags = {
    'Trending': [
      '#viral',
      '#trending',
      '#explore',
      '#fyp',
      '#foryou',
      '#trendingnow',
      '#viralvideo',
      '#explorepage',
    ],
    'Niche': [
      '#contentcreator',
      '#creatorlife',
      '#digitalcreator',
      '#creatorcommunity',
      '#contentcreation',
      '#creatorsofinstagram',
      '#creatortips',
      '#creator economy',
    ],
    'Branded': [
      '#ad',
      '#sponsored',
      '#partner',
      '#brandpartner',
      '#collab',
      '#brandcollab',
      '#paidpartnership',
      '#ambassador',
    ],
    'Location': [
      '#worldwide',
      '#global',
      '#international',
      '#creatorfrom',
      '#localcreator',
      '#homeoffice',
      '#digitalnomad',
      '#remotework',
    ],
  };

  void _generate() {
    if (_topicController.text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _generatedHashtags = _mockHashtags[_selectedCategory] ?? [];
    });
  }

  void _copyHashtags() {
    if (_generatedHashtags.isEmpty) return;
    final text = _generatedHashtags.join(' ');
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hashtags copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hashtag Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Topic input
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                hintText: 'Enter topic or keyword...',
              ),
            ),
            const SizedBox(height: 16),
            // Category chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _categories.length - 1 ? 8 : 0,
                    ),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = category);
                        }
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Generate Hashtags'),
              ),
            ),
            const SizedBox(height: 24),
            // Results
            if (_generatedHashtags.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated Hashtags',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton.icon(
                    onPressed: _copyHashtags,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _generatedHashtags
                          .map((tag) => Chip(
                                label: Text(tag),
                                onDeleted: () {
                                  setState(() {
                                    _generatedHashtags.remove(tag);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
