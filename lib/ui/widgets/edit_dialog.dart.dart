import 'package:flutter/material.dart';
import 'package:mock_users/presenter/list_data/data_read.dart';

class EditDialog extends StatefulWidget {
  final PessoaStruct pessoa;
  final void Function(PessoaStruct) onUpdate;

  const EditDialog({
    Key? key,
    required this.pessoa,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late PessoaStruct _editedPessoa;

  @override
  void initState() {
    super.initState();
    _editedPessoa = widget.pessoa;
  }

  Widget _buildTextField(
      String label, String value, Function(String) onChanged) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }

  String bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  List<int> hexToBytes(String hex) {
    var bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      var byteString = hex.substring(i, i + 2);
      var byteValue = int.parse(byteString, radix: 16);
      bytes.add(byteValue);
    }
    return bytes;
  }

  Widget _buildByteField(
      String label, List<int> byteValue, Function(List<int>) onChanged) {
    return TextFormField(
      initialValue: bytesToHex(byteValue),
      onChanged: (val) => onChanged(hexToBytes(val)),
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildTextField('Parent ID', _editedPessoa.iIDPai.toString(),
                (val) => _editedPessoa.iIDPai = int.parse(val)),
            _buildTextField('Name', _editedPessoa.vbNome,
                (val) => _editedPessoa.vbNome = val),
            _buildTextField('Type', _editedPessoa.bTipo,
                (val) => _editedPessoa.bTipo = val),
            _buildTextField('Password', _editedPessoa.vbSenha,
                (val) => _editedPessoa.vbSenha = val),
            _buildTextField('RFID', _editedPessoa.vbRfid,
                (val) => _editedPessoa.vbRfid = val),
            _buildTextField(
                'NFC', _editedPessoa.vbNfc, (val) => _editedPessoa.vbNfc = val),
            _buildTextField(
                'Pav', _editedPessoa.vbPav, (val) => _editedPessoa.vbPav = val),
            _buildTextField('Weekday', _editedPessoa.bDiaSemana,
                (val) => _editedPessoa.bDiaSemana = int.parse(val)),
            _buildByteField('Initial Hour', _editedPessoa.vbHrInicial,
                (val) => _editedPessoa.vbHrInicial = val),
            _buildByteField('Final Hour', _editedPessoa.vbHrFinal,
                (val) => _editedPessoa.vbHrFinal = val),
            _buildTextField(
                'Can Register',
                _editedPessoa.bPodeCadastrar.toString(),
                (val) => _editedPessoa.bPodeCadastrar = int.parse(val)),
            _buildTextField(
              'Can Release',
              _editedPessoa.bPodeLiberar.toString(),
              (val) => _editedPessoa.bPodeLiberar = int.parse(val),
            ),
            _buildTextField(
              'Edited',
              _editedPessoa.bEditado.toString(),
              (val) => _editedPessoa.bEditado = int.parse(val),
            ),
            /*_buildByteField(
              'Apartment',
              _editedPessoa.bApartamento,
              (val) => _editedPessoa.bApartamento = val,
            ),
            _buildTextField(
              'Version',
              _editedPessoa.vbVersao,
              (val) => _editedPessoa.vbVersao = val,
            ),
            _buildByteField(
              'Initial Date Time',
              _editedPessoa.vbDataHoraInicial,
              (val) => _editedPessoa.vbDataHoraInicial = val,
            ),
            _buildByteField(
              'Final Date Time',
              _editedPessoa.vbDataHoraFinal,
              (val) => _editedPessoa.vbDataHoraFinal = val,
            ),*/
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            widget.onUpdate(_editedPessoa);
          },
        ),
      ],
    );
  }
}
