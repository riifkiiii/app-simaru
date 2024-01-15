// import 'package:appssimaru/screens/login_screen.dart';
import 'package:appssimaru/model/booking.dart';
import 'package:appssimaru/screens/booking/booking_add.dart';
import 'package:appssimaru/screens/booking/booking_edit.dart';
import 'package:flutter/material.dart';
import 'package:appssimaru/core/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  @override
  BookingsScreenState createState() => BookingsScreenState();
}

class BookingsScreenState extends State<BookingScreen> {
  final ApiClient _apiClient = ApiClient();
  String accesstoken = '';

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: _apiClient.getBookingData(accesstoken),
          builder:
              (BuildContext context, AsyncSnapshot<List<Booking>> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    "Something wrong with message: ${snapshot.error.toString()}"),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              List<Booking>? bookings = snapshot.data;
              return _buildListView(bookings!);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const BookingAddScreen())),
      ),
    );
  }

  Widget _buildListView(List<Booking> bookings) {
    DateTime now = DateTime.now();
    // Format date
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    // Format time
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListView.builder(
        itemBuilder: (context, index) {
          Booking booking = bookings[index];
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      booking.ruangan_id,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(booking.start_book),
                    Text('Pembooking : ${booking.user_id}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Warning"),
                                    content: Text(
                                        "Are you sure want to delete data booking ${booking.ruangan_id}?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text("Yes"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _apiClient
                                              .delBooking(
                                                  accesstoken, booking.id)
                                              .then((isSuccess) {
                                            if (isSuccess) {
                                              setState(() {});
                                              ScaffoldMessenger.of(this.context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Delete data success")));
                                            } else {
                                              ScaffoldMessenger.of(this.context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Delete data failed")));
                                            }
                                          });
                                        },
                                      ),
                                      TextButton(
                                        child: Text("No"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  );
                                });
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookingEditScreen(
                                          booking: booking,
                                        )));
                          },
                          child: Text(
                            "Edit",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: bookings.length,
      ),
    );
  }
}
