import 'package:flutter/material.dart';
import 'package:mock_users/presenter/app_logic/app_logic.dart';
import 'package:mock_users/ui/widgets/edit_dialog.dart.dart';

import '../../presenter/list_data/data_read.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<AppScreen> {
  String previewData = "Preview Data";
  final AppLogic _appLogic = AppLogic();
  String _fileContent = "Preview";
  String filePath = "";

  void _handleReadFile() async {
    String data = await _appLogic.readFile();
    setState(() {
      _fileContent = data;
    });
  }

  void _handleCompleteList() async {
    await _appLogic.completeList(context);
  }

  void _showEditDialog(BuildContext context, PessoaStruct pessoa, int index) {
    EditDialog.show(context, pessoa, index, (updatedRecord) {
      setState(() {
        // Update the record in your data list
        _appLogic.records[index] = updatedRecord;
        // Update the file with the edited data (you need to implement this logic)
        _dataCreate.updateRecord(filePath, index, updatedRecord);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Usuários"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 550,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: ListView.builder(
                  itemCount: _appLogic.records
                      .length, // Assume this is a list of PessoaStruct from your logic
                  itemBuilder: (context, index) {
                    final pessoa = _appLogic.records[index];
                    return ListTile(
                      title: Text(pessoa
                          .toString()), // This should display a summary of your PessoaStruct
                      onTap: () {
                        _showEditDialog(
                            context, pessoa, index); // Implement this method
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _handleReadFile,
                      child: const Text("Read File"),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: _handleCompleteList,
                      child: const Text("Complete List"),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
