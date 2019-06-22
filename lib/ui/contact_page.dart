import 'dart:io';

import 'package:app_agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  // Construtor - serve para ao clicar em editar ou criar a pagina ja vai abrir com os dados do contato
  ContactPage({this.contact}
      // colocando o atributo entre {} fica opcional (não obrigatorio)
      );

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  //controladores para pegar os dados digitados
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Cria um foco para o campo name por ser um campo obrigatorio e é redirecionado para o campo
  final _nameFocus = FocusNode();

  // verifica se o usuario editou algo
  bool _userEdited = false;

  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      // Utilizadon o widget.xxxxx é possivel acessar o atributo de outra classe, neste caso foi o atributo contact da classe ContactPage
      _editedContact =
          Contact(); // if contato for nulo, entao cria um novo contato
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(  // controla a seta que aparece automaticamento para volta de pagina
        onWillPop: _requestPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey,
            title: Text(_editedContact.name ?? "Novo Contato"),
            centerTitle: true,
          ), // AppBar
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // valida os dados digitados
              if (_editedContact.name != null &&
                  _editedContact.name.isNotEmpty) {
                Navigator.pop(context,
                    _editedContact); // Navigator funciona como uma pilha, o pop retira a tela contact_page e o _editedContact envia os dados para a proxima tela
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.grey,
          ), // FloatingActionButton
          body: SingleChildScrollView(
            // utilizado para o teclado nao cubrir os campos
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                GestureDetector( // permite ser clicavel
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            // se o usuario tiver a imagem ele a carrega senao carrega a imagem padrao
                            image: _editedContact.img != null
                                ? FileImage(File(_editedContact.img))
                                : AssetImage(
                                    "images/person.png"),
                            fit: BoxFit.cover // deixa a imagen 100% redonda
                        ) // DecorationImage
                      ), // BoxDecoration
                  ), // Container
                  onTap: (){
                    ImagePicker.pickImage(source: ImageSource.camera).then((file){ // importa plugin ImagePaker - esta opção abilita a camera para tirar a foto
                      if(file == null) return;
                      setState(() {
                        _editedContact.img = file.path;  // pega o caminho da foto tirada e a apresenta
                      });
                      });
                  }
                ), // GestureDetector
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (text) {
                    _userEdited = true; // se editou algo entao seta com true
                    setState(() {
                      // altera o nome sincronizando de acordo com o que é digitado no campo nome
                      _editedContact.name = text;
                    });
                  },
                  maxLength: 18,
                ), // TextField
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (text) {
                    _userEdited = true; // se editou algo entao seta com true
                    _editedContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                  // coloca mascara formato de email
                  maxLength: 30,
                ), // TextField
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Phone"),
                  onChanged: (text) {
                    _userEdited = true; // se editou algo entao seta com true
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                  // coloca mascara formato de email
                  maxLength: 15,
                ), // TextField
              ], // <Widget>
            ), // Column
          ), // SingleChildScrollView
        ) // Scaffold
      ); // WillPopScope
  }

  /** Função do AlertDialogo  */
  Future<bool> _requestPop(){
    if (_userEdited){
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas"),
              actions: <Widget>[
                FlatButton(
                    child: Text("Cancelar"),
                    onPressed: (){
                      Navigator.pop(context); // retira a tela(camada) do AlertDialog
                    },
                ), // FlatButton
                FlatButton(
                    child: Text("Sim"),
                    onPressed: (){
                      Navigator.pop(context); // retira a tela(camada) do AlertDialog
                      Navigator.pop(context); // retira a tela(camada) do contact_page
                    },
                ) // FlatButton
              ], // <Widget>
            ); // AlertDialog
          }
      );
      return Future.value(false); // nao deixa sair da tela qse teve alguma modificação
    } else {
      return Future.value(true); // libera saida automatica da tela senao houver alteração
    }
  }

}
