import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:mock_users/presenter/list_data/data_create.dart';

class PessoaStruct {
  int iID;
  int iIDPai;
  String vbNome;
  String bTipo;
  String vbSenha;
  int recordSize = 96;

  var vbRfid;
  var vbNfc;
  var vbHrFinal;
  var vbPav;
  var bDiaSemana;
  var vbHrInicial;
  var bPodeLiberar;
  var bPodeCadastrar;
  var bEditado;
  var bApartamento;
  var vbVersao;
  var vbDataHoraInicial;
  var vbDataHoraFinal;

  PessoaStruct({
    required this.iID,
    required this.iIDPai,
    required this.vbNome,
    required this.bTipo,
    required this.vbSenha,
    required this.vbRfid,
    required this.vbNfc,
    required this.vbPav,
    required this.bDiaSemana,
    required this.vbHrInicial,
    required this.vbHrFinal,
    required this.bPodeCadastrar,
    required this.bPodeLiberar,
    required this.bEditado,
    required this.bApartamento,
    required this.vbVersao,
    required this.vbDataHoraInicial,
    required this.vbDataHoraFinal,
  });

  @override
  String toString() {
    List<String> numbers = vbPav.split(',');
    String firstFourNumbers = numbers.take(4).join(',');
    return '$iID / $vbNome / $bTipo / $vbSenha / $vbRfid / $firstFourNumbers...';
  }

  Uint8List toBytes() {
    Uint8List recordBytes = Uint8List(recordSize);
    ByteData byteData = ByteData.sublistView(recordBytes);

    int offset = 0;

    byteData.setUint16(offset, iID, Endian.little);
    offset += 2;

    byteData.setUint16(offset, iIDPai, Endian.little);
    offset += 2;

    // Encode vbNome to UTF-8 and ensure it doesn't exceed 30 bytes
    List<int> nameBytes = utf8.encode(vbNome);
    recordBytes.setRange(offset, offset + min(nameBytes.length, 30), nameBytes);
    offset += 30;

    // Convert bTipo to int and set as uint8
    byteData.setUint8(offset, int.parse(bTipo));
    offset += 1;

    // Encode vbSenha to UTF-8 and ensure it doesn't exceed 8 bytes
    String adjustedSenha = '${vbSenha}00';
    List<int> senhaBytes = utf8.encode(adjustedSenha);
    Uint8List passwordBytes = Uint8List.fromList(senhaBytes);
    DataCreate.converteSenha(passwordBytes);
    recordBytes.setRange(offset, offset + 8, passwordBytes);
    offset += 8;

    // Encode vbRfid to UTF-8 and ensure it doesn't exceed 8 bytes
    List<int> rfidBytes = vbRfid
        .split('.')
        .map((segment) => int.tryParse(segment) ?? 0)
        .toList()
        .cast<int>();

    rfidBytes =
        List<int>.generate(8, (i) => i < rfidBytes.length ? rfidBytes[i] : 0);

    recordBytes.setRange(offset, offset + 8, rfidBytes);
    offset += 8;

    // Encode vbNfc to UTF-8 and ensure it doesn't exceed 6 bytes
    List<int> nfcBytes = vbNfc
        .split('.')
        .map((segment) => int.tryParse(segment) ?? 0)
        .toList()
        .cast<int>();

    nfcBytes =
        List<int>.generate(6, (i) => i < nfcBytes.length ? nfcBytes[i] : 0);

    recordBytes.setRange(offset, offset + 6, nfcBytes);

    offset += 6;

    List<int> pavBytes =
        vbPav.split(", ").map((part) => int.parse(part)).toList().cast<int>();

    if (pavBytes.length < 16) {
      pavBytes.addAll(List.filled(16 - pavBytes.length, 0));
    } else if (pavBytes.length > 16) {
      pavBytes = pavBytes.sublist(0, 16);
    }
    recordBytes.setRange(offset, offset + 16, pavBytes);
    offset += 16;

    byteData.setUint8(offset, int.parse(bDiaSemana));
    offset += 1;

    recordBytes.setRange(offset, offset + 2, vbHrInicial);
    offset += 2;

    recordBytes.setRange(offset, offset + 2, vbHrFinal);
    offset += 2;

    byteData.setUint8(offset, int.parse(bPodeCadastrar));
    offset += 1;
    byteData.setUint8(offset, int.parse(bPodeLiberar));
    offset += 1;
    byteData.setUint8(offset, int.parse(bEditado));
    offset += 1;

    recordBytes.setRange(offset, offset + 6, bApartamento);
    offset += 6;

    byteData.setUint8(offset, int.parse(vbVersao));
    offset += 1;

    recordBytes.setRange(offset, offset + 4, vbDataHoraInicial);
    offset += 4;

    recordBytes.setRange(offset, offset + 4, vbDataHoraFinal);

    return recordBytes;
  }
}

