import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mock_users/data/list_data/data_create.dart';
import 'package:mock_users/data/list_data/data_read.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<AppScreen> {
  String previewData = "Preview Data";
  final DataReader _dataReader = DataReader();
  String _fileContent = "Preview";
  String filePath = "";

  Future<void> readFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // Directly update the class-level `filePath` variable
      filePath = result.files.single.path ??
          ""; // Use '??' to provide an empty string as a fallback
      print(filePath);
      if (filePath.isNotEmpty) {
        String data = await _dataReader.pickAndReadFile(filePath);

        setState(() {
          _fileContent = data;
        });
      }
    } else {
      print("No file selected");
    }
  }

  void completeList() async {
    print(filePath);
    if (filePath != "") {
      DataCreate dataCreate = DataCreate();
      await dataCreate.completeFileWithRecords(filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My App"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 500,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _fileContent,
                    textAlign: TextAlign.left,
                  ),
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
                      onPressed: readFile,
                      child: const Text("Read File"),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: completeList,
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
