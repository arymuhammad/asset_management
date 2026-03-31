import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/models/report_model.dart';
import 'package:assets_management/app/modules/report_issue/views/widget/add_report.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import '../../../data/Repo/service_api.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/format_waktu.dart';
import '../../../data/models/login_model.dart';
import '../../../data/shared/dropdown.dart';
import '../../../data/shared/text_field.dart';
import '../controllers/report_issue_controller.dart';
import 'widget/drawer_search.dart';
import 'widget/edit_report.dart';

class ReportIssueView extends GetView<ReportIssueController> {
  ReportIssueView({super.key, this.userData, this.branch, required this.isHO});
  final Data? userData;
  final String? branch;
  final bool isHO;
  final reportC = Get.put(ReportIssueController());

  @override
  Widget build(BuildContext context) {
    List<DataColumn> colStore = [
      const DataColumn2(
        label: Center(
          child: Text('Store', style: TextStyle(color: Colors.white)),
        ),
        fixedWidth: 170,
      ),
    ];
    List<DataColumn> colImg = [
      const DataColumn2(
        label: Center(
          child: Text('Image B/A', style: TextStyle(color: Colors.white)),
        ),
        fixedWidth: 100,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
        return Stack(
          children: [
            Scaffold(
              endDrawer: DrawerSearch(
                userData: userData,
                branch: isHO ? branch! : userData!.kodeCabang!,
                isHO: isHO,
              ),
              body: Obx(() {
                if (!reportC.isReady.value || reportC.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: PaginatedDataTable2(
                    headingRowHeight: 40,
                    dataRowHeight: 40, //minimal tinggi baris, bisa disesuaikan
                    columnSpacing: 20,
                    horizontalMargin: 12,
                    minWidth: 1800,
                    wrapInCard: true,
                    // isHorizontalScrollBarVisible: true,
                    // isVerticalScrollBarVisible: true,
                    // columnSpacing: 100,
                    // horizontalMargin: 40,
                    smRatio: 0.9, // Rasio lebar kolom S terhadap M
                    lmRatio: 2.0,
                    fixedLeftColumns: isWideScreen ? 1 : 0,
                    rowsPerPage: reportC.rowsPerPage,
                    availableRowsPerPage: const [5, 10, 20, 50, 100],
                    onRowsPerPageChanged: (value) {
                      if (value != null) {
                        reportC.rowsPerPage = value;
                      }
                    },
                    border: TableBorder.all(),
                    renderEmptyRowsInTheEnd: false,
                    showFirstLastButtons: true,
                    empty:
                        reportC.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text('Belum ada data')],
                            ),
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => AppColors.itemsBackground,
                    ),

                    actions: [
                      InkWell(
                        onTap: () async {
                          loadingDialog('Refresh data', '');
                          await reportC.getReport(
                            isHO ? branch : userData!.kodeCabang,
                          );
                          reportC.statusSelected.value = "";
                          reportC.filterDataReport('');
                          Get.back();
                          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                          reportC.dataSource.notifyListeners();
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.itemsBackground,
                          ),
                          // decoration: const BoxDecoration(color: AppColors.itemsBackground),
                          child: const Icon(
                            Icons.refresh_outlined,
                            size: 24.0,
                            color: AppColors.contentColorWhite,
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   width: 150,
                      //   height: 35,
                      //   child: DateTimeField(
                      //     controller: reportC.datePeriode,
                      //     style: const TextStyle(fontSize: 14),
                      //     decoration: const InputDecoration(
                      //       contentPadding: EdgeInsets.all(0.5),
                      //       prefixIcon: Icon(Icons.calendar_month_sharp),
                      //       hintText: 'Pilih Periode',
                      //       border: OutlineInputBorder(),
                      //     ),
                      //     onChanged: (periode) async {
                      //       if (periode == null) {
                      //         // || periode == DateTime.parse(reportC.initDate.value)
                      //         // reportC.initDate.value = DateFormat(
                      //         //   'yyyy-MM-dd',
                      //         // ).format(
                      //         //   DateTime.parse(
                      //         //     DateTime(
                      //         //       DateTime.now().year,
                      //         //       DateTime.now().month,
                      //         //       1,
                      //         //     ).toString(),
                      //         //   ),
                      //         // );
                      //         // reportC.endDate.value = DateFormat(
                      //         //   'yyyy-MM-dd',
                      //         // ).format(
                      //         //   DateTime.parse(
                      //         //     DateTime(
                      //         //       DateTime.now().year,
                      //         //       DateTime.now().month + 1,
                      //         //       0,
                      //         //     ).toString(),
                      //         //   ),
                      //         // );
                      //       } else {
                      //         // reportC.isLoading.value = true;
                      //         reportC.filterDataReport('');

                      //         reportC.initDate.value = DateFormat(
                      //           'yyyy-MM-dd',
                      //         ).format(periode);
                      //         reportC.endDate.value = DateFormat(
                      //           'yyyy-MM-dd',
                      //         ).format(
                      //           DateTime(periode.year, periode.month + 1, 0),
                      //         );
                      //         await reportC.getReport();

                      //         // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                      //         reportC.dataSource.notifyListeners();
                      //         getDefaultSnackbar(
                      //           title: 'Success',
                      //           desc:
                      //               'Showing report & maintenance data\nperiode ${reportC.datePeriode.text}',
                      //           success: true,
                      //         );

                      //         // salC.isLoading.value = true;
                      //       }
                      //     },
                      //     format: DateFormat("MMM yyyy"),
                      //     onShowPicker: (context, currentValue) {
                      //       return showMonthYearPicker(
                      //         context: context,
                      //         firstDate: DateTime(2000),
                      //         initialDate: currentValue ?? DateTime.now(),
                      //         lastDate: DateTime(2100),
                      //       );
                      //     },
                      //   ),
                      // ),
                      Visibility(
                        visible: isWideScreen ? true : false,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 35,
                              child: Obx(
                                () => CsDropDown(
                                  label: 'Select Status',
                                  value:
                                      reportC.statusSelected.isNotEmpty
                                          ? reportC.statusSelected.value
                                          : null,
                                  items:
                                      reportC.listStatus
                                          .map(
                                            (data) => DropdownMenuItem(
                                              value: data,
                                              child: Text(data),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                  // reportC.isUpdate.value
                                  // ?
                                  (val) {
                                    loadingDialog('Refresh data', '');
                                    Future.delayed(
                                      const Duration(seconds: 1),
                                      () async {
                                        reportC.statusSelected.value =
                                            val ?? '';
                                        await reportC.getReportBySts(
                                          val,
                                          isHO
                                              ? branch!
                                              : userData!.kodeCabang!,
                                        );
                                        Get.back();
                                      },
                                    );
                                  },
                                  // : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              width: 150,
                              height: 35,
                              child: CsTextField(
                                // readOnly: false,
                                controller: reportC.searchController,
                                label: 'Search Data',
                                onChanged: (val) {
                                  reportC.filterDataReport(val);
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  reportC.dataSource.notifyListeners();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed:
                        // userData!.kodeCabang == "HO000"
                        //     ? null
                        //     :
                        () async {
                          await reportC.generateNumbId();
                          // print('id Report : ${reportC.idReport.text}');
                          // ignore: use_build_context_synchronously
                          // reportC.isUpdate.value = false;
                          reportC.isUpdate.value = true;
                          // reportC.isEdit.value = true;
                          addReport(
                            context,
                            reportC.idReport.text,
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            userData,
                          );
                          // print(reportC.idReport);
                        },
                        icon: const Icon(HugeIcons.strokeRoundedAddCircle),
                        tooltip: 'Add Report',
                        splashRadius: 10,
                      ),
                    ],
                    header: const Text(
                      'Report & Maintenance',
                      style: TextStyle(fontSize: 15),
                    ),
                    columns: [
                      // DataColumn2(label: Text('ID'), fixedWidth: 150),
                      ...userData!.levelUser!.contains('IT') ||
                              userData!.levelUser!.contains('BRAND') ||
                              userData!.levelUser!.contains('AREA')
                          ? colStore
                          : [],
                      const DataColumn2(
                        label: Center(
                          child: Text(
                            'No',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        fixedWidth: 55,
                      ),
                      const DataColumn2(
                        label: Center(
                          child: Text(
                            'Report',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        fixedWidth: 350,
                      ),
                      ...colImg,
                      const DataColumn2(
                        label: Center(
                          child: Text(
                            'Date',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        fixedWidth: 120,
                      ),
                      const DataColumn2(
                        label: Center(
                          child: Text(
                            'Priority',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        fixedWidth: 95,
                      ),
                      const DataColumn2(
                        label: Center(
                          child: Text(
                            'Status',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        fixedWidth: 110,
                      ),
                      const DataColumn2(
                        label: Center(
                          child: Text(
                            'Progress',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        fixedWidth: 250,
                      ),
                      const DataColumn2(
                        label: Center(
                          child: Text(
                            'Issue',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        fixedWidth: 200,
                      ),
                      const DataColumn2(
                        label: Center(
                          child: Text(
                            'Note',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        fixedWidth: 200,
                      ),
                      const DataColumn2(
                        label: Center(
                          child: Text(
                            'Action',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        fixedWidth: 90,
                      ),
                    ],
                    source: reportC.dataSource,
                  ),
                );
              }),
              floatingActionButton:
                  !isWideScreen
                      ? Builder(
                        builder: (context) {
                          return FloatingActionButton(
                            backgroundColor: AppColors.itemsBackground,
                            onPressed: () {
                              // seachForm(context);
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: const Icon(Icons.search),
                          );
                        },
                      )
                      : null,
            ),

            Visibility(
              visible: userData!.kodeCabang == "HO000",
              child: Positioned(
                top: 0,
                left: 3,
                child: IconButton(
                  onPressed: reportC.backToList,
                  icon: Icon(Icons.cancel, color: red),
                  splashRadius: 10,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

seachForm(context) {
  showDialog(
    context: context,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(8),
            content: SizedBox(
              width: 150,
              height: 35,
              child: CsTextField(
                // readOnly: false,
                controller: reportC.searchController,
                maxLines: 1,
                label: 'Search Data',
                onChanged: (val) {
                  reportC.filterDataReport(val);
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  reportC.dataSource.notifyListeners();
                },
              ),
            ),
          );
        },
      );
    },
  );
}

class ReportData extends DataTableSource {
  ReportData({required this.dataReport, this.dataUser});
  RxList<Report> dataReport;
  final Data? dataUser;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    if (index >= dataReport.length) {
      return null;
    }
    final item = dataReport[index];

    //item report
    List<String> numReport = [];
    List<String> joinDate = [];
    List<String> joinedProgress = [];
    List<String> joinedIssue = [];
    List<String> joinedKeterangan = [];
    List<String> itemPrior = [];
    List<String> itemSts = [];
    List<String> imgB = [];
    List<String> imgA = [];

    // numbReport
    if (item.report != null && item.report!.trim().isNotEmpty) {
      numReport = item.report!.split(',').map((e) => e.trim()).toList();
    } else {
      numReport = ['empty'];
    }

    //item priority
    if (item.priority != null && item.priority!.trim().isNotEmpty) {
      itemPrior = item.priority!.split(',').map((e) => e.trim()).toList();
    } else {
      itemPrior = ['empty'];
    }

    //item status
    if (item.status != null && item.status!.trim().isNotEmpty) {
      itemSts = item.status!.split(',').map((e) => e.trim()).toList();
    } else {
      itemSts = ['empty'];
    }

    //item progress
    if (item.progress != null && item.progress!.trim().isNotEmpty) {
      joinedProgress = item.progress!.split(',').map((e) => e.trim()).toList();
    } else {
      joinedProgress = ['empty'];
    }

    //item issue
    if (item.issue != null && item.issue!.trim().isNotEmpty) {
      joinedIssue = item.issue!.split(',').map((e) => e.trim()).toList();
    } else {
      joinedIssue = ['empty'];
    }

    //item keterangan
    if (item.keterangan != null && item.keterangan!.trim().isNotEmpty) {
      joinedKeterangan =
          item.keterangan!.split(',').map((e) => e.trim()).toList();
    } else {
      joinedKeterangan = ['empty'];
    }

    //item image before
    if (item.imageBf != null && item.imageBf!.trim().isNotEmpty) {
      imgB = item.imageBf!.split(',').map((e) => e.trim()).toList();
    } else {
      imgB = ['empty'];
    }

    //item image after
    if (item.imageAf != null && item.imageAf!.trim().isNotEmpty) {
      imgA = item.imageAf!.split(',').map((e) => e.trim()).toList();
    } else {
      imgA = ['empty'];
    }

    //item date

    joinDate = item.date!.split(',').map((e) => e.trim()).toList();

    Color getStatusColor(String status) {
      switch (status.toUpperCase()) {
        case 'ON PRGS':
          return Colors.yellowAccent[700]!;
        case 'DONE':
          return darkGreen;
        case 'HOLD':
          return Colors.redAccent[700]!;
        case 'FU':
          return Colors.blueAccent[700]!;
        case 'RE SCHE':
          return Colors.black;
        case 'P1':
          return Colors.redAccent[700]!;
        case 'P2':
          return Colors.yellowAccent[700]!;
        case 'P3':
          return darkGreen;
        // case 'OPEN':
        //   return Colors.orange;
        default:
          return Colors.white;
      }
    }

    // String insertNewlineAfter3Space(String input) {
    //   List<String> words = input.split(' ');
    //   List<String> chunks = [];

    //   for (int i = 0; i < words.length; i += 3) {
    //     // Ambil 3 kata sekaligus (atau kurang kalau sisa kurang dari 3)
    //     chunks.add(words.skip(i).take(3).join(' '));
    //   }

    //   return chunks.join('\n');
    // }

    List<DataCell> cellStore = [
      DataCell(
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: InkWell(
              onTap:
              // dataUser!.levelUser!.contains('IT') ||
              //         dataUser!.levelUser!.contains('BRAND')
              //     ?
              () async {
                loadingDialog("Memuat data...", "");
                await reportC.getDetailReport(
                  dataUser!.kodeCabang!,
                  item.kodeCabang!,
                  item.uid!,
                );
                Get.back();
                editReport(
                  Get.context!,
                  item.id!,
                  item.kodeCabang!,
                  item.cabang!,
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  item.createdAt!,
                  item.createdBy!,
                  dataUser!,
                );
              },
              // : () async {
              //   loadingDialog("Memuat data...", "");
              //   await reportC.getDetailReport(item.kodeCabang!);
              //   reportC.tempListReport.addAll(reportC.detailDataReport);
              //   Get.back();
              //   addReport(
              //     Get.context!,
              //     item.id!,
              //     '',
              //     '',
              //     '',
              //     '',
              //     '',
              //     item.date!,
              //   );
              // },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // insertNewlineAfter3Space(item.cabang!),
                    item.cabang!,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Wrap(
                  //   spacing: 8, // Jarak antar user
                  //   runSpacing: 4,
                  //   children:
                  //       item.createdBy!
                  //           .split(',')
                  //           .map((e) => e.trim())
                  //           .toSet() // hapus duplikat disini
                  //           .toList()
                  //           .map(
                  //             (e) => Row(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 const Icon(Icons.person, size: 18),
                  //                 const SizedBox(width: 3),
                  //                 SizedBox(
                  //                   width: 130,
                  //                   child: Text(
                  //                     e.trim().capitalize!,
                  //                     style: const TextStyle(
                  //                       color: Colors.black,
                  //                       fontWeight: FontWeight.bold,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           )
                  //           .toList(),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
    List<DataCell> cellImg = [
      DataCell(
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      imgB.asMap().entries.map((val) {
                        String imgItem = val.value;
                        // if (imgItem.length > 37) {
                        //   imgItem = '${imgItem.substring(0, 37)}...';
                        // }
                        // print(imgItem);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2.5),
                          // padding: const EdgeInsets.symmetric(
                          //   horizontal: 1,
                          //   // vertical: 4,
                          // ),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: Get.context!,
                                builder: (context) {
                                  reportC.disableRightClick();
                                  return Dialog(
                                    backgroundColor: Colors.black,
                                    insetPadding: const EdgeInsets.all(0),
                                    child: GestureDetector(
                                      onSecondaryTapDown:
                                          reportC
                                              .storePosition, // Tangkap posisi klik kanan
                                      onSecondaryTap:
                                          () async => reportC.showCustomMenu(
                                            context,
                                            '${ServiceApi().baseUrl}$imgItem',
                                            false,
                                          ),
                                      // onLongPress: () async {
                                      //   // try {
                                      //   reportC.copyImageToClipboard(
                                      //     context,
                                      //     '${ServiceApi().baseUrl}$imgItem',
                                      //     false,
                                      //   );
                                      //   // } catch (e) {
                                      //   //   failedDialog(
                                      //   //     context,
                                      //   //     'error',
                                      //   //     'Failed to copy image: $e',
                                      //   //     isWideScreen,
                                      //   //   );
                                      //   // }
                                      // },
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        reportC.enableRightClick();
                                      },
                                      child: PhotoView(
                                        imageProvider: NetworkImage(
                                          '${ServiceApi().baseUrl}$imgItem',
                                        ),
                                        backgroundDecoration:
                                            const BoxDecoration(
                                              color: Colors.black,
                                            ),
                                        minScale:
                                            PhotoViewComputedScale.contained,
                                        maxScale:
                                            PhotoViewComputedScale.covered * 3,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(
                              imgItem != "empty" ? 'Img B  /  ' : '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.contentColorBlue,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children:
                      imgA.asMap().entries.map((e) {
                        String imgItemA = e.value;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2.5),
                          // padding: const EdgeInsets.symmetric(
                          //   horizontal: 1,
                          //   // vertical: 4,
                          // ),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: Get.context!,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: Colors.black,
                                    insetPadding: const EdgeInsets.all(0),
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: PhotoView(
                                        imageProvider: NetworkImage(
                                          '${ServiceApi().baseUrl}$imgItemA',
                                        ),
                                        backgroundDecoration:
                                            const BoxDecoration(
                                              color: Colors.black,
                                            ),
                                        minScale:
                                            PhotoViewComputedScale.contained,
                                        maxScale:
                                            PhotoViewComputedScale.covered * 3,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(
                              imgItemA == "empty" ? '' : 'Img A',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.contentColorBlue,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
    return DataRow.byIndex(
      index: index,
      cells: [
        // DataCell(Text(item.id!)),
        ...dataUser!.levelUser!.contains('IT') ||
                dataUser!.levelUser!.contains('BRAND') ||
                dataUser!.levelUser!.contains('AREA')
            ? cellStore
            : [],
        DataCell(
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children:
                    numReport.asMap().entries.map((entry) {
                      int reportLength = index + 1;
                      int idx = entry.key + 1; // nomor urut mulai dari 1

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          // vertical: 4,
                        ),
                        // decoration: BoxDecoration(
                        //   color: getStatusColor(prior),
                        //   borderRadius: BorderRadius.circular(4),
                        // ),
                        child: Text(
                          idx == 0
                              ? ''
                              : '$reportLength', // menambahkan nomor urut di depan status
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),

        DataCell(
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children:
                    numReport.map((val) {
                      String reportItem = val.toUpperCase();
                      if (reportItem.length > 37) {
                        reportItem = '${reportItem.substring(0, 37)}...';
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          // vertical: 4,
                        ),
                        child: Text(
                          reportItem,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          // Text(
          //   joinedReport,
          //   style: const TextStyle(fontSize: 12),
          //   // softWrap: true,
          //   // maxLines: 2, // Atur sesuai kebutuhan
          //   // overflow: TextOverflow.ellipsis,
          // ),
        ),
        ...cellImg,
        DataCell(
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children:
                    joinDate.asMap().entries.map((date) {
                      // String reportItem = val.toUpperCase();
                      // if (reportItem.length > 37) {
                      //   reportItem = '${reportItem.substring(0, 37)}...';
                      // }
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          // vertical: 4,
                        ),
                        child: Text(
                          FormatWaktu.formatTglBlnThn(
                            tanggal: DateTime.parse(date.value),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children:
                    itemPrior.asMap().entries.map((entry) {
                      // int idx = entry.key + 1; // nomor urut mulai dari 1
                      String prior = entry.value;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          // vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor(prior),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          // '${prior == "empty" ? '' : '$idx.'} ${prior == "empty" ? '' : prior}', // menambahkan nomor urut di depan status
                          prior == "empty"
                              ? ''
                              : prior, // menambahkan nomor urut di depan status
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children:
                    itemSts.asMap().entries.map((entry) {
                      // int idx = entry.key + 1; // nomor urut mulai dari 1
                      String status = entry.value;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          // vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor(status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          // '${status == "empty" ? '' : '$idx.'} ${status == "empty" ? '' : status}', // menambahkan nomor urut di depan status
                          status == "empty"
                              ? ''
                              : status, // menambahkan nomor urut di depan status
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children:
                    joinedProgress.map((val) {
                      String progressItem = val.toUpperCase();
                      if (progressItem.length > 29) {
                        progressItem = '${progressItem.substring(0, 29)}...';
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.5),
                        padding: const EdgeInsets.symmetric(
                          // horizontal: 8,
                          // vertical: 4,
                        ),
                        child: Text(
                          progressItem == "EMPTY" ? '' : progressItem,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children:
                    joinedIssue.map((val) {
                      String issueItem = val.toUpperCase();
                      if (issueItem.length > 22) {
                        issueItem = '${issueItem.substring(0, 22)}...';
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.5),
                        padding: const EdgeInsets.symmetric(
                          // horizontal: 8,
                          // vertical: 4,
                        ),
                        child: Text(
                          issueItem == "EMPTY" ? '' : issueItem,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children:
                    joinedKeterangan.map((val) {
                      String noteItem = val.toUpperCase();
                      if (noteItem.length > 22) {
                        noteItem = '${noteItem.substring(0, 22)}...';
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.5),
                        padding: const EdgeInsets.symmetric(
                          // horizontal: 8,
                          // vertical: 4,
                        ),
                        child: Text(
                          noteItem == "EMPTY" ? '' : noteItem.capitalize!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible:
                      dataUser!.levelUser!.contains('IT') ||
                              dataUser!.levelUser!.contains('BRAND')
                          ? false
                          : true,
                  child: IconButton(
                    tooltip: 'Edit',
                    onPressed: () async {
                      loadingDialog("Memuat data...", "");
                      await reportC.getDetailReport(
                        dataUser!.kodeCabang!,
                        item.kodeCabang!,
                        item.uid!,
                      );
                      // reportC.isEdit.value = true;
                      reportC.isUpdate.value = false;
                      Get.back();
                      addReport(
                        Get.context!,
                        item.id!,
                        item.div!,
                        item.report,
                        '',
                        '',
                        item.status,
                        item.uid!,
                        item.date!,
                        dataUser,
                      );
                    },
                    icon: const Icon(Icons.edit, size: 20, color: Colors.green),
                    splashRadius: 10,
                  ),
                ),
                Visibility(
                  visible:
                      dataUser!.levelUser!.contains('IT') ||
                              dataUser!.levelUser!.contains('BRAND')
                          ? true
                          : false,
                  child: IconButton(
                    tooltip:
                        item.status! == "ON PROGRESS" ? 'Edit' : 'Show Detail',
                    onPressed: () async {
                      loadingDialog("Memuat data...", "");
                      await reportC.getDetailReport(
                        dataUser!.kodeCabang!,
                        item.kodeCabang!,
                        item.uid!,
                      );
                      Get.back();
                      editReport(
                        Get.context!,
                        item.id!,
                        item.kodeCabang!,
                        item.cabang!,
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        item.createdAt!,
                        item.createdBy!,
                        dataUser!,
                      );
                    },
                    icon: Icon(
                      item.status! == "ON PROGRESS"
                          ? Icons.edit
                          : Icons.remove_red_eye_outlined,
                      size: 20,
                      color: Colors.green,
                    ),
                    splashRadius: 10,
                  ),
                ),
                Visibility(
                  visible:
                      dataUser!.levelUser!.contains('IT') ||
                              dataUser!.levelUser!.contains('BRAND')
                          ? true
                          : false,
                  child: IconButton(
                    tooltip: 'Print',
                    onPressed: () async {
                      await reportC.getDetailReport(
                        dataUser!.kodeCabang!,
                        item.kodeCabang!,
                        item.uid!,
                      );
                      reportC.printReport();
                    },
                    icon: Icon(
                      Icons.print_rounded,
                      size: 20,
                      color: Colors.blueAccent[700],
                    ),
                    splashRadius: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dataReport.length;

  @override
  int get selectedRowCount => 0;
}
