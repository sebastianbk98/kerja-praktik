// import 'package:file_picker/file_picker.dart';
// if(dart.library.html)
// {'package:file_picker_web/file_picker_web.dart' as WebFilePicker;}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/screens/work/add_work_trucks_screen.dart';

class AddWorkPage extends StatefulWidget {
  const AddWorkPage({super.key});

  @override
  State<AddWorkPage> createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _numberDNController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _receivingCompanyController =
      TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _shippingDateController = TextEditingController();
  final TextEditingController _transportationTypeController =
      TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _isLoading = false;

  String selectedFile = '';
  Uint8List? selectedFileInBytes;

  _selectFile() async {
    FilePickerResult? fileResult;
    if (kIsWeb) {
      fileResult = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    } else {
      fileResult = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    }
    if (fileResult != null) {
      selectedFile = fileResult.files.first.name;
      selectedFileInBytes = fileResult.files.first.bytes;
    }
    setState(() {
      _documentController.text = selectedFile;
    });
  }

  final DateTime _selectedDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) {
      setState(() {
        _shippingDateController.text = picked.toString().split(" ")[0];
      });
    }
  }

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
              // resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text("Add New Work"),
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
                          TextBoxWithValidation(
                            textController: _clientController,
                            label: 'Client',
                          ),
                          TextBoxWithValidation(
                            textController: _numberDNController,
                            label: 'Number DN',
                          ),
                          TextBoxWithValidation(
                            textController: _destinationController,
                            label: 'Destination',
                          ),
                          TextBoxWithValidation(
                            textController: _receivingCompanyController,
                            label: 'Receiving Company',
                          ),
                          TextBoxWithValidation(
                            textController: _weightController,
                            label: 'Weight',
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _shippingDateController,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              decoration: InputDecoration(
                                label: const Text("Shipping Date"),
                                filled: true,
                                hintText: 'Shipping Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Shipping Date is required";
                                }
                                return null;
                              },
                            ),
                          ),
                          TextBoxWithValidation(
                            textController: _transportationTypeController,
                            label: 'Transportation Type',
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _documentController,
                              decoration: InputDecoration(
                                label: const Text("Document"),
                                filled: true,
                                hintText: 'Document',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              readOnly: true,
                              onTap: _selectFile,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Document is required";
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (selectedFileInBytes == null) {}
                                  Work work = Work(
                                    id: '',
                                    client: _clientController.text,
                                    numberDN: _numberDNController.text,
                                    destination: _destinationController.text,
                                    receivingCompany:
                                        _receivingCompanyController.text,
                                    weight: _weightController.text,
                                    shippingDate: _shippingDateController.text,
                                    transportationType:
                                        _transportationTypeController.text,
                                    employees: {},
                                    trucks: {},
                                    status: workRequestEmployee,
                                    documentReference: _documentController.text,
                                    reportReference: [],
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddWorkTrucksPage(
                                          work: work,
                                          file: selectedFileInBytes),
                                    ),
                                  );
                                }
                              },
                              child: const Text("Next"),
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

class TextBoxWithValidation extends StatelessWidget {
  const TextBoxWithValidation({
    Key? key,
    required this.textController,
    required this.label,
  }) : super(key: key);

  final TextEditingController textController;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: textController,
        decoration: InputDecoration(
          label: Text(label),
          filled: true,
          hintText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required";
          }
          return null;
        },
      ),
    );
  }
}
