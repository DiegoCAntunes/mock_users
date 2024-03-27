// app_logic.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mock_users/presenter/list_data/data_create.dart';
import 'package:mock_users/presenter/list_data/data_read.dart';

class AppLogic {
  final DataReader _dataReader = DataReader();
  final DataCreate _dataCreate = DataCreate();
  List<PessoaStruct> records = [];
  String filePath = "";

  Future<List<PessoaStruct>> readFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      filePath = result.files.single.path ?? "";
      if (filePath.isNotEmpty) {
        records = _dataReader
            .parseBinFile(filePath); // Directly get the list of records
      }
    } else {
      print("No file selected");
    }
    return records;
  }

  Future<void> completeList(BuildContext context) async {
    if (filePath != "") {
      DataCreate dataCreate = DataCreate();
      await dataCreate.completeFileWithRecords(filePath);
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
              title: Text(
                  "Arquivo completo! Salvo na mesma pasta do arquivo original")));
    }
  }
}
