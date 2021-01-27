// ///More cool ux otp screen
//
// import 'dart:async';
//
// import 'package:clipstream/Pages/management.dart';
// import 'package:flare_flutter/flare_actor.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
//
// class PinCodeVerificationScreen extends StatefulWidget {
//   final String phoneNumber;
//
//   PinCodeVerificationScreen(this.phoneNumber);
//
//   @override
//   _PinCodeVerificationScreenState createState() =>
//       _PinCodeVerificationScreenState();
// }
//
// class _PinCodeVerificationScreenState extends State<PinCodeVerificationScreen> {
//   var onTapRecognizer;
//
//   TextEditingController textEditingController = TextEditingController();
//   // ..text = "123456";
//
//   StreamController<ErrorAnimationType> errorController;
//
//   bool hasError = false;
//   String currentText = "";
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   final formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     onTapRecognizer = TapGestureRecognizer()
//       ..onTap = () {
//         Navigator.pop(context);
//       };
//     errorController = StreamController<ErrorAnimationType>();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     errorController.close();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue.shade50,
//       key: scaffoldKey,
//       body: GestureDetector(
//         onTap: () {},
//         child: Container(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           child: ListView(
//             children: <Widget>[
//               SizedBox(height: 30),
//               Container(
//                 height: MediaQuery.of(context).size.height / 3,
//                 child: FlareActor(""),
//                  // "assets/otp.flr",
//                  // animation: "otp",
//                   // fit: BoxFit.fitHeight,
//                  // alignment: Alignment.center,
//               ),
//               SizedBox(height: 8),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Text(
//                   'Phone Number Verification',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
//                 child: RichText(
//                   text: TextSpan(
//                       text: "Enter the code sent to ",
//                       children: [
//                         TextSpan(
//                             text: widget.phoneNumber,
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15)),
//                       ],
//                       style: TextStyle(color: Colors.black54, fontSize: 15)),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Form(
//                 key: formKey,
//                 child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 8.0, horizontal: 30),
//                     child: PinCodeTextField(
//                       appContext: context,
//                       pastedTextStyle: TextStyle(
//                         color: Colors.green.shade600,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       length: 6,
//                       obscureText: false,
//                       obscuringCharacter: '*',
//                       animationType: AnimationType.fade,
//                       validator: (v) {
//                         if (v.length < 3) {
//                           return "I'm from validator";
//                         } else {
//                           return null;
//                         }
//                       },
//                       pinTheme: PinTheme(
//                         shape: PinCodeFieldShape.box,
//                         borderRadius: BorderRadius.circular(5),
//                         fieldHeight: 60,
//                         fieldWidth: 50,
//                         activeFillColor:
//                         hasError ? Colors.orange : Colors.white,
//                       ),
//                       cursorColor: Colors.black,
//                       animationDuration: Duration(milliseconds: 300),
//                       textStyle: TextStyle(fontSize: 20, height: 1.6),
//                       backgroundColor: Colors.blue.shade50,
//                       enableActiveFill: true,
//                       errorAnimationController: errorController,
//                       controller: textEditingController,
//                       keyboardType: TextInputType.number,
//                       boxShadows: [
//                         BoxShadow(
//                           offset: Offset(0, 1),
//                           color: Colors.black12,
//                           blurRadius: 10,
//                         )
//                       ],
//                       onCompleted: (v) {
//                         print("Completed");
//                       },
//                       // onTap: () {
//                       //   print("Pressed");
//                       // },
//                       onChanged: (value) {
//                         print(value);
//                         setState(() {
//                           currentText = value;
//                         });
//                       },
//                       beforeTextPaste: (text) {
//                         print("Allowing to paste $text");
//                         //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
//                         //but you can show anything you want here, like your pop up saying wrong paste format or etc
//                         return true;
//                       },
//                     )),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 30.0),
//                 child: Text(
//                   hasError ? "*Please fill up all the cells properly" : "",
//                   style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w400),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               RichText(
//                 textAlign: TextAlign.center,
//                 text: TextSpan(
//                     // text: "Wrong number? ",
//                     // style: TextStyle(color: Colors.red, fontSize: 15),
//                     children: [
//                       TextSpan(
//                           text: "Wrong number?",
//                           recognizer: onTapRecognizer,
//                           style: TextStyle(
//                               color: Color(0xFFFF0000),
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16))
//                     ]),
//               ),
//               SizedBox(
//                 height: 14,
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: EdgeInsets.only(bottom: 30),
//     child: Visibility(
//     visible: true,
//       child: FloatingActionButton(
//         onPressed: (){
//           Navigator.push(context,
//           MaterialPageRoute(
//             builder: (context) => ManagementScreen(),
//           ),
//         );
//           formKey.currentState.validate();
//           // conditions for validating
//           if (currentText.length != 6 || currentText != "towtow") {
//             errorController.add(ErrorAnimationType
//                 .shake); // Triggering error shake animation
//             setState(() {
//               hasError = true;
//             });
//           } else {
//             setState(() {
//               hasError = false;
//               scaffoldKey.currentState.showSnackBar(SnackBar(
//                 content: Text("Aye!!"),
//                 duration: Duration(seconds: 2),
//               ));
//             });
//           }
//         },
//           child: Icon(Icons.arrow_forward_sharp),
//     backgroundColor: Colors.red,
//         foregroundColor: Colors.white,
//       ),
//       ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
//     );
//   }
// }