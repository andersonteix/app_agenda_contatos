import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';

// É utilizado o final para ser utilizado para que não ocorra erro em digitar os nomes dos atributos e ser unicos no codigo sem que sejam alterados
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";


class ContactHelper {
/** CONEXÃO COM BANCO - Esta classe é do padrão singeton por ter somente uma instancia e não varias instancias */

  // Objeto da classe _instance -- // ContactHelper.internal() é o contrutor interno
  static final ContactHelper _instance = ContactHelper.internal();

 // retorna o _instance
  factory ContactHelper() => _instance;

  // Construtor interno vazio
  ContactHelper.internal();

  Database _db;

  // Inicializa o banco de dados e utiliza o async e await por não retornar instantaneamente
  Future<Database> get db async {
      // Se ja inicializou o banco de dados então retorna o banco senao cria a inicializa o db
      if(_db != null){
        return _db;
      } else {
        _db = await initDb();
        return _db;
      }
  }

  // Como não retorna instantaneamente e utilizado o await e async para retornar e em muitos casos o Future<>
   Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath(); // busca o local onde o banco esta armazenado
//    final path = join(databasesPath, "contacts.db"); // busca o arquivo que esta armazenado no banco de dados
    final path = join(databasesPath, "contactsnew.db"); // renomeiar quando for fazer teste no banco para nao dar conflito em testes

    return  await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async { // onCreate utiliza uma função
              //cria o banco senao estiver criado
              await db.execute("CREATE TABLE $contactTable( $idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, "
                                            "$phoneColumn TEXT, $imgColumn TEXT )"
              );
    });
  }

  /** Método Salvar contato */
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;   // Obtem o banco de dados
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  /** Método lista um contato */
  Future<Contact> getContact(int id) async {
    Database dbContact = await db;  // Obtem o banco de dados
    List<Map> maps = await dbContact.query(contactTable,  // Utiliza 'query' para informar qual atributo retornar
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id] );

    if(maps.length > 0){
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /** Método deleta um contato */
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;  // Obtem o banco de dados
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  /** Método atualiza um contato */
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;  // Obtem o banco de dados
    return await dbContact.update(contactTable,
                                  contact.toMap(),
                                  where: "$idColumn = ?",
                                  whereArgs: [contact.id]
                                );
  }

  /** Método lista com todos contatos */
  Future<List> getAllContacts() async {
    Database dbContact = await db;  // Obtem o banco de dados
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContacts = List();
    for(Map m in listMap){
      listContacts.add(Contact.fromMap(m));
    }

    return listContacts;
  }

  /** Método contabiliza total de contatos */
  Future<int> getNumber() async {
    Database dbContact = await db;  // Obtem o banco de dados
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  /** Método fecha conexão com o banco de dados */
  Future close() async {
    Database dbContact = await db;  // Obtem o banco de dados
    dbContact.close();
  }

}


/**
 * CLASSE CONTACT
 **/

class Contact {

  int id;
  String name;
  String email;
  String phone;
  String img;

  //Construtor vazio
  Contact();

  Contact.fromMap(Map map){
    id    = map[idColumn];
    name  = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img   = map[imgColumn];

  }

  /** Converte para Map */
  Map toMap(){
    Map<String, dynamic> map = {
      nameColumn:  name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn:   img,
    };

    if(id != null){
      map[idColumn] = id;
    }

    return map;
  }


  @override
  String toString() {
    return "Contact( id: $id, name: $name, email: $email, phone: $phone, img: $img )";
  }


}