import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class TextFormatterScreen extends StatefulWidget {
  const TextFormatterScreen({super.key});

  @override
  State<TextFormatterScreen> createState() => _TextFormatterScreenState();
}

class _TextFormatterScreenState extends State<TextFormatterScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _outputText = '';

  void _transform(String operation) {
    final text = _inputController.text;
    if (text.isEmpty) return;

    setState(() {
      switch (operation) {
        case 'uppercase':
          _outputText = text.toUpperCase();
          break;
        case 'lowercase':
          _outputText = text.toLowerCase();
          break;
        case 'titlecase':
          _outputText = _toTitleCase(text);
          break;
        case 'bold':
          _outputText = '**$text**';
          break;
        case 'italic':
          _outputText = '*$text*';
          break;
        case 'strikethrough':
          _outputText = '~~$text~~';
          break;
      }
    });

    HapticFeedback.lightImpact();
  }

  String _toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _copyOutput() {
    if (_outputText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _outputText));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Formatter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Input
            TextField(
              controller: _inputController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter text to format...',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            // Format buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FormatChip(
                  label: 'Uppercase',
                  icon: Icons.arrow_upward,
                  onTap: () => _transform('uppercase'),
                ),
                _FormatChip(
                  label: 'Lowercase',
                  icon: Icons.arrow_downward,
                  onTap: () => _transform('lowercase'),
                ),
                _FormatChip(
                  label: 'Title Case',
                  icon: Icons.title,
                  onTap: () => _transform('titlecase'),
                ),
                _FormatChip(
                  label: 'Bold',
                  icon: Icons.format_bold,
                  onTap: () => _transform('bold'),
                ),
                _FormatChip(
                  label: 'Italic',
                  icon: Icons.format_italic,
                  onTap: () => _transform('italic'),
                ),
                _FormatChip(
                  label: 'Strike',
                  icon: Icons.format_strikethrough,
                  onTap: () => _transform('strikethrough'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Output
            if (_outputText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Result',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        IconButton(
                          onPressed: _copyOutput,
                          icon: const Icon(Icons.copy, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_outputText),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FormatChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
