import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';

import '../../models/media_model.dart';
import '../../services/capsule_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/media_recorder.dart';
import '../../widgets/navbar.dart';
import '../../widgets/rich_text_editor.dart';
import 'capsule_confirmation_screen.dart';

class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({super.key});

  @override
  State<CreateCapsuleScreen> createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _quillController = quill.QuillController.basic();
  DateTime? _deliveryDate;
  int _bodyLength = 0;
  bool _isSubmitting = false;
  MediaAttachment? _photo;
  MediaAttachment? _video;
  MediaAttachment? _audio;
  String? _dateError;

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (date == null) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) {
      return;
    }

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _deliveryDate = selected;
      _dateError = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_deliveryDate == null || _deliveryDate!.isBefore(DateTime.now())) {
      setState(() {
        _dateError = 'Oops! Please select a future date and time.';
      });
      return;
    }

    if (_bodyLength == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message body cannot be empty.')),
      );
      return;
    }

    if (_bodyLength > AppConstants.capsuleBodyMaxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message exceeds the 2,000 character limit.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final capsule = await CapsuleService.instance.createCapsule(
        title: _titleController.text.trim(),
        contentText: RichTextSerializer.toJson(_quillController.document),
        deliveryDate: _deliveryDate!,
        photo: _photo,
        video: _video,
        audio: _audio,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        RoutePaths.capsuleCreated,
        arguments: CapsuleConfirmationArgs(
          title: capsule.title,
          deliveryDate: capsule.deliveryDate,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload media. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _deliveryDate == null
        ? 'Select delivery date & time'
        : DateFormat('MMM d, yyyy • h:mm a').format(_deliveryDate!);

    return Scaffold(
      appBar: const AppNavbar(currentRoute: RoutePaths.createCapsule),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Create Time Capsule',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to Dashboard'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    maxLength: AppConstants.capsuleTitleMaxLength,
                    decoration:
                        const InputDecoration(labelText: 'Capsule Title'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Delivery Date & Time',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(dateLabel),
                  ),
                  if (_dateError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _dateError!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text('Your Message',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  RichTextEditor(
                    controller: _quillController,
                    onLengthChanged: (length) {
                      setState(() => _bodyLength = length);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_bodyLength / ${AppConstants.capsuleBodyMaxLength} characters',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  MediaRecorder(
                    photo: _photo,
                    video: _video,
                    audio: _audio,
                    onAdded: (attachment) {
                      setState(() {
                        if (attachment.type == MediaType.photo) {
                          _photo = attachment;
                        } else if (attachment.type == MediaType.video) {
                          _video = attachment;
                        } else if (attachment.type == MediaType.audio) {
                          _audio = attachment;
                        }
                      });
                    },
                    onRemoved: (type) {
                      setState(() {
                        if (type == MediaType.photo) {
                          _photo = null;
                        } else if (type == MediaType.video) {
                          _video = null;
                        } else if (type == MediaType.audio) {
                          _audio = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Schedule Message'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
