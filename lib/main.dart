import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  await Permission.storage.request();
  runApp(MyApp());
}

Map<int, String> notices = {
  1: "Assessment Plan for August - September 2020",
  10: "Time Table - Civil",
  11: "Time Table - Chemical",
  12: "Time Table - Biotech",
  13: "Time Table - Biomedical",
  14: "Time Table - Aero & Auto",
  15: "NRI FEE SCHEDULE 2020-21 WITH BANK DETAIL",
  16: "NRI FEE SCHEDULE 2020-21 WITH BANK DETAIL",
  17: "AICTE FEE SCHEDULE",
  18: "FEE SCHEDULE 2020-21",
  19: "FEE SCHEDULE 2020-21",
  2: "Time Table - Media Technology",
  20: "FEE SCHEDULE 2020-21",
  21: "FEE SCHEDULE 2020-21",
  22: "FEE NOTIFICATION 2020-21 2019 BATCH",
  23: "FEE NOTIFICATION 2020-21",
  24: "Notice: Re-registration of M.Tech./ MCA courses - July 2020",
  25: "NOTICE: Re-registration of B.Tech. III/V/VII Semester Courses",
  26: "NOTICE: Re-registration of Mathematics-I - July 2020",
  27: "Fee Notification: III and IV Year",
  28: "Fee Notification 2019 admission",
  29: "Fee Notification: III and IV Year",
  3: "Time Table - Mechatronics",
  30: "Fee Notification",
  31: "Notice: For Reject & Rejoin",
  32: "Special Exam Time Table (July 2020) for students admitted prior to 2014",
  33: "Announcement of Results",
  34: "MIT-Start of New Semester-August 2020",
  35: "SPECIAL EXAM REGISTRATION FOR ODD AND EVEN SEMESTER COURSES (Revised) - UG students admitted prior to 2014 (Course Completed) and PG students",
  36: "Standard Operating Procedure (SoP) for evaluation and grading for the current semester at MIT Manipal",
  37: "Schedule for Sessional Re-test (I or II)",
  38: "VI Semester Revised Sessional Test II Time Table",
  39: "IV Semester Sessional Time Table",
  4: "Time Table - Mechanical & IP",
  40: "Circular: June 6, 2020",
  5: "Time Table - IT & CCE",
  6: "Time Table - Dept of ICE",
  7: "Time Table - E&C",
  8: "Time Table - EEE",
  9: "Time Table - Computer Science"
};

Map<String, String> dwnldList = {
  "Assessment Plan for August - September 2020":
      "AttachmentAssessment_Plan_for_August_-_S..pdf",
  "Time Table - Media Technology": "AttachmentMedia_Technology..pdf",
  "Time Table - Mechatronics": "AttachmentMechatronics..pdf",
  "Time Table - Mechanical & IP": "AttachmentMech_-_IP..pdf",
  "Time Table - IT & CCE": "AttachmentIT-CCE..pdf",
  "Time Table - Dept of ICE": "AttachmentElectronics_&_Instrumentation..pdf"
};

List<String> noticeC = [];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

bool show = false;

class _MyHomePageState extends State<MyHomePage> {
  bool isSearching = false;
  TextEditingController _searchCont;
  String searchQuery;
  int noRows = 10;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    //noticeC = notices.values.toList();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  List<DataRow> generateRows() {
    List<DataRow> temp = [];
    for (var item in notices.keys) {
      temp.add(DataRow(cells: [
        DataCell(Text(item.toString())),
        DataCell(Text(notices[item]))
      ]));
    }
    return temp;
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('SLcM Notices'),
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: [
              PaginatedDataTable(
                rowsPerPage: noRows,
                onRowsPerPageChanged: (value) {
                  setState(() {
                    noRows = value;
                  });
                },
                availableRowsPerPage: [5, 10, 15, 20],
                header: Center(
                  child: Text(isSearching ? '' : 'Important Documents'),
                ),
                actions: <Widget>[
                  isSearching
                      ? Center(
                          child: Container(
                            child: TextField(
                              controller: _searchCont,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  noticeC = [];
                                  for (var item in notices.values) {
                                    if (item.contains(value) ||
                                        item.contains(value.toLowerCase()) ||
                                        item.contains(value.toUpperCase())) {
                                      noticeC.add(item);
                                    }
                                  }
                                  //print(noticeC);
                                  setState(() {
                                    show = true;
                                  });
                                } else {
                                  setState(() {
                                    show = false;
                                  });
                                }
                              },
                              // onEditingComplete: () {
                              //   for (var item in noticeC) {
                              //     if (item.contains(_searchCont.text)) {
                              //       //continue;
                              //     } else {
                              //       noticeC.remove(item);
                              //     }
                              //   }
                              //   setState(() {
                              //     show = true;
                              //   });
                              // },
                              // onSubmitted: (value) {
                              //   for (var item in noticeC) {
                              //     if (item.contains(value)) {
                              //       //continue;
                              //     } else {
                              //       noticeC.remove(item);
                              //     }
                              //   }
                              //   setState(() {
                              //     show = true;
                              //   });
                              // },
                            ),
                            width: MediaQuery.of(context).size.width - 90,
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            setState(() {
                              isSearching = true;
                            });
                          },
                        )
                ],
                columns: <DataColumn>[
                  DataColumn(
                    label: Text('S. No'),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text('Title'),
                  )
                ],
                source: UserDataTable(context: context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserDataTable extends DataTableSource {
  final BuildContext context;
  UserDataTable({this.context});
  Iterable<int> temp = notices.keys;
  var tter = notices.keys.toList()..sort();
  void downld(String file) async {
    Directory tempDir = await getExternalStorageDirectory();
    String dirPath = tempDir.path;
    String taskId;
    try {
      taskId = await FlutterDownloader.enqueue(
        url: 'https://prakharb10.pythonanywhere.com/files/$file',
        savedDir: dirPath,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    } catch (e) {} finally {
      FlutterDownloader.open(taskId: taskId);
    }
  }

  @override
  int get rowCount => show ? noticeC.length : notices.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  DataRow getRow(int index) {
    // IMPLEMENT HERE
    return DataRow.byIndex(cells: [
      DataCell(Text(show ? (index + 1).toString() : tter[index].toString())),
      DataCell(
        Container(
          child: Text(show ? noticeC[index] : notices[tter[index]]),
          //constraints: BoxConstraints.tight(Size.fromWidth(MediaQuery.of(context).size.width-10)),
        ),
        onTap: () {
          var filename =
              dwnldList[show ? noticeC[index] : notices[tter[index]]];
          downld(filename);
        },
      )
    ], index: index);
  }

  @override
  int get selectedRowCount => 0;
}
