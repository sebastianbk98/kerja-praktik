import 'package:file_picker/file_picker.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rue_app/config/theme.dart';
import 'package:rue_app/controllers/work_controller.dart';
import 'package:rue_app/models/work_model.dart';
import 'package:rue_app/widget.dart';

class WorkReportPage extends StatefulWidget {
  const WorkReportPage({super.key, required this.work});
  final Work work;

  @override
  State<WorkReportPage> createState() => _WorkReportPageState();
}

class _WorkReportPageState extends State<WorkReportPage> {
  List<String> selectedFile = [];
  List<Uint8List> selectedFileInBytes = [];

  @override
  Widget build(BuildContext context) {
    selectFile() async {
      FilePickerResult? fileResult;
      fileResult = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      setState(() {
        if (fileResult != null) {
          for (var i = 0; i < fileResult.count; i++) {
            selectedFile.add("${widget.work.id}/${fileResult.files[i].name}");
            selectedFileInBytes.add(fileResult.files[i].bytes!);
          }
        }
      });
    }

    Work work = widget.work;
    return Title(
      color: Colors.blue,
      title: "Report",
      child: Container(
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
                        onPressed: selectFile,
                        child: const Text("Upload Image")),
                    ElevatedButton(
                      onPressed: () {
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
                            setState(() {
                              selectedFile = [];
                              selectedFileInBytes = [];
                            });
                          }
                        });
                      },
                      child: const Text("Reset"),
                    ),
                    ElevatedButton(
                      onPressed: () {
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
                            work.deliveryDate =
                                DateTime.now().toString().split(" ")[0];
                            uploadReport(
                              work: work,
                              references: selectedFile,
                              files: selectedFileInBytes,
                            ).then((value) {
                              if (value == "success") {
                                Navigator.pop(context);
                              } else {
                                showAlertDialog(context, "Error", value);
                              }
                            });
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
                        for (var byte in selectedFileInBytes)
                          GestureDetector(
                            child: Image.memory(byte),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ImageView(imageBytes: byte),
                                ),
                              );
                            },
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.imageBytes});
  final Uint8List imageBytes;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Image Viewer"),
        ),
        body: Container(
          color: Colors.black,
          height: double.infinity,
          width: double.infinity,
          child: InteractiveViewer(child: Image.memory(imageBytes)),
        ),
      ),
    );
  }
}
