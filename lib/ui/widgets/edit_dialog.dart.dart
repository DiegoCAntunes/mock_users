import 'package:flutter/material.dart';
import 'package:mock_users/presenter/list_data/data_read.dart';

class EditDialog extends StatefulWidget {
  final PessoaStruct pessoa;
  final void Function(PessoaStruct) onUpdate;

  const EditDialog({
    Key? key,
    required this.pessoa,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late PessoaStruct _editedPessoa;

  @override
  void initState() {
    super.initState();
    _editedPessoa = widget.pessoa;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextFormField(
              initialValue: _editedPessoa.vbNome,
              onChanged: (value) {
                setState(() {
                  _editedPessoa.vbNome = value;
                });
              },
              decoration: InputDecoration(labelText: 'Name'),
            ),
            // Add more TextFormFields for other fields of PessoaStruct
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            widget.onUpdate(_editedPessoa);
          },
        ),
      ],
    );
  }
}
