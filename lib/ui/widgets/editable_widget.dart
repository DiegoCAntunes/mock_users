import 'package:flutter/material.dart';

class EditableTextWidget extends StatefulWidget {
  final String initialText;
  final Function(String) onSubmitted;

  const EditableTextWidget({
    Key? key,
    required this.initialText,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  _EditableTextWidgetState createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant EditableTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText) {
      _controller.text = widget.initialText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isEditing = true),
      child: _isEditing
          ? TextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (newValue) {
                widget.onSubmitted(newValue);
                setState(() => _isEditing = false);
              },
              maxLines: null,
            )
          : Text(_controller.text),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
