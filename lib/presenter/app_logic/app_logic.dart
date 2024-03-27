// app_logic.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mock_users/presenter/list_data/data_create.dart';
import 'package:mock_users/presenter/list_data/data_read.dart';

class AppLogic {
  final DataReader _dataReader = DataReader();
  int recordSize = 96;
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

  void updateRecord(String filePath, int index, PessoaStruct updatedRecord) {
    int recordSize = 96; // Ensure this matches the actual size of your records
    int offset = index * recordSize;

    try {
      // Open the file for reading and writing, without truncating
      RandomAccessFile raf = File(filePath).openSync(mode: FileMode.append);

      // Move the file pointer to the start position of the record to update
      raf.setPositionSync(offset);

      // Convert the updated record into bytes
      Uint8List recordBytes = updatedRecord.toBytes();
      if (recordBytes.length != recordSize) {
        throw Exception("Record byte length does not match expected size.");
      }

      // Write the bytes to the file at the correct position
      raf.writeFromSync(recordBytes);

      // Ensure changes are written to the file
      raf.flushSync();

      // Close the file
      raf.closeSync();
    } catch (e) {
      print("Error updating record: $e");
    }
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
