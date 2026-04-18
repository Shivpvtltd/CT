import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  final List<_ScheduledPost> _posts = [
    _ScheduledPost(
      title: 'Product Review Video',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      platform: 'YouTube',
      notes: 'Review the new tech gadget',
    ),
    _ScheduledPost(
      title: 'Behind the Scenes',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      platform: 'Instagram',
      notes: 'BTS of recent shoot',
    ),
  ];

  void _addPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AddPostSheet(
        onSave: (post) {
          setState(() => _posts.add(post));
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Scheduler'),
      ),
      body: _posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scheduled posts yet',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getPlatformColor(post.platform).withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getPlatformIcon(post.platform),
                        color: _getPlatformColor(post.platform),
                      ),
                    ),
                    title: Text(post.title),
                    subtitle: Text(
                      '${DateFormat('MMM d, yyyy').format(post.dateTime)} at ${DateFormat('h:mm a').format(post.dateTime)}',
                    ),
                    trailing: Chip(
                      label: Text(
                        post.platform,
                        style: const TextStyle(fontSize: 11),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPost,
        icon: const Icon(Icons.add),
        label: const Text('Schedule'),
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'YouTube':
        return Colors.red;
      case 'Instagram':
        return Colors.purple;
      case 'TikTok':
        return Colors.black;
      case 'Twitter':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'YouTube':
        return Icons.play_circle_outline;
      case 'Instagram':
        return Icons.camera_alt_outlined;
      case 'TikTok':
        return Icons.music_note;
      case 'Twitter':
        return Icons.chat_bubble_outline;
      default:
        return Icons.link;
    }
  }
}

class _ScheduledPost {
  final String title;
  final DateTime dateTime;
  final String platform;
  final String notes;

  _ScheduledPost({
    required this.title,
    required this.dateTime,
    required this.platform,
    required this.notes,
  });
}

class _AddPostSheet extends StatefulWidget {
  final Function(_ScheduledPost) onSave;

  const _AddPostSheet({required this.onSave});

  @override
  State<_AddPostSheet> createState() => _AddPostSheetState();
}

class _AddPostSheetState extends State<_AddPostSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _platform = 'YouTube';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _platforms = ['YouTube', 'Instagram', 'TikTok', 'Twitter'];

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _save() {
    if (_titleController.text.isEmpty) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    widget.onSave(_ScheduledPost(
      title: _titleController.text,
      dateTime: dateTime,
      platform: _platform,
      notes: _notesController.text,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black.withOpacity(0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Schedule Post',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter post title...',
            ),
          ),
          const SizedBox(height: 16),
          // Platform dropdown
          DropdownButtonFormField<String>(
            value: _platform,
            decoration: const InputDecoration(labelText: 'Platform'),
            items: _platforms.map((p) {
              return DropdownMenuItem(value: p, child: Text(p));
            }).toList(),
            onChanged: (v) => setState(() => _platform = v!),
          ),
          const SizedBox(height: 16),
          // Date and Time pickers
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    DateFormat('MMM d, yyyy').format(_selectedDate),
                  ),
                  onTap: _pickDate,
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text(_selectedTime.format(context)),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Add any notes...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
