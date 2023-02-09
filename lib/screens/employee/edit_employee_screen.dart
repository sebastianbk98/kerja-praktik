import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/models/employee_model.dart';
import 'package:rue_app/auth/auth_utils.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage(
      {super.key, required this.isManager, required this.employee});
  final bool isManager;
  final Employee employee;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isLoading = false;
  bool _isPasswordChanged = false;
  bool _isEmailChanged = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final List<String> _position = [positionManager, positionStaffOperation];

  @override
  Widget build(BuildContext context) {
    Employee employee = widget.employee;
    bool isManager = widget.isManager;
    _fullNameController.text = employee.fullName;
    _phoneNumberController.text = employee.phoneNumber;
    _positionController.text = employee.position;
    _emailController.text = employee.email;

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/rianindautamaekspress.jpg"),
                  fit: BoxFit.cover),
            ),
            child: Scaffold(
              backgroundColor: Colors.white.withOpacity(0.9),
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text("Edit Account"),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: adaptiveConv(context, 10),
                      horizontal: adaptiveConv(context, 20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                label: const Text("Full Name"),
                                filled: true,
                                hintText: 'Full Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: ((value) {
                                if (value == null || value.isEmpty) {
                                  return "Full name is required";
                                }
                                return null;
                              }),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _phoneNumberController,
                              decoration: InputDecoration(
                                label: const Text("Phone Number"),
                                filled: true,
                                hintText: 'Phone Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: ((value) {
                                if (value == null || value.isEmpty) {
                                  return "Phone number is required";
                                }
                                return null;
                              }),
                            ),
                          ),
                          isManager
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonFormField(
                                    hint: const Text("Position"),
                                    items: _position
                                        .map((String value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(value),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      _positionController.text = value!;
                                    },
                                    validator: ((value) {
                                      if (value == null || value.isEmpty) {
                                        return "Position is required";
                                      }
                                      return null;
                                    }),
                                  ),
                                )
                              : Container(),
                          isManager
                              ? Container()
                              : Row(
                                  children: [
                                    Checkbox(
                                      value: _isEmailChanged,
                                      onChanged: (_) {
                                        setState(() {
                                          _isEmailChanged = !_isEmailChanged;
                                        });
                                      },
                                    ),
                                    const Text("Change Email"),
                                  ],
                                ),
                          isManager
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _emailController,
                                    enabled: !isManager && _isEmailChanged,
                                    decoration: InputDecoration(
                                      label: const Text("Email"),
                                      filled: true,
                                      hintText: 'Email',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: ((value) {
                                      if (value == null || value.isEmpty) {
                                        return "Email is required";
                                      }
                                      return null;
                                    }),
                                  ),
                                ),
                          isManager
                              ? Container()
                              : Row(
                                  children: [
                                    Checkbox(
                                      value: _isPasswordChanged,
                                      onChanged: (_) {
                                        setState(() {
                                          _isPasswordChanged =
                                              !_isPasswordChanged;
                                        });
                                      },
                                    ),
                                    const Text("Change Password"),
                                  ],
                                ),
                          isManager
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _newPasswordController,
                                    obscureText: true,
                                    enabled: _isPasswordChanged,
                                    decoration: InputDecoration(
                                      label: const Text("New Password"),
                                      filled: true,
                                      hintText: 'New Password',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: ((value) {
                                      if ((value == null || value.isEmpty) &&
                                          _isPasswordChanged) {
                                        return "New password is required";
                                      }
                                      return null;
                                    }),
                                  ),
                                ),
                          isManager
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: _currentPasswordController,
                                    obscureText: true,
                                    enabled:
                                        _isPasswordChanged || _isEmailChanged,
                                    decoration: InputDecoration(
                                      label: Text(
                                          "${_isPasswordChanged ? "Current " : ""}Password"),
                                      filled: true,
                                      hintText:
                                          '${_isPasswordChanged ? "Current " : ""}Password',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: ((value) {
                                      if ((value == null || value.isEmpty) &&
                                          (_isPasswordChanged ||
                                              _isEmailChanged)) {
                                        return "${_isPasswordChanged ? "Current " : ""}Password is required";
                                      }
                                      return null;
                                    }),
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    AuthService()
                                        .editAccount(
                                      uid: employee.uid,
                                      email: _emailController.text,
                                      fullName: _fullNameController.text,
                                      phoneNumber: _phoneNumberController.text,
                                      position: _positionController.text,
                                      isAdmin: isManager,
                                      currentPassword:
                                          _currentPasswordController.text,
                                      isPasswordChanged: _isPasswordChanged,
                                      newPassword: _newPasswordController.text,
                                    )
                                        .then((value) {
                                      if (value!.contains('success')) {
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(value),
                                          ),
                                        );
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    });
                                  }
                                },
                                child: const Text("Update Employee Data")),
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
