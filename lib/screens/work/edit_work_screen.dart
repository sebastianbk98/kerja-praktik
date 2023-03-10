import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/const.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/work_controller.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/widget.dart';

class EditWorkPage extends StatefulWidget {
  const EditWorkPage({super.key, required this.work});
  final Work work;

  @override
  State<EditWorkPage> createState() => _EditWorkPageState();
}

class _EditWorkPageState extends State<EditWorkPage> {
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _numberDNController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _receivingCompanyController =
      TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _shippingDateController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    Work work = widget.work;
    _clientController.text = work.client;
    _numberDNController.text = work.numberDN;
    _destinationController.text = work.destination;
    _receivingCompanyController.text = work.receivingCompany;
    _weightController.text = work.weight;
    _shippingDateController.text = work.shippingDate;
    _deliveryDateController.text = work.deliveryDate;
    _transportationTypeController.text = work.transportationType;
    _documentController.text = work.documentReference;
    final DateTime selectedDate = DateTime.now();
    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.parse(work.shippingDate),
          lastDate: DateTime.now());
      if (picked != null) {
        setState(() {
          _shippingDateController.text = picked.toString().split(" ")[0];
        });
      }
    }

    return Title(
      color: Colors.blue,
      title: "Add New Work",
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image:
                        AssetImage("assets/images/rianindautamaekspress.jpg"),
                    fit: BoxFit.cover),
              ),
              child: Scaffold(
                backgroundColor: Colors.white.withOpacity(0.9),
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
                                onTap: () => selectDate(context),
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
                            [workDone, workDoneConfirmation]
                                    .contains(work.status)
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _shippingDateController,
                                      readOnly: true,
                                      onTap: () => selectDate(context),
                                      decoration: InputDecoration(
                                        label: const Text("Delivery Date"),
                                        filled: true,
                                        hintText: 'Delivery Date',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      validator: (value) {
                                        if ([workDone, workDoneConfirmation]
                                                .contains(work.status) &&
                                            (value == null || value.isEmpty)) {
                                          return "Delivery Date is required";
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                                : Container(),
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
                                    work.client = _clientController.text;
                                    work.numberDN = _numberDNController.text;
                                    work.destination =
                                        _destinationController.text;
                                    work.receivingCompany =
                                        _receivingCompanyController.text;
                                    work.weight = _weightController.text;
                                    work.shippingDate =
                                        _shippingDateController.text;
                                    work.deliveryDate =
                                        _deliveryDateController.text;
                                    work.transportationType =
                                        _transportationTypeController.text;
                                    work.documentReference =
                                        _documentController.text;
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm"),
                                          content: const Text("Are you sure?"),
                                          actions: [
                                            ElevatedButton(
                                              child: const Text("No"),
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                            ),
                                            ElevatedButton(
                                              child: const Text("Yes"),
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ).then((value) {
                                      if (value != null && value) {
                                        editWork(
                                                work: work,
                                                file: selectedFileInBytes)
                                            .then((value) {
                                          if (value == "success") {
                                            Navigator.pop(context);
                                          } else {
                                            showAlertDialog(context, "Error",
                                                value.toString());
                                          }
                                        });
                                      }
                                    });
                                  }
                                },
                                child: const Text("Edit Work"),
                              ),
                            ),
                          ],
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

class TextBoxWithValidation extends StatelessWidget {
  const TextBoxWithValidation({
    Key? key,
    required this.textController,
    required this.label,
    this.enable = true,
  }) : super(key: key);

  final TextEditingController textController;
  final String label;
  final bool enable;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: textController,
        enabled: enable,
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
