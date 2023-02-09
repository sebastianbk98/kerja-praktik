import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/employee_controller.dart';
import 'package:rue_app/controllers/truck_controller.dart';

class AddTruckPage extends StatefulWidget {
  const AddTruckPage({super.key});

  @override
  State<AddTruckPage> createState() => _AddTruckPageState();
}

class _AddTruckPageState extends State<AddTruckPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                title: const Text("Add New Truck"),
              ),
              body: FutureBuilder(
                future: getAllEmployeesForDriver(),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic>? data = snapshot.data;
                    if (data?["message"] == "success") {
                      return SafeArea(
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
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        label: const Text("Name"),
                                        filled: true,
                                        hintText: 'Name',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      validator: ((value) {
                                        if (value == null || value.isEmpty) {
                                          return "Name is required";
                                        }
                                        return null;
                                      }),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _licenseNumberController,
                                      decoration: InputDecoration(
                                        label: const Text("License Number"),
                                        filled: true,
                                        hintText: 'License Number',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      validator: ((value) {
                                        if (value == null || value.isEmpty) {
                                          return "License number is required";
                                        }
                                        return null;
                                      }),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _capacityController,
                                      decoration: InputDecoration(
                                        label: const Text("Capacity"),
                                        filled: true,
                                        hintText: 'Capacity',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      validator: ((value) {
                                        if (value == null || value.isEmpty) {
                                          return "Capacity is required";
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
                                          createTruck(
                                            name: _nameController.text,
                                            licenseNumber:
                                                _licenseNumberController.text,
                                            capacity: _capacityController.text,
                                          ).then((value) {
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
                                      child: const Text("Add New Truck"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(data?["message"]),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
              ),
            ),
          );
  }
}