class DataReader {
  Future<String> pickAndReadFile(filePath) async {
    String parsedData = "";

    List<PessoaStruct> dataList = parseBinFile(filePath);
    parsedData = formatDataForDisplay(dataList);

    return parsedData;
  }

  String formatDataForDisplay(List<PessoaStruct> data) {
    return data.map((pessoa) => pessoa.toString()).join('\n');
  }

  List<PessoaStruct> parseBinFile(String filePath) {
    File file = File(filePath);
    final fileBytes = file.readAsBytesSync();
    List<PessoaStruct> records = [];
    int offset = 0;
    const int recordSize = 96;
    final totalSize = fileBytes.length;

    while (offset + recordSize <= totalSize) {
      final buffer = ByteData.sublistView(Uint8List.fromList(fileBytes));

      int iID = buffer.getUint16(offset, Endian.little);
      offset += 2;
      int iIDPai = buffer.getUint16(offset, Endian.little);
      offset += 2;

      String vbNome =
          String.fromCharCodes(fileBytes.sublist(offset, offset + 30))
              .replaceAll('\u0000', '');
      offset += 30;

      String bTipo = buffer.getUint8(offset).toString();
      offset += 1;

      Uint8List passwordSegment =
          Uint8List.fromList(fileBytes.sublist(offset, offset + 8));
      String vbSenha = desconverteSenha(passwordSegment);
      vbSenha = vbSenha.substring(2);

      offset += 8;

      String vbRfid = fileBytes.sublist(offset, offset + 8).toString();
      vbRfid = vbRfid.replaceAll(RegExp(r'[\[\]]'), '');
      vbRfid = vbRfid.replaceAll(', ', '.');

      offset += 8;

      String vbNfc = fileBytes.sublist(offset, offset + 6).toString();
      vbRfid = vbRfid.replaceAll(RegExp(r'[\[\]]'), '');
      vbRfid = vbRfid.replaceAll(', ', '.');

      offset += 6;

      String vbPav = fileBytes.sublist(offset, offset + 16).toString();
      vbPav = vbPav.replaceAll(RegExp(r'[\[\]]'), '');
      offset += 16;

      String bDiaSemana = buffer.getUint8(offset).toString();
      offset += 1;

      List<int> vbHrInicial = [fileBytes[offset], fileBytes[offset + 1]];
      offset += 2;

      List<int> vbHrFinal = [fileBytes[offset], fileBytes[offset + 1]];
      offset += 2;

      String bPodeCadastrar = buffer.getUint8(offset).toString();
      offset += 1;

      String bPodeLiberar = buffer.getUint8(offset).toString();
      offset += 1;

      String bEditado = buffer.getUint8(offset).toString();
      offset += 1;

      List<int> bApartamento = fileBytes.sublist(offset, offset + 6).toList();
      offset += 6;

      String vbVersao = buffer.getUint8(offset).toString();
      offset += 1;

      List<int> vbDataHoraInicial =
          fileBytes.sublist(offset, offset + 4).toList();
      offset += 4;

      List<int> vbDataHoraFinal =
          fileBytes.sublist(offset, offset + 4).toList();
      offset += 4;

      records.add(PessoaStruct(
        iID: iID,
        iIDPai: iIDPai,
        vbNome: vbNome,
        bTipo: bTipo,
        vbSenha: vbSenha,
        vbRfid: vbRfid,
        vbNfc: vbNfc,
        vbPav: vbPav,
        bDiaSemana: bDiaSemana,
        vbHrInicial: vbHrInicial,
        vbHrFinal: vbHrFinal,
        bPodeCadastrar: bPodeCadastrar,
        bPodeLiberar: bPodeLiberar,
        bEditado: bEditado,
        bApartamento: bApartamento,
        vbVersao: vbVersao,
        vbDataHoraInicial: vbDataHoraInicial,
        vbDataHoraFinal: vbDataHoraFinal,
      ));
    }
    return records;
  }
}

String desconverteSenha(Uint8List pt) {
  int aux;

  pt[2] = pt[2] ^ 'K'.codeUnitAt(0);
  pt[3] = pt[3] ^ pt[2];
  pt[4] = pt[4] ^ pt[3];
  pt[5] = pt[5] ^ pt[4];
  pt[6] = pt[6] ^ pt[5];
  pt[7] = pt[7] ^ pt[6];

  aux = pt[7];
  pt[7] = pt[4];
  pt[4] = aux;

  aux = pt[5];
  pt[5] = pt[3];
  pt[3] = aux;

  aux = pt[6];
  pt[6] = pt[2];
  pt[2] = aux;

  return String.fromCharCodes(pt);
}
