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
  final int targetRecords = 4000 - 109;
  int currentId = 110;

  Future<void> completeFileWithRecords(String filePath) async {
    var directory = File(filePath).parent;
    var newFileName = 'new_${File(filePath).uri.pathSegments.last}';
    var newFile = File('${directory.path}/$newFileName');

    await newFile.create(recursive: true); // Ensure the new file exists
    var sink = newFile.openWrite(mode: FileMode.write);

    print("Started appending records to the file...");
    for (int i = 0; i < targetRecords; i++) {
      Uint8List recordBytes = Uint8List(recordSize);
      ByteData byteData = ByteData.sublistView(recordBytes);

      // Example: Writing random iID and iIDPai (2 bytes each)
      byteData.setUint16(0, currentId++, Endian.little);
      byteData.setUint16(2, random.nextInt(65536), Endian.little);

      // vbNome
      String name = faker.person.firstName();
      List<int> nameBytes = utf8.encode(name);
      recordBytes.setRange(4, 4 + min(nameBytes.length, 30), nameBytes);

      // vbSenha (Password)
      // Generate a password "00" followed by 6 digits
      String rawPassword =
          "00${List.generate(6, (_) => random.nextInt(10)).join()}";
      Uint8List passwordBytes = Uint8List.fromList(utf8.encode(rawPassword));
      converteSenha(passwordBytes); // Apply conversion
      recordBytes.setRange(
          34, 42, passwordBytes); // Set the converted password in the record

      // Fill the rest of the fields with random data for simplicity
      for (int j = 42; j < recordBytes.length; j++) {
        recordBytes[j] = random.nextInt(256);
      }

      // Append the generated record to the file
      sink.add(recordBytes);
    }

    await sink.flush();
    await sink.close();

    print("Completed. New file with updated records: ${newFile.path}");
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
