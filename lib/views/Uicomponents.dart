import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackfest/views/user_online/maps_markers.dart';
import 'package:intl/intl.dart';

Color appblue = const Color(0XFF4D88D7);

// ignore: non_constant_identifier_names
TextStyle heading_Tstlye({Color? color, double? size}) {
  return TextStyle(
    fontSize: size ?? 24.0,
    color: color ?? Colors.black87,
    fontWeight: FontWeight.bold,
  );
}

TextStyle content_Tstlye({
  Color? color,
}) {
  return TextStyle(
      fontSize: 18.0,
      color: color ?? Colors.black45,
      fontWeight: FontWeight.w500);
}

IconThemeData backButton({required Color color}) {
  return IconThemeData(color: color);
}

// TextStyle content_Tstyle = TextStyle(fontSize: 16.0, color: Colors.grey);

TextStyle appbar_Tstyle =
    TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20);

// TextStyle buttonTstyle =
//     TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);

TextStyle buttonTstyle({Color? color}) {
  return TextStyle(
      color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 16);
}

InputDecoration t_boxdecor(
    {IconData? icon,
    required String hintText,
    String? labelText,
    Color? color}) {
  return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      floatingLabelStyle: const TextStyle(fontSize: 24, color: Colors.black54),
      labelText: labelText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      icon: icon != null
          ? Icon(
              icon,
            )
          : null,
      iconColor: icon != null && color != null ? color : Colors.white);
}

// ButtonStyle buttonStyle = ElevatedButton.styleFrom(
//     backgroundColor: appblue,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));

ButtonStyle buttonStyle({Color? bgcolor}) {
  return ElevatedButton.styleFrom(
      backgroundColor: bgcolor ?? appblue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
}

String GetDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  String formattedDate = DateFormat('d MMMM').format(dateTime);
  return formattedDate;
}

String GetTime(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  String formattedDate = DateFormat('h:mm a').format(dateTime);
  return formattedDate;
}

