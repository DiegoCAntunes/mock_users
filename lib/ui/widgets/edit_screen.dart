import 'package:flutter/material.dart';

import '../../presenter/list_data/data_read.dart';

class EditPessoaScreen extends StatefulWidget {
  final PessoaStruct pessoa;

  const EditPessoaScreen({Key? key, required this.pessoa}) : super(key: key);

  @override
  _EditPessoaScreenState createState() => _EditPessoaScreenState();
}

class _EditPessoaScreenState extends State<EditPessoaScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pessoa.vbNome);
    // Initialize other controllers for each field
  }

  @override
  void dispose() {
    _nameController.dispose();
    // Dispose other controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.pessoa.vbNome}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name')),
            // Add TextFields for other fields in PessoaStruct
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save logic
                Navigator.pop(
                    context); // Go back to the previous screen with updated data
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
