import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rue_app/config/firebase_storage_utils.dart';

var db = FirebaseFirestore.instance;
Future<String> createReport(List<Map<String, dynamic>> data) async {
  final doc = pw.Document();
  final image = await imageFromAssetBundle('assets/images/KOP-RUE.jpg');
  var monthRoman = {
    1: "I",
    2: "II",
    3: "III",
    4: "IV",
    5: "V",
    6: "VI",
    7: "VII",
    8: "VIII",
    9: "IX",
    10: "X",
    11: "XI",
    12: "XII",
  };
  var month = DateTime.now().month;
  var year = DateTime.now().year;
  var reportNumber = await getReportNumber(month: month, year: year) + 1;
  String reportInfo = "No. $reportNumber/LAPORAN/${monthRoman[month]}/$year";
  doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.only(
          left: 0.5 * PdfPageFormat.cm,
          right: 0.5 * PdfPageFormat.cm,
          bottom: 0.5 * PdfPageFormat.cm),
      header: (context) => pw.Image(image),
      footer: (context) {
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.only(
                bottom: 1.5 * PdfPageFormat.cm, top: 0.5 * PdfPageFormat.cm),
            child: pw.Text("${context.pageNumber}"));
      },
      build: (pw.Context context) {
        return [
          pw.Center(
              child: pw.Text("Laporan",
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold))),
          pw.Center(child: pw.Text(reportInfo)),
          pw.Padding(
              padding: const pw.EdgeInsets.only(top: 10),
              child: pw.Column(children: [
                for (Map<String, dynamic> map in data)
                  pw.Column(children: [
                    pw.Table(border: pw.TableBorder.all(width: 1), children: [
                      pw.TableRow(
                          verticalAlignment:
                              pw.TableCellVerticalAlignment.middle,
                          children: [
                            for (String title in map["header"])
                              tableCellTitle(title),
                          ]),
                      for (List<String> list in map["data"])
                        pw.TableRow(
                            verticalAlignment:
                                pw.TableCellVerticalAlignment.middle,
                            children: [
                              for (String cell in list) tableCell(cell),
                            ])
                    ]),
                    pw.SizedBox(height: 1 * PdfPageFormat.cm)
                  ]),
              ]))
        ];
      }));
  String url = await saveReport(
      reportInfo: reportInfo, month: month, year: year, byte: await doc.save());
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save());
  return url;
}

pw.Text tableCellTitle(String text) {
  return pw.Text(
    text,
    textAlign: pw.TextAlign.center,
    style: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
    ),
  );
}

pw.Padding tableCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4.0),
    child: pw.Center(
        child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
    )),
  );
}

Future<int> getReportNumber({required int month, required int year}) async {
  final ref = await db
      .collection("report")
      .where("month", isEqualTo: month)
      .where("year", isEqualTo: year)
      .count()
      .get();

  return ref.count;
}

Future<String> saveReport(
    {required String reportInfo,
    required int month,
    required int year,
    required Uint8List byte}) async {
  String fileName = reportInfo.replaceAll(". ", "").replaceAll("/", "_");
  String fileReference = "Report/$fileName.pdf";
  var upload = {};
  upload = await StorageServices()
      .uploadFile(fileReference, byte, "application/pdf");
  String reference = upload["object"];
  await db.collection("report").add({
    "reportInfo": reportInfo,
    "month": month,
    "year": year,
    "reference": reference,
  });
  return reference;
}

Future<List<Map<String, dynamic>>> getAllReport() async {
  final ref = await db
      .collection("report")
      .orderBy("year", descending: true)
      .orderBy("month", descending: true)
      .orderBy("reportInfo", descending: true)
      .get();

  List<Map<String, dynamic>> list = [];
  for (var map in ref.docs) {
    list.add(map.data());
  }
  return list;
}
