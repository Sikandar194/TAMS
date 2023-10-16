import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idms_fyp_app/Validation/custom_form_validation.dart';
import 'package:idms_fyp_app/login_page.dart';

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  const OtpInput(this.controller, this.autoFocus, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 50,
      child: TextField(
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller: controller,
        maxLength: 1,
        cursorColor: Theme.of(context).primaryColor,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            counterText: '',
            hintStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}

class ForgetPass extends StatefulWidget {
  static const String routeName = '/forgetPass';
  const ForgetPass({Key? key}) : super(key: key);

  @override
  State<ForgetPass> createState() => _ForgetPassState();
}

Future<String> sendEmail(BuildContext context, String email) async {
  final url = Uri.parse('http://device-ip:3001/fetchemailforotp?email=${email}');
  final response = await http.get(url);
  final decodedResponse = json.decode(response.body);
  final data = decodedResponse['data'];
  if (response.statusCode != 200 || !decodedResponse['success']) {
    return 'failed';
  }
  return 'success';
}



class _ForgetPassState extends State<ForgetPass> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController= TextEditingController();
  final _confirmpasswordController=TextEditingController();
  bool passwordVisible=false;
  bool confirmpasswordVisible=false;
  bool _emailformat = false;
  bool _emailboxvisible=true;
  bool _otpboxvisible=false;
  bool _passboxvisible=false;
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  final TextEditingController _fieldFive = TextEditingController();
  final TextEditingController _fieldSix = TextEditingController();
  String? _sendotp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text('Forgot Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
              children: <Widget>[
                Visibility(
                  visible: _emailboxvisible,
                  child: CustomFormField(
                    hintText: 'Email',
                    labelText: 'Email',
                    controller: _emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      else {
                        if (value!.isValidEmail){
                          _emailformat=true;
                        }
                        else
                        {
                          return 'Email format: someone@example.com';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                Visibility(
                  visible: _emailboxvisible,
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: const Text('Please enter your email to receive OTP.',textAlign: TextAlign.center,style: TextStyle(color: Colors.green),),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: _emailboxvisible,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text('Send code'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_emailformat == true) {
                            final result = await sendEmail(context, _emailController.text.trim());
                            if (result=='success'){
                              setState(() {
                                _emailboxvisible=false;
                                _otpboxvisible=true;
                              });
                            }
                          }
                        }
                        else {
                          // Invalid email or password
                          print('Invalid input');
                        }
                      },
                    ),
                  ),
                ),

                Visibility(
                  visible: _otpboxvisible,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OtpInput(_fieldOne, true), // auto focus
                      OtpInput(_fieldTwo, false),
                      OtpInput(_fieldThree, false),
                      OtpInput(_fieldFour, false),
                      OtpInput(_fieldFive, false),
                      OtpInput(_fieldSix, false)
                    ],
                  ),
                ),

                Visibility(
                  visible: _otpboxvisible,
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: const Text('Please check your email and enter OTP.',textAlign: TextAlign.center,style: TextStyle(color: Colors.green),),
                        ),
                      ],
                    ),
                  ),
                ),

                Visibility(
                  visible: _otpboxvisible,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text('Verify OTP'),
                      onPressed: () async {
                        setState(() {
                          _sendotp = _fieldOne.text +
                              _fieldTwo.text +
                              _fieldThree.text +
                              _fieldFour.text +
                              _fieldFive.text+
                              _fieldSix.text;
                        });
                        await verifyOTP(_emailController.text.trim(),_sendotp);

                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: _passboxvisible,
                  child: Column(
                    children: [
                      TextFormField(
                        obscureText: !passwordVisible,
                        cursorColor: Colors.green,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          hintText: 'Password',
                          labelText: 'Password',
                          focusColor: Colors.green,
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: Colors.green[600],
                            onPressed: () {
                              setState(
                                    () {
                                  passwordVisible = !passwordVisible;
                                },
                              );
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15,),
                      TextFormField(
                        obscureText: !confirmpasswordVisible,
                        cursorColor: Colors.green,
                        controller: _confirmpasswordController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          hintText: 'Confirm Password',
                          labelText: 'Confirm Password',
                          focusColor: Colors.green,
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: Colors.green[600],
                            onPressed: () {
                              setState(
                                    () {
                                  passwordVisible = !confirmpasswordVisible;
                                },
                              );
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please re-enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: const Text('Change Password'),
                        onPressed: () async {
                          await savePassword();
                        },
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
  Future<void> verifyOTP(String email,String? otp) async {
    final url = Uri.parse('http://device-ip:3001/verifyotp?email=${email}&enteredOTP=$otp');
    final response = await http.get(url);
    final decodedResponse = json.decode(response.body);
    if (response.statusCode == 200 && decodedResponse['success']) {
      setState(() {
        _otpboxvisible = false;
        _passboxvisible = true;
      });
    } else {
      print('OTP is invalid');
    }
  }
  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Password updated successfully.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
  Future<void> savePassword() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmpasswordController.text;

    if(password==confirmPassword){
    final url = Uri.parse('http://device-ip:3001/savepassword');
    final response = await http.post(url, body: {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    if (response.statusCode == 200) {
    showSuccessDialog(context);
    } else {
      print('Error in saving password.');
    }
  }
    else{
      showSnackBar(context, 'Password and Confirm Password do not match.');
    }
  }

}
