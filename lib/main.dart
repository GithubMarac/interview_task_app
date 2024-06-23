import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _hourController = TextEditingController();
  final _minuteController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  String _selectedGender = 'male';
  String _result = '';

  Future<void> _sendData() async {
    try {
      var body = json.encode({
          'date': _dateController.text,
          'hour': _hourController.text,
          'minute': _minuteController.text,
          'name': _nameController.text,
          'surname': _surnameController.text,
          'sex': _selectedGender,
        });

      final response = await http.post(
        Uri.parse('http://bazihero.com/api/algo/firststep'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          _result = body;
        });
      } else {
        setState(() {
          _result = 'Error: ${response.statusCode}\nResponse: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != DateTime.now())
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple API App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a date';
                      }
                      try {
                        DateFormat('yyyy-MM-dd').parse(value);
                      } catch (_) {
                        return 'Invalid date format';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              TextFormField(
                controller: _hourController,
                decoration: InputDecoration(labelText: 'Hour (0-23)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an hour';
                  }
                  int? hour = int.tryParse(value);
                  if (hour == null || hour < 0 || hour > 23) {
                    return 'Invalid hour';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _minuteController,
                decoration: InputDecoration(labelText: 'Minute (0-59)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a minute';
                  }
                  int? minute = int.tryParse(value);
                  if (minute == null || minute < 0 || minute > 59) {
                    return 'Invalid minute';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: 'Surname (optional)'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ['male', 'female']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Sex'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sendData();
                  }
                },
                child: Text('Send Data'),
              ),
              SizedBox(height: 20),
              Text('Result: $_result'),
            ],
          ),
        ),
      ),
    );
  }
}