//Product Tile
Widget buyProduct({
  required BuildContext context,
  required String productId,
  required String imagelink,
  required String productPrice,
  required String productName,
  required String location,
  required int stockno,
}) {
  return Card(
    elevation: 10,
    color: Colors.blue.shade50,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(2),
            height: 120,
            width: double.infinity,
            child: Image.network(
              imagelink,
              fit: BoxFit.fill,
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            productName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            location,
            softWrap: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Stock: $stockno'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Rs.$productPrice',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

Widget buyProvisionTile(
    {required BuildContext context,
    required String provId,
    required String provName,
    required String imagelink,
    required String provPrice,
    required String location,
    required int stockno}) {
  return Card(
    elevation: 10,
    color: Colors.blue.shade50,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(2),
            height: 120,
            width: double.infinity,
            child: Image.network(
              imagelink,
              fit: BoxFit.fill,
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            provName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            location,
            softWrap: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Stock: $stockno'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Rs.$provPrice',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

//For Admin_Welcome_page
Widget DistressCalls(String distresstype, String name, String nop,
    String datetime, String location, Function() onpressed) {
  return Container(
    decoration: BoxDecoration(
        color: distresstype.toLowerCase() == 'sos'
            ? Colors.red.withOpacity(0.7)
            : distresstype.toLowerCase() == 'food'
                ? Colors.green.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
        border: Border.all(color: Colors.black, width: 0.2)),
    padding: const EdgeInsets.all(10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Image.asset(
                distresstype.toLowerCase() == 'sos'
                    ? 'assets/images/sos-icon.png'
                    : distresstype.toLowerCase() == 'food'
                        ? 'assets/images/food-icon.png'
                        : 'assets/images/medical-icon.png',
                width: 39,
                height: 39,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              datetime.split(', ')[0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Text(
              datetime.split(', ')[1],
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            )
          ],
        ),
        Container(
          width: 220,
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: distresstype.toLowerCase() == 'sos'
                  ? Colors.red.shade50
                  : distresstype.toLowerCase() == 'food'
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
              border: Border.all(color: Colors.black, width: 0.2),
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                distresstype.toUpperCase(),
                style: TextStyle(
                    color: distresstype.toLowerCase() == 'sos'
                        ? Colors.red.shade900
                        : distresstype.toLowerCase() == 'food'
                            ? Colors.green.shade500
                            : Colors.blue.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
                indent: 2,
                endIndent: 2,
              ),
              Text(
                name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Text('People : $nop',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const Text('Location :',
                  softWrap: true,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              Text(location,
                  softWrap: true,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87))
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onpressed,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 10,
              shape: const CircleBorder()),
          child: Icon(
            Icons.location_on,
            color: distresstype.toLowerCase() == 'sos'
                ? Colors.red.shade900
                : distresstype.toLowerCase() == 'food'
                    ? Colors.green.shade500
                    : Colors.blue.shade500,
          ),
        )
      ],
    ),
  );
}

//For user's welcome_page
Widget profilecard(String name, String adharCardNumber, String NOP,
    String location, Function() onpressed, String pphone, String sphone) {
  return Center(
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
      elevation: 10,
      color: appblue.withOpacity(0.9),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              child: const Icon(
                CupertinoIcons.profile_circled,
                size: 180,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Welcome, $name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 290,
              child: Divider(
                thickness: 1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              textAlign: TextAlign.center,
              'Aadhar Number',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              textAlign: TextAlign.center,
              '${adharCardNumber.substring(0, adharCardNumber.length - 4)}****',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Number Of People : $NOP',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Location:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              location,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onpressed,
              style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                  elevation: 10),
              child: const Text('Update Location'),
            ),
            const SizedBox(height: 10),
            Text(
              'Phone No.: $pphone',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Alt Phone No.: $sphone',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget updatetile(String disasterType, String suggestion, String dateNTime,
    bool isSevere, String location, BuildContext context) {
  return Column(children: [
    Container(
      decoration: BoxDecoration(
          color: isSevere
              ? Colors.red.withOpacity(0.6)
              : Colors.yellow.withOpacity(0.5),
          border: const Border.symmetric(
              horizontal: BorderSide(color: Colors.white, width: 1.9))),
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      disasterType.trim() == "Flood"
                          ? Icons.flood
                          : disasterType.trim() == "Hurricane"
                              ? Icons.cloudy_snowing
                              : disasterType.trim() == "Earthquake"
                                  ? Icons.landslide
                                  : Icons.flood,
                      size: 39,
                      color: Colors.red.shade900,
                    ),
                  ),
                  onTap: () {
                    List<String> latLng = location.split(', ');
                    double latitude = double.parse(latLng[0].split(': ')[1]);
                    double longitude = double.parse(latLng[1].split(': ')[1]);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GoogleMapScreen(
                              lat: latitude,
                              long: longitude,
                            )));
                  },
                ),
                const SizedBox(height: 5),
                Text(
                  dateNTime.split(', ')[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  dateNTime.split(', ')[1],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSevere
                          ? Colors.red.shade50
                          : Colors.deepOrange.shade50,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      disasterType[0].toUpperCase() + disasterType.substring(1),
                      style: TextStyle(
                          color: isSevere ? Colors.red : Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSevere
                          ? Colors.red.shade50
                          : Colors.deepOrange.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Suggestion :',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          suggestion,
                          softWrap: true,
                          style: const TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ]);
}

Widget Historytile(String distressType, String DistressTime) {
  return Column(children: [
    Container(
      decoration: BoxDecoration(
          color: distressType.toLowerCase() == 'sos'
              ? Colors.red.withOpacity(0.8)
              : distressType.toLowerCase() == 'food'
                  ? Colors.green.withOpacity(0.5)
                  : Colors.blue.withOpacity(0.5),
          border: const Border.symmetric(
              horizontal: BorderSide(color: Colors.white, width: 2.0))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Image.asset(
                    distressType.toLowerCase() == 'sos'
                        ? 'assets/images/sos-icon.png'
                        : distressType.toLowerCase() == 'food'
                            ? 'assets/images/food-icon.png'
                            : 'assets/images/medical-icon.png',
                    width: distressType.toLowerCase() == 'sos' ? 40 : 45,
                    height: distressType.toLowerCase() == 'sos' ? 40 : 45,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: distressType.toLowerCase() == 'sos'
                          ? Colors.red.shade50
                          : Colors.deepOrange.shade50,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      distressType,
                      style: TextStyle(
                          color: distressType.toLowerCase() == 'sos'
                              ? Colors.red
                              : Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: distressType.toLowerCase() == 'sos'
                          ? Colors.red.shade50
                          : Colors.deepOrange.shade50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Date : ${GetDate(DistressTime)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Time : ${GetTime(DistressTime)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ]);
}

Widget distressTile(
    String innerText, IconData iconData, Function()? onpressed, Color color) {
  return Container(
    height: 160,
    width: 160,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),
          spreadRadius: 3,
          blurRadius: 10,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Text(
            innerText,
            softWrap: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
              backgroundColor: color,
              // overlayColor: Colors.red,
              elevation: 10,
            ),
            onPressed: onpressed,
            child: Icon(
              iconData,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    ),
  );
}
