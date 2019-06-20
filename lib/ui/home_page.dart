import 'package:app_agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
