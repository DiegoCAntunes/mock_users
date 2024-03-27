import 'package:flutter/material.dart';
import 'package:mock_users/presenter/app_logic/app_logic.dart';
import 'package:mock_users/presenter/list_data/data_read.dart';
import 'package:mock_users/ui/widgets/edit_dialog.dart.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<AppScreen> {
  final AppLogic _appLogic = AppLogic();
  String filePath = "";

  void _handleReadFile() async {
    List<PessoaStruct> data = await _appLogic.readFile();
    setState(() {
      _appLogic.records = data;
      filePath = _appLogic.filePath;
    });
  }

  void _handleCompleteList() async {
    await _appLogic.completeList(context);
  }

  void _showEditDialog(BuildContext context, PessoaStruct pessoa, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDialog(
          pessoa: pessoa,
          onUpdate: (PessoaStruct updatedPessoa) {
            setState(() {
              _appLogic.updateRecord(filePath, index, updatedPessoa);
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
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
                  itemCount: _appLogic.records.length,
                  itemBuilder: (context, index) {
                    final pessoa = _appLogic.records[index];
                    return ListTile(
                      title: Text(pessoa.toString()),
                      onTap: () {
                        _showEditDialog(context, pessoa, index);
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
