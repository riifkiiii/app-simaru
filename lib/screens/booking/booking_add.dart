import 'dart:convert';
import 'dart:html';

import 'package:appssimaru/model/ruangan.dart';
import 'package:flutter/material.dart';
import 'package:appssimaru/core/api_client.dart';
import 'package:appssimaru/screens/login_screen.dart';
import 'package:appssimaru/utils/validator.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' show Client;

final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

class BookingAddScreen extends StatefulWidget {
  const BookingAddScreen({Key? key}) : super(key: key);

  @override
  State<BookingAddScreen> createState() => _BookingAddScreenState();
}

class _BookingAddScreenState extends State<BookingAddScreen> {
  Client client = Client();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController bookingController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  String accesstoken = '';
  // Select Ruangan
  String? selectedRuangan;
  List<String> ruanganOptions = [];
  String result = '';

  @override
  void initState() {
    startDateController.text = "";
    super.initState();
    _loadToken();
    fetchRuangan(accesstoken);
  }

  Future<List<Ruangan>> fetchRuangan(String accessToken) async {
    try {
      final response = await client.get(
        Uri.parse('https://simaru.amisbudi.cloud/api/ruangans/all'),
        // queryParameters: {'apikey': ApiSecret.apiKey},
        headers: {
          'Authorization': 'Bearer $accessToken',
          'content-type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return ruanganFromJson(response.body);
      } else {
        return [];
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        result = 'Selected Category: $selectedRuangan';
      });
    }
  }

  _loadToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var data = localStorage.getString('accessToken');

    if (data != null) {
      setState(() {
        accesstoken = data;
      });
    }
  }

  Future<void> addBooking() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Processing Data'),
        backgroundColor: Colors.green.shade300,
      ));

      Map<String, dynamic> bookingData = {
        "ruangan_id": bookingController.text,
        "user_id": userIdController.text,
        "start_book": startDateController.text,
        "end_book": endDateController.text
      };

      final res = await _apiClient.addRuangan(accesstoken, bookingData);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (res.statusCode == 200 || res.statusCode == 201) {
        var msg = jsonDecode(res.body);
        ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
          content: Text('${msg['message'].toString()}'),
          backgroundColor: Colors.green.shade300,
        ));
        Navigator.pop(_scaffoldState.currentState!.context);
      } else if (res.statusCode == 401) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else if (res.statusCode == 500) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: Internal Server Error 500'),
          backgroundColor: Colors.red.shade300,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${res.body.toString()}'),
          backgroundColor: Colors.red.shade300,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldState,
      backgroundColor: Colors.blueGrey[200],
      body: Form(
        key: _formKey,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: size.width * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //   SizedBox(height: size.height * 0.08),
                    const Center(
                      child: Text(
                        "Booking Ruangan",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Ruangan',
                      ),
                      value: selectedRuangan,
                      items: ruanganOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedRuangan = newValue;
                        });
                      },
                    ),

                    SizedBox(height: size.height * 0.03),

                    TextFormField(
                      controller: userIdController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: "Pembooking",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    TextFormField(
                      validator: (value) => Validator.validateText(value ?? ""),
                      controller: startDateController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "Start Booking",
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(
                                2000), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));

                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          //you can implement different kind of Date Format here according to your requirement

                          setState(() {
                            startDateController.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                    ),
                    SizedBox(height: size.height * 0.03),
                    TextFormField(
                      validator: (value) => Validator.validateText(value ?? ""),
                      controller: endDateController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "End Booking",
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(
                                2000), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));

                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          //you can implement different kind of Date Format here according to your requirement

                          setState(() {
                            endDateController.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                    ),
                    SizedBox(height: size.height * 0.06),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addBooking,
                        style: ElevatedButton.styleFrom(
                            primary: Colors.indigo,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15)),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
