import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/screens/home_screen.dart';
import 'package:rue_app/auth/auth_utils.dart';
import 'package:rue_app/widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Title(
      color: Colors.blue,
      title: "Login",
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/rianindautamaekspress.jpg"),
              fit: BoxFit.cover),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.only(right: 35, left: 35),
                        height: MediaQuery.of(context).size.height * 0.55,
                        width: MediaQuery.of(context).size.width > 500
                            ? 500
                            : MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Rianinda Utama Ekspress',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: adaptiveConv(context, 27) > 27
                                        ? 27
                                        : adaptiveConv(context, 27),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: adaptiveConv(context, 10) > 10
                                    ? 10
                                    : adaptiveConv(context, 10),
                              ),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  constraints: BoxConstraints.tightFor(
                                      height: adaptiveConv(context, 50) > 50
                                          ? 50
                                          : adaptiveConv(context, 50)),
                                  label: const Text("Email"),
                                  filled: true,
                                  hintText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Email is required";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: adaptiveConv(context, 10) > 10
                                    ? 10
                                    : adaptiveConv(context, 10),
                              ),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  constraints: BoxConstraints.tightFor(
                                      height: adaptiveConv(context, 50) > 50
                                          ? 50
                                          : adaptiveConv(context, 50)),
                                  label: const Text("Password"),
                                  filled: true,
                                  hintText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Password is required";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: adaptiveConv(context, 10) > 10
                                    ? 10
                                    : adaptiveConv(context, 10),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: adaptiveConv(context, 27) > 27
                                            ? 27
                                            : adaptiveConv(context, 27),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: CircleAvatar(
                                      radius: adaptiveConv(context, 30) > 30
                                          ? 30
                                          : adaptiveConv(context, 30),
                                      backgroundColor: const Color(0xff4c505b),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: IconButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              AuthService()
                                                  .login(
                                                email: _emailController.text,
                                                password:
                                                    _passwordController.text,
                                              )
                                                  .then((value) {
                                                if (value!
                                                    .contains('success')) {
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const HomePage()),
                                                      (route) => false);
                                                } else {
                                                  showAlertDialog(
                                                      context, "Error", value);
                                                }
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              });
                                            }
                                          },
                                          icon: const Icon(Icons.arrow_forward),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: adaptiveConv(context, 5) > 5
                                    ? 5
                                    : adaptiveConv(context, 5),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  children: [
                                    const Text("Forgot Password?"),
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text("Confirm"),
                                                content: TextFormField(
                                                  controller: _emailController,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    hintText: 'Email',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return "Email is required";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    child: const Text("Cancel"),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, false);
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    child: const Text("Next"),
                                                    onPressed: () {
                                                      AuthService()
                                                          .checkEmail(
                                                              _emailController
                                                                  .text)
                                                          .then((value) {
                                                        if (value["message"] ==
                                                            "success") {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    "Confirm"),
                                                                content:
                                                                    TextFormField(
                                                                  controller:
                                                                      _passwordController,
                                                                  obscureText:
                                                                      true,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    filled:
                                                                        true,
                                                                    hintText:
                                                                        'New Password',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return "Password is required";
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                                actions: [
                                                                  ElevatedButton(
                                                                    child: const Text(
                                                                        "Cancel"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  ),
                                                                  ElevatedButton(
                                                                    child: const Text(
                                                                        "Next"),
                                                                    onPressed:
                                                                        () {
                                                                      AuthService()
                                                                          .forgotPassword(
                                                                              uid: value["object"],
                                                                              newPassword: _passwordController.text)
                                                                          .then((value) {
                                                                        if (value ==
                                                                            "success") {
                                                                          Navigator.pushAndRemoveUntil(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => const HomePage()),
                                                                              (route) => false);
                                                                        } else {
                                                                          showAlertDialog(
                                                                              context,
                                                                              "Error",
                                                                              value!);
                                                                        }
                                                                      });
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        } else {
                                                          showAlertDialog(
                                                              context,
                                                              "Error",
                                                              value["message"]);
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text("Click here!"))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
