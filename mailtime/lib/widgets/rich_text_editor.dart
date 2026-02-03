import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../utils/constants.dart';

class RichTextEditor extends StatefulWidget {
  const RichTextEditor({
    super.key,
    required this.controller,
    required this.onLengthChanged,
  });

  final quill.QuillController controller;
  final ValueChanged<int> onLengthChanged;

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    final length = widget.controller.document.toPlainText().trim().length;
    widget.onLengthChanged(length);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        quill.QuillSimpleToolbar(
          controller: widget.controller,
          config: const quill.QuillSimpleToolbarConfig(
            showAlignmentButtons: true,
            showColorButton: true,
            showBackgroundColorButton: true,
            showCodeBlock: false,
            showInlineCode: false,
            showSearchButton: false,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: quill.QuillEditor.basic(
            controller: widget.controller,
            config: const quill.QuillEditorConfig(
              placeholder: 'Write your message to your future self...',
            ),
          ),
        ),
      ],
    );
  }
}

class RichTextViewer extends StatelessWidget {
  const RichTextViewer({super.key, required this.documentJson});

  final String documentJson;

  @override
  Widget build(BuildContext context) {
    final doc = _documentFromPayload(documentJson);
    final controller = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: quill.QuillEditor.basic(
        controller: controller,
        config: const quill.QuillEditorConfig(
          scrollable: false,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  quill.Document _documentFromPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is List) {
        return quill.Document.fromJson(decoded);
      }
    } catch (_) {}
    return quill.Document()..insert(0, payload);
  }
}

class RichTextSerializer {
  static String toJson(quill.Document document) {
    final delta = document.toDelta().toJson();
    return jsonEncode(delta);
  }

  static bool isWithinLimit(quill.Document document) {
    final length = document.toPlainText().trim().length;
    return length <= AppConstants.capsuleBodyMaxLength;
  }
}
