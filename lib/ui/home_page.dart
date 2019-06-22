import 'dart:io';

import 'package:app_agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_page.dart';

enum OrderOptions {orderaz, orderza}  // enumerador é um conjunto de constantes

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //  ContactHelper helper2 = ContactHelper(); // se este objeto fosse criado teria outro banco de dados com seus atributos, mas não é o caso dessa aplicação por ser contruida um singleton, unica instancia na aplicação
  ContactHelper helper = ContactHelper();

 /*
  //foi dado um override em initState para ter o local para colocar o codigo (como se fosse a main) SOMENTE PARA TESTE
  @override
  void initState() {
    super.initState();

   /*
   // teste de criacao de contato no banco
    Contact c = Contact();
    c.name = "Sildes Teixeira";
    c.email = "sildes@hotmail.com";
    c.phone = "55333232223";
    c.img = "imgtest2";
    helper.saveContact(c);*/

     /*// pode utilizar o await ou .then por retornar algo no futuro
     helper.getAllContacts().then((list){
       print(list);
     });*/
    }
  */

  List<Contact> contacts = List();


  // Responsavel por carregar a lista de contatos com carregar a tela
  @override
  void initState() {
    super.initState();

//    helper.getAllContacts().then((list){
//      setState(() { // usado para atualizar a tela
//        contacts = list;
//      });
//    });

    //chama função que busca todos contatos
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.grey,
        centerTitle: true,
        actions: <Widget>[    /* CRIA MENU SUSPENSO PARA FAZER ORDENCAO  */
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ), // PopupMenuItem
              const PopupMenuItem(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              ), // PopupMenuItem
            ], // <PopupMenuEntry<OrderOptions>>
            onSelected: _orderList,
         ) // PopupMenuButton
        ], // <Widget>
      ), // AppBar
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();  // Quando clicar no botao flutuante é redirecionado para a pagina de editar contato contact_page
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.grey,
      ), // FloatingActionButton
      body: ListView.builder(
          padding:  EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }
      ), // ListView.builder
    ); // Scaffold
  } // build


  Widget _contactCard (BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage( // se o usuario tiver a imagem ele a carrega senao carrega a imagem padrao
                    image: contacts[index].img != null ?
                              FileImage(File(contacts[index].img)) :
                              AssetImage("images/person.png"),
                    fit: BoxFit.cover // deixa a imagen 100% redonda
                  ) // DecorationImage
                ), // BoxDecoration
              ), // Container
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contacts[index].name ?? "",
                      style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                    ), // Text
                    Text(contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ), // Text
                    Text(contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ), // Text
                  ], // <Widget>
                ), // Column
              ), // Padding
            ], // <Widget>
          ), // Row
        ), // Padding
      ), // Card
      onTap: (){  // redireciona para pagina de editar contato quando clina no contato
//        _showContactPage(contact: contacts[index]); // retorna o index do contato clicado para ser editado
        _showOptions(context, index); // criou esta função para apresentar uma janela com outras ações quando clicar no contato
      },
    ); // GestureDetector
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(
        context: context, 
        builder: (context){
          return BottomSheet(
              onClosing: (){},
              builder: (context){
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                         padding: EdgeInsets.all(10.0),
                         child: FlatButton(
                           child: Text("Ligar", style: TextStyle(color: Colors.grey, fontSize: 20.0, fontWeight: FontWeight.w900)),
                           onPressed: (){
                             launch("tel:${contacts[index].phone}"); // utiliza o plugin launch, como é para enviar onumero para ligar utiliza o "tel:"
                             Navigator.pop(context);
                           },
                         ) // FlatButton,
                      ), // Padding
                      Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Editar", style: TextStyle(color: Colors.grey, fontSize: 20.0, fontWeight: FontWeight.w900)),
                        onPressed: (){
                            Navigator.pop(context); // fecha a aba(janela) aberta
                            _showContactPage(contact: contacts[index]); // mostra tela de contatos
                          },
                        ) // FlatButton,
                      ), // Padding
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                          child: Text("Excluir", style: TextStyle(color: Colors.grey, fontSize: 20.0, fontWeight: FontWeight.w900),),
                          onPressed: (){
                            helper.deleteContact(contacts[index].id); // remove item do banco
                            setState(() {
                              contacts.removeAt(index); // remove da apresentação da tela
                              Navigator.pop(context); // fecha a aba(janela) aberta
                            });
                          },
                        ) // FlatButton,
                      ) // Padding
                    ],
                  ), // Column
                ); // Container
              }
          ); // BottomSheet
        }
    );
  }

  /** Função que chama a pagina contact_page.dart passando o index do contato vindo "onTap()" ou quando clica no botao adcionar contato*/
  void _showContactPage( {Contact contact} ) async {
    final recContact = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ContactPage(contact: contact,)) //ContactPage(contact: contact,) envia os dados para a pagina de editar contatos
                            );

    // Verifica se enviou contato, no caso se voltou ou saiu da tela sem ter salvo, se for nao faz nada
    if(recContact != null){
      if(contact != null){ // verifica se contato é novo ou existente para editar
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  /** função que pega todos os contatos para atualizar na lista home */
  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState(() { // usado para atualizar a tela
        contacts = list;
      });
    });
  }

  /** função que ordena por nome dos contatos */
  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a,b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a,b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {  // para atualizar a lista acrescenta o setState vazio
    });
  }

}
