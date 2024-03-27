import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

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
    List<int> senhaBytes = utf8.encode(vbSenha);
    recordBytes.setRange(
        offset, offset + min(senhaBytes.length, 8), senhaBytes);
    offset += 8;

    // Encode vbRfid to UTF-8 and ensure it doesn't exceed 8 bytes
    List<int> rfidBytes = utf8.encode(vbRfid);
    recordBytes.setRange(offset, offset + min(rfidBytes.length, 8), rfidBytes);
    offset += 8;

    // Encode vbNfc to UTF-8 and ensure it doesn't exceed 6 bytes
    List<int> nfcBytes = utf8.encode(vbNfc);
    recordBytes.setRange(offset, offset + min(nfcBytes.length, 6), nfcBytes);
    offset += 6;

    List<int> pavBytes = utf8.encode(vbPav);
    recordBytes.setRange(offset, offset + min(pavBytes.length, 16), pavBytes);
    offset += 16;

    byteData.setUint8(offset, int.parse(bDiaSemana));
    offset += 1;

    List<String> hrInicialParts = vbHrInicial.split(':');
    byteData.setUint8(offset, int.parse(hrInicialParts[0]));
    offset += 1;
    byteData.setUint8(offset, int.parse(hrInicialParts[1]));
    offset += 1;

    List<String> hrFinalParts = vbHrFinal.split(':');
    byteData.setUint8(offset, int.parse(hrFinalParts[0]));
    offset += 1;
    byteData.setUint8(offset, int.parse(hrFinalParts[1]));
    offset += 1;

    byteData.setUint8(offset, int.parse(bPodeCadastrar));
    offset += 1;
    byteData.setUint8(offset, int.parse(bPodeLiberar));
    offset += 1;
    byteData.setUint8(offset, int.parse(bEditado));
    offset += 1;

    List<int> apartamentoBytes = utf8.encode(bApartamento);
    recordBytes.setRange(
        offset, offset + min(apartamentoBytes.length, 6), apartamentoBytes);
    offset += 6;

    byteData.setUint8(offset, int.parse(vbVersao));
    offset += 1;

    List<int> dataHoraInicialBytes = utf8.encode(vbDataHoraInicial);
    recordBytes.setRange(offset, offset + min(dataHoraInicialBytes.length, 4),
        dataHoraInicialBytes);
    offset += 4;

    List<int> dataHoraFinalBytes = utf8.encode(vbDataHoraFinal);
    recordBytes.setRange(
        offset, offset + min(dataHoraFinalBytes.length, 4), dataHoraFinalBytes);

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

      String vbHrInicial = fileBytes.sublist(offset, offset + 2).toString();
      offset += 2;

      String vbHrFinal = fileBytes.sublist(offset, offset + 2).toString();
      offset += 2;

      String bPodeCadastrar = buffer.getUint8(offset).toString();
      offset += 1;

      String bPodeLiberar = buffer.getUint8(offset).toString();
      offset += 1;

      String bEditado = buffer.getUint8(offset).toString();
      offset += 1;

      String bApartamento = fileBytes.sublist(offset, offset + 6).toString();
      offset += 6;

      String vbVersao = buffer.getUint8(offset).toString();
      offset += 1;

      String vbDataHoraInicial =
          fileBytes.sublist(offset, offset + 4).toString();
      offset += 4;

      String vbDataHoraFinal = fileBytes.sublist(offset, offset + 4).toString();
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
