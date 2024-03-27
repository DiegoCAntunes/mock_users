import 'dart:io';
import 'dart:typed_data';

class PessoaStruct {
  int iID;
  int iIDPai;
  String vbNome;
  String bTipo;
  String vbSenha;

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
