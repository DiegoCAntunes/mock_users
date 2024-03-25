import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:faker/faker.dart';

class DataCreate {
  final Faker faker = Faker();
  final Random random = Random();
  final int recordSize =
      2 + 2 + 30 + 1 + 8 + 8 + 6 + 16 + 1 + 2 + 2 + 1 + 1 + 1 + 6 + 1 + 4 + 4;
  int lastId = 109;
  int targetRecords = 0;
  int currentId = 110;
  int currentRfidIndex = 0;

  Future<void> completeFileWithRecords(String originalFilePath) async {
    File originalFile = File(originalFilePath);

    // Prepare to read existing data from the original file
    Uint8List existingData = Uint8List(0);
    if (await originalFile.exists()) {
      print("Reading existing data...");
      existingData = await originalFile.readAsBytes();
      final recordCount = existingData.length ~/ recordSize;
      for (int i = 0; i < recordCount; i++) {
        final id = ByteData.sublistView(
                existingData, i * recordSize, i * recordSize + 2)
            .getUint16(0, Endian.little);
        if (id > lastId) lastId = id; // Update lastId if this ID is higher
        targetRecords = 4001 - lastId;
      }
    }

    // Directory of the original file
    var directory = originalFile.parent;

    // New file name based on the original file's name
    var newFileName = 'new_${originalFile.uri.pathSegments.last}';
    var newFile = File('${directory.path}/$newFileName');

    // Ensure the new file exists
    await newFile.create(recursive: true);

    // Open the sink for writing both existing and new data
    var sink = newFile.openWrite(mode: FileMode.write);
    print("Started writing to the new file...");

    // First, write the existing data to the new file
    if (existingData.isNotEmpty) {
      sink.add(existingData);
    }

    // Generate and append new records to the new file
    for (int i = 0; i < targetRecords; i++) {
      Uint8List recordBytes = Uint8List(recordSize);
      ByteData byteData = ByteData.sublistView(recordBytes);

      // Populate the byte data for each record...
      byteData.setUint16(0, lastId++, Endian.little);
      byteData.setUint16(2, random.nextInt(65536), Endian.little);

      // vbNome
      String name = faker.person.firstName();
      List<int> nameBytes = utf8.encode(name);
      recordBytes.setRange(4, 4 + min(nameBytes.length, 30), nameBytes);

      // bTipo
      recordBytes[34] = random.nextInt(9);

      // vbSenha (Password)
      String rawPassword =
          "${(random.nextInt(10) + 1).toString().padLeft(2, '0')}${List.generate(6, (_) => random.nextInt(10)).join()}";

      Uint8List passwordBytes = Uint8List.fromList(utf8.encode(rawPassword));
      converteSenha(passwordBytes); // Apply conversion
      recordBytes.setRange(
          35, 43, passwordBytes); // Set the converted password in the record

      // vbRfid
      Uint8List rfid = Uint8List(8); // Start with all bytes set to 0
      rfid[currentRfidIndex] = 1; // Set one byte to 1

      // Assuming the RFID comes right after the password:
      int rfidStartPos = 44;
      recordBytes.setRange(rfidStartPos, rfidStartPos + 8, rfid);

      // Prepare for the next record
      currentRfidIndex = (currentRfidIndex + 1) % 8;

      // Fill the rest of the fields with random data for simplicity
      for (int j = 52; j < recordBytes.length; j++) {
        recordBytes[j] = random.nextInt(256);
      }

      // Append the generated record to the new file
      sink.add(recordBytes);
    }

    await sink.flush();
    await sink.close();

    print("Completed. New file with all records: ${newFile.path}");
  }

  void converteSenha(Uint8List pt) {
    int aux;
    Uint8List senha = Uint8List(8);

    for (aux = 0; aux < 6; aux++) {
      pt[7 - aux] = pt[5 - aux];
    }

    aux = pt[6];
    pt[6] = pt[2];
    pt[2] = aux;

    aux = pt[5];
    pt[5] = pt[3];
    pt[3] = aux;

    aux = pt[7];
    pt[7] = pt[4];
    pt[4] = aux;

    pt[0] = (pt[2] ^ pt[4]) + 3; // byte dummy
    pt[1] = (pt[3] ^ pt[5]) + 3; // byte dummy

    senha.setAll(0, pt);

    pt[2] = pt[2] ^ 'K'.codeUnitAt(0);
    pt[3] = pt[3] ^ senha[2];
    pt[4] = pt[4] ^ senha[3];
    pt[5] = pt[5] ^ senha[4];
    pt[6] = pt[6] ^ senha[5];
    pt[7] = pt[7] ^ senha[6];
  }
}
