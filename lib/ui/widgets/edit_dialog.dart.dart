import 'package:flutter/material.dart';
import 'package:mock_users/presenter/list_data/data_read.dart';

class EditDialog {
  static void show(BuildContext context, PessoaStruct pessoa, int index,
      Function(PessoaStruct) onSave) {
    TextEditingController iIDController =
        TextEditingController(text: pessoa.iID.toString());
    TextEditingController iIDPaiController =
        TextEditingController(text: pessoa.iIDPai.toString());
    TextEditingController vbNomeController =
        TextEditingController(text: pessoa.vbNome);
    TextEditingController bTipoController =
        TextEditingController(text: pessoa.bTipo);
    TextEditingController vbSenhaController =
        TextEditingController(text: pessoa.vbSenha);
    TextEditingController vbRfidController =
        TextEditingController(text: pessoa.vbRfid);
    TextEditingController vbNfcController =
        TextEditingController(text: pessoa.vbNfc);
    TextEditingController vbPavController =
        TextEditingController(text: pessoa.vbPav);
    TextEditingController bDiaSemanaController =
        TextEditingController(text: pessoa.bDiaSemana);
    TextEditingController vbHrInicialController =
        TextEditingController(text: pessoa.vbHrInicial);
    TextEditingController vbHrFinalController =
        TextEditingController(text: pessoa.vbHrFinal);
    TextEditingController bPodeCadastrarController =
        TextEditingController(text: pessoa.bPodeCadastrar);
    TextEditingController bPodeLiberarController =
        TextEditingController(text: pessoa.bPodeLiberar);
    TextEditingController bEditadoController =
        TextEditingController(text: pessoa.bEditado);
    TextEditingController bApartamentoController =
        TextEditingController(text: pessoa.bApartamento);
    TextEditingController vbVersaoController =
        TextEditingController(text: pessoa.vbVersao);
    TextEditingController vbDataHoraInicialController =
        TextEditingController(text: pessoa.vbDataHoraInicial);
    TextEditingController vbDataHoraFinalController =
        TextEditingController(text: pessoa.vbDataHoraFinal);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    controller: iIDController,
                    decoration: InputDecoration(labelText: 'iID')),
                TextField(
                    controller: iIDPaiController,
                    decoration: InputDecoration(labelText: 'iIDPai')),
                TextField(
                    controller: vbNomeController,
                    decoration: InputDecoration(labelText: 'vbNome')),
                TextField(
                    controller: bTipoController,
                    decoration: InputDecoration(labelText: 'bTipo')),
                TextField(
                    controller: vbSenhaController,
                    decoration: InputDecoration(labelText: 'vbSenha')),
                TextField(
                    controller: vbRfidController,
                    decoration: InputDecoration(labelText: 'vbRfid')),
                TextField(
                    controller: vbNfcController,
                    decoration: InputDecoration(labelText: 'vbNfc')),
                TextField(
                    controller: vbPavController,
                    decoration: InputDecoration(labelText: 'vbPav')),
                TextField(
                    controller: bDiaSemanaController,
                    decoration: InputDecoration(labelText: 'bDiaSemana')),
                TextField(
                    controller: vbHrInicialController,
                    decoration: InputDecoration(labelText: 'vbHrInicial')),
                TextField(
                    controller: vbHrFinalController,
                    decoration: InputDecoration(labelText: 'vbHrFinal')),
                TextField(
                    controller: bPodeCadastrarController,
                    decoration: InputDecoration(labelText: 'bPodeCadastrar')),
                TextField(
                    controller: bPodeLiberarController,
                    decoration: InputDecoration(labelText: 'bPodeLiberar')),
                TextField(
                    controller: bEditadoController,
                    decoration: InputDecoration(labelText: 'bEditado')),
                TextField(
                    controller: bApartamentoController,
                    decoration: InputDecoration(labelText: 'bApartamento')),
                TextField(
                    controller: vbVersaoController,
                    decoration: InputDecoration(labelText: 'vbVersao')),
                TextField(
                    controller: vbDataHoraInicialController,
                    decoration:
                        InputDecoration(labelText: 'vbDataHoraInicial')),
                TextField(
                    controller: vbDataHoraFinalController,
                    decoration: InputDecoration(labelText: 'vbDataHoraFinal')),
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
                onSave(PessoaStruct(
                  iID: int.parse(iIDController.text),
                  iIDPai: int.parse(iIDPaiController.text),
                  vbNome: vbNomeController.text,
                  bTipo: bTipoController.text,
                  vbSenha: vbSenhaController.text,
                  vbRfid: vbRfidController.text,
                  vbNfc: vbNfcController.text,
                  vbPav: vbPavController.text,
                  bDiaSemana: bDiaSemanaController.text,
                  vbHrInicial: vbHrInicialController.text,
                  vbHrFinal: vbHrFinalController.text,
                  bPodeCadastrar: bPodeCadastrarController.text,
                  bPodeLiberar: bPodeLiberarController.text,
                  bEditado: bEditadoController.text,
                  bApartamento: bApartamentoController.text,
                  vbVersao: vbVersaoController.text,
                  vbDataHoraInicial: vbDataHoraInicialController.text,
                  vbDataHoraFinal: vbDataHoraFinalController.text,
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
