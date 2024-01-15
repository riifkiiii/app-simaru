import 'dart:convert';
import 'package:appssimaru/model/booking.dart';
import 'package:flutter/material.dart';
import 'package:appssimaru/core/api_client.dart';
import 'package:appssimaru/screens/login_screen.dart';
import 'package:appssimaru/utils/validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

// ignore: must_be_immutable
class BookingEditScreen extends StatefulWidget {
  // const RuanganEditScreen({Key? key}) : super(key: key);

  Booking booking;

  BookingEditScreen({required this.booking});

  @override
  State<BookingEditScreen> createState() => _BookingEditScreenState();
}

class _BookingEditScreenState extends State<BookingEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController bookingController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  String accesstoken = '';
  int id = 0;

  @override
  void initState() {
    super.initState();

    bookingController.text = widget.booking.ruangan_id;
    userIdController.text = widget.booking.user_id;
    startDateController.text = widget.booking.start_book;
    endDateController.text = widget.booking.end_book;
    setState(() {
      id = widget.booking.id;
    });
    _loadToken();
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

      final res = await _apiClient.updateBooking(
          accesstoken, bookingData, widget.booking.id);

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
                        "Edit Booking",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),

                    SizedBox(height: size.height * 0.03),
                    TextFormField(
                      validator: (value) => Validator.validateText(value ?? ""),
                      controller: bookingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "Name Booking",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    TextFormField(
                      controller: userIdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Pengguna",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    TextFormField(
                      validator: (value) => Validator.validateText(value ?? ""),
                      controller: startDateController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "Start Booking",
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
