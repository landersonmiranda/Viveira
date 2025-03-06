import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:projeto_viviera/controllers/visualizar_controller.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';
import 'package:projeto_viviera/screens/home_layout.dart';

class EditarEstudantePage extends ConsumerStatefulWidget {
  final String estudanteId;

  const EditarEstudantePage({super.key, required this.estudanteId});

  @override
  EditarEstudantePageState createState() => EditarEstudantePageState();
}

class EditarEstudantePageState extends ConsumerState<EditarEstudantePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _certidaoController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _restricoesController = TextEditingController();
  final _cuidadosController = TextEditingController();
  final _matriculaController = TextEditingController();
  XFile? _image;

  final _certidaoInputFormatter = MaskTextInputFormatter(
    mask: '######.##.##.####.#.#####.###.#######-##', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );
  
  final _rgInputFormatter = MaskTextInputFormatter(
    mask: '##.###.###-#', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  final _cpfInputFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _carregarEstudante();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _carregarEstudante() async {
    var estudante = await VisualizarController().buscarEstudante(widget.estudanteId);
    _nomeController.text = estudante['nome'] ?? '';
    _matriculaController.text = estudante['matricula'] ?? '';
    var dataNascimento = estudante['dataNascimento'];
    if (dataNascimento != null) {
      if (dataNascimento is Timestamp) {
        var dateTime = dataNascimento.toDate();
        _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(dateTime);
      } else if (dataNascimento is DateTime) {
        _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(dataNascimento);
      }
    }
    _cpfController.text = estudante['cpf'] ?? '';
    _rgController.text = estudante['rg'] ?? '';
    _certidaoController.text = estudante['certidao'] ?? '';
    _alergiasController.text = estudante['alergias'] ?? '';
    _restricoesController.text = estudante['restricoes'] ?? '';
    _cuidadosController.text = estudante['cuidados'] ?? '';
  }

  Future<void> _salvarEstudante() async {
    try {
      String dataNascimentoStr = _dataNascimentoController.text;
      DateTime dataNascimento = DateFormat('dd/MM/yyyy').parse(dataNascimentoStr);
      Timestamp timestampDataNascimento = Timestamp.fromDate(dataNascimento);

      await FirebaseFirestore.instance
          .collection('estudantes')
          .doc(widget.estudanteId)
          .update({
        'nome': _nomeController.text,
        'matricula': _matriculaController.text,
        'cpf': _cpfController.text,
        'rg': _rgController.text,
        'certidao': _certidaoController.text,
        'alergias': _alergiasController.text,
        'restricoes': _restricoesController.text,
        'cuidados': _cuidadosController.text,
        'dataNascimento': timestampDataNascimento,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estudante editado com sucesso!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao editar estudante')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    
    onTapFunction({required BuildContext context}) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        lastDate: DateTime.now(),
        firstDate: DateTime(1900),
        initialDate: _dataNascimentoController.text.isEmpty ? DateTime.now() : DateFormat('dd/MM/yyyy').parse(_dataNascimentoController.text),
        locale: const Locale('pt', 'BR')
      );
      if (pickedDate != null) {
      _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
  }
    }

    return HomeLayout(  // Envolvendo com o HomeLayout
      title: 'Editar - Estudante',  // Passando o título
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: PageView(
            controller: _pageController,
            children: [
              Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: _pickImage,
                    child: _image == null
                        ? CircleAvatar(radius: 50, child: Icon(Icons.add_a_photo))
                        : CircleAvatar(radius: 50, backgroundImage: FileImage(File(_image!.path))),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUnfocus,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _dataNascimentoController,
                    decoration: InputDecoration(labelText: 'Data de Nascimento'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a data de nascimento';
                      }
                      return null;
                    },
                    onTap: () => onTapFunction(context: context),
                    autovalidateMode: AutovalidateMode.onUnfocus,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _matriculaController,
                    decoration: InputDecoration(labelText: 'Matrícula'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a matrícula';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUnfocus,
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Documentos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextFormField(
                    controller: _cpfController,
                    decoration: InputDecoration(labelText: 'CPF'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o CPF';
                      }
                      if(_cpfInputFormatter.getUnmaskedText().length < 11) {
                        return 'São necessários 11 dígitos para o CPF';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    inputFormatters: [_cpfInputFormatter],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _rgController,
                    decoration: InputDecoration(labelText: 'RG'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o RG';
                      }
                      if(_rgInputFormatter.getUnmaskedText().length < 9) {
                        return 'São necessários 9 dígitos para o RG';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    inputFormatters: [_rgInputFormatter],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _certidaoController,
                    decoration: InputDecoration(labelText: 'Certidão'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a certidão';
                      }
                      if(_certidaoInputFormatter.getUnmaskedText().length < 32) {
                        return 'São necessários 32 dígitos para a certidão';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    inputFormatters: [_certidaoInputFormatter],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _salvarEstudante,
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
