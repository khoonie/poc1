import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:poc1/repository/dataRepository.dart';
import 'package:poc1/utils/constants.dart';

import 'model/homes.dart';

typedef DialogCallback = void Function();

class HomeDetails extends StatelessWidget {
  final Home home;
  const HomeDetails(this.home);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(home.propname == null ? "" : home.propname),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: HomeDetailForm(home),
      ),
    );
  }
}

class HomeDetailForm extends StatefulWidget {
  final Home home;
  const HomeDetailForm(this.home);

  @override
  _HomeDetailFormState createState() => _HomeDetailFormState();
}

class _HomeDetailFormState extends State<HomeDetailForm> {
  final DataRepository repository = DataRepository();
  final _formKey = GlobalKey<FormBuilderState>();
  final dateformat = DateFormat('yyyy-MM-dd');
  String propname = "";
  String proptype = "";
  String address = "";

  @override
  void initState() {
    proptype = widget.home.proptype;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(children: <Widget>[
              SizedBox(height: 20.0),
              FormBuilderTextField(
                  name: "property name",
                  initialValue: widget.home.propname,
                  decoration: textInputDecoration.copyWith(
                      hintText: "Name", labelText: "Property Name"),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.minLength(context, 1),
                    FormBuilderValidators.required(context)
                  ]),
                  onChanged: (val) {
                    setState(() => propname = val!);
                  }),
            ])));
  }
}
