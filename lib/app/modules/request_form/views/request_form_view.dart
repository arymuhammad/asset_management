import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/request_model.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../data/helper/format_waktu.dart';
import '../../../data/shared/text_field.dart';
import '../controllers/request_form_controller.dart';
import 'widget/add_request.dart';

class RequestFormView extends GetView<RequestFormController> {
  RequestFormView({super.key});

  final requestC = Get.find<RequestFormController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(12),
          child:
              requestC.isLoading.value
                  ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Memuat data... '),
                          CupertinoActivityIndicator(),
                        ],
                      ),
                    ],
                  )
                  : Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: Colors.blueGrey[50],
                      dividerColor: Colors.grey[300],
                      textTheme: const TextTheme(
                        bodyMedium: TextStyle(fontSize: 14),
                      ),
                    ),
                    child: PaginatedDataTable2(
                      minWidth: 1300,
                      wrapInCard: true,
                      columnSpacing: 20,
                      horizontalMargin: 12,
                      // columnSpacing: 100,
                      // horizontalMargin: 40,
                      smRatio: 0.9, // Rasio lebar kolom S terhadap M
                      lmRatio: 2.0,
                      // fixedLeftColumns: 1,
                      rowsPerPage: requestC.rowsPerPage,
                      availableRowsPerPage: const [5, 10, 20, 50, 100],
                      onRowsPerPageChanged: (value) {
                        if (value != null) {
                          requestC.rowsPerPage = value;
                        }
                      },
                      renderEmptyRowsInTheEnd: false,
                      showFirstLastButtons: true,
                      empty: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('Belum ada data')],
                      ),
                      headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.grey[400],
                      ),
                      headingRowHeight: 40,

                      actions: [
                        SizedBox(
                          width: 150,
                          height: 35,
                          child: CsTextField(
                            // readOnly: false,
                            label: 'Search Data',
                            onChanged: (val) {
                              requestC.filterDataRequest(val);
                              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                              requestC.requestData.notifyListeners();
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            addRequest(context, RxList.empty(), '');
                            await requestC.generateId();
                            // print(requestC.idReport);
                          },
                          icon: const Icon(HugeIcons.strokeRoundedAddCircle),
                        ),
                      ],
                      header: const Text(
                        'Requst Form',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      columns: const [
                        // DataColumn2(label: Text('ID'), fixedWidth: 150),
                        DataColumn2(
                          label: Center(child: Text('STORE')),
                          fixedWidth: 230,
                        ),
                        DataColumn2(
                          label: Center(child: Text('REQUEST DESCRIPTION')),
                          fixedWidth: 320,
                        ),
                        DataColumn2(
                          label: Center(child: Text('CREATED BY')),
                          fixedWidth: 170,
                        ),
                        DataColumn2(
                          label: Center(child: Text('DATE')),
                          fixedWidth: 150,
                        ),
                        DataColumn2(
                          label: Center(child: Text('ACTION')),
                          fixedWidth: 150,
                        ),
                      ],
                      source: requestC.requestData,
                    ),
                  ),
        );
      }),
    );
  }
}

class RequestData extends DataTableSource {
  RequestData({required this.dataRequest});
  final RxList<RequestModel> dataRequest;
  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    if (index >= dataRequest.length) {
      return null;
    }
    final item = dataRequest[index];

    Color getStatusColor(String status) {
      switch (status.toUpperCase()) {
        case 'ON PROGRESS':
          return Colors.yellow;
        case 'DONE':
          return Colors.green;
        case 'HOLD':
          return Colors.red;
        // case 'OPEN':
        //   return Colors.orange;
        default:
          return Colors.blue;
      }
    }

    return DataRow.byIndex(
      index: index,
      cells: [
        // DataCell(Text(item.id!)),
        DataCell(
          Container(
            color: Colors.yellow,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: InkWell(
                onTap: () async {
                  loadingDialog("Memuat data...", "");
                  // await reportC.getDetailReport(item.id!);
                  // Get.back();
                  // editReport(
                  //   Get.context!,
                  //   item.id!,
                  //   item.cabang!,
                  //   '',
                  //   '',
                  //   '',
                  //   '',
                  //   '',
                  //   item.createdAt!,
                  // );
                },
                child: Text(
                  item.branch!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              item.desc!,
              // softWrap: true,
              // maxLines: 2, // Atur sesuai kebutuhan
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Center(child: Text(item.createdBy!))),
        DataCell(
          Center(
            child: Text(
              FormatWaktu.formatTglBlnThn(tanggal: DateTime.parse(item.date!)),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  // tooltip: item.status! == "ON PROGRESS" ? 'Edit' : 'Show Detail',
                  onPressed: () async {
                    loadingDialog("Memuat data...", "");
                    // await reportC.getDetailReport(item.id!);
                    Get.back();
                    // editReport(
                    //   Get.context!,
                    //   item.id!,
                    //   item.cabang!,
                    //   '',
                    //   '',
                    //   '',
                    //   '',
                    //   '',
                    //   item.createdAt!,
                    // );
                  },
                  icon: const Icon(
                    Icons.print,
                    size: 20,
                    color: Colors.blueAccent,
                  ),
                  splashRadius: 10,
                ),
                IconButton(
                  // tooltip: item.status! == "OPEN" ? 'Cancel' : 'Delete',
                  onPressed: () {
                    // stokC.deleteAssetCategories(item.id!);
                  },
                  icon: Icon(
                    Icons.edit_document,
                    size: 20,
                    color: Colors.greenAccent[700],
                  ),
                  splashRadius: 10,
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
  int get rowCount => dataRequest.length;

  @override
  int get selectedRowCount => 0;
}
