import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_de_contatos/helpers/contact_helper.dart';

import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController(),
      _emailController = TextEditingController(),
      _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEditing = false;
  Contact _editingContact;

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editingContact = Contact();
    } else {
      _editingContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editingContact.name;
      _emailController.text = _editingContact.email;
      _phoneController.text = _editingContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editingContact.name ?? "Novo contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            backgroundColor: Colors.red,
            onPressed: () {
              if (_editingContact.name != null &&
                  _editingContact.name.isNotEmpty) {
                Navigator.pop(context, _editingContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            }),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editingContact.img != null
                          ? FileImage(File(_editingContact.img))
                          : AssetImage("images/contact_card.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: () {
                  _userEditing = true;
                  ImagePicker.pickImage(source: ImageSource.camera)
                      .then((file) {
                    if (file == null) {
                      return;
                    } else {
                      setState(() {
                        _editingContact.img = file.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEditing = true;
                  setState(() {
                    _editingContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text) {
                  _userEditing = true;
                  _editingContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Telefone"),
                onChanged: (text) {
                  _userEditing = true;
                  _editingContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEditing) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Descartar alterações?"),
                content: Text("Se aceitar as alterações serão perdidas."),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("CANCELAR")),
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text("SIM")),
                ],
              ));
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
