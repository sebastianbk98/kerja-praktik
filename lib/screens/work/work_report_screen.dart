import 'package:file_picker/file_picker.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/work_controller.dart';
import 'package:rue_app/models/work_model.dart';

class WorkReportPage extends StatefulWidget {
  const WorkReportPage({super.key, required this.work});
  final Work work;

  @override
  State<WorkReportPage> createState() => _WorkReportPageState();
}

class _WorkReportPageState extends State<WorkReportPage> {
  List<String> selectedFile = [];
  List<Uint8List> selectedFileInBytes = [];
  _selectFile() async {
    FilePickerResult? fileResult;
    if (kIsWeb) {
      fileResult = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);
    } else {
      fileResult = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);
    }
    if (fileResult != null) {
      for (var i = 0; i < fileResult.count; i++) {
        selectedFile.add(fileResult.files[i].name);
        selectedFileInBytes.add(fileResult.files[i].bytes!);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Work work = widget.work;
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/rianindautamaekspress.jpg"),
            fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        appBar: AppBar(
          title: const Text("Report"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton(
                      onPressed: _selectFile,
                      child: const Text("Upload Image")),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedFile = [];
                        selectedFileInBytes = [];
                      });
                    },
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      uploadReport(
                        work: work,
                        references: selectedFile,
                        files: selectedFileInBytes,
                      ).then((value) {
                        if (value == "success") {
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value),
                            ),
                          );
                        }
                      });
                    },
                    child: const Text("Submit"),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      vertical: adaptiveConv(context, 5),
                      horizontal: adaptiveConv(context, 20),
                    ),
                    crossAxisCount: 2,
                    crossAxisSpacing: adaptiveConv(context, 10),
                    mainAxisSpacing: adaptiveConv(context, 10),
                    shrinkWrap: true,
                    children: [
                      for (var byte in selectedFileInBytes) Image.memory(byte)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
