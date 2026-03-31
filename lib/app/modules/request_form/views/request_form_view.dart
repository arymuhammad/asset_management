import 'package:assets_management/app/data/helper/app_colors.dart';
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

  final requestC = Get.put(RequestFormController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
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
                      : PaginatedDataTable2(
                        minWidth: 1300,
                        wrapInCard: true,
                        columnSpacing: 20,
                        horizontalMargin: 12,
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
                          (states) => AppColors.itemsBackground,
                        ),
                        headingRowHeight: 40,

                        actions: [
                          Visibility(
                            visible: isWideScreen ? true : false,
                            child: SizedBox(
                              width: 150,
                              height: 35,
                              child: CsTextField(
                                // readOnly: false,
                                controller: requestC.searchController,
                                maxLines: 1,
                                label: 'Search Data',
                                onChanged: (val) {
                                  requestC.filterDataRequest(val);
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  requestC.requestData.notifyListeners();
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              loadingDialog("Memuat data...", "");
                              await requestC.generateId();
                              await requestC.fetchCatAsset(requestC.branchCode);
                              if (!context.mounted) return;
                              Get.back();
                              addRequest(
                                context,
                                '',
                                '',
                                requestC.branchCode,
                                '',
                                '',
                                RxList.empty(),
                              );
                              // print(requestC.idReport);
                            },
                            icon: const Icon(HugeIcons.strokeRoundedAddCircle),
                            tooltip: 'Add Request',
                          ),
                        ],
                        header: const Text(
                          'Requst Form',
                          style: TextStyle(fontSize: 15),
                        ),
                        columns: const [
                          // DataColumn2(label: Text('ID'), fixedWidth: 150),
                          DataColumn2(
                            label: Center(
                              child: Text(
                                'STORE',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            fixedWidth: 180,
                          ),
                          DataColumn2(
                            label: Center(
                              child: Text(
                                'REQUEST DESCRIPTION',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            fixedWidth: 320,
                          ),
                          DataColumn2(
                            label: Center(
                              child: Text(
                                'CATEGORY',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            fixedWidth: 200,
                          ),
                          DataColumn2(
                            label: Center(
                              child: Text(
                                'CREATED BY',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            fixedWidth: 170,
                          ),
                          DataColumn2(
                            label: Center(
                              child: Text(
                                'DATE',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            fixedWidth: 120,
                          ),
                          DataColumn2(
                            label: Center(
                              child: Text(
                                'ACTION',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            fixedWidth: 120,
                          ),
                        ],
                        source: requestC.requestData,
                      ),
            );
          }),
          floatingActionButton:
              !isWideScreen
                  ? FloatingActionButton(
                    backgroundColor: AppColors.itemsBackground,
                    onPressed: () {
                      seachForm(context);
                    },
                    child: const Icon(Icons.search),
                  )
                  : null,
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
                controller: requestC.searchController,
                maxLines: 1,
                label: 'Search Data',
                onChanged: (val) {
                  requestC.filterDataRequest(val);
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  requestC.requestData.notifyListeners();
                },
              ),
            ),
          );
        },
      );
    },
  );
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
                  await requestC.getDetailRequest(item.id!);
                  Get.back();
                  requestC.grandTotal.value = 0;
                  addRequest(
                    Get.context!,
                    item.id!,
                    item.group!,
                    item.branchCode!,
                    item.desc!,
                    item.category!,
                    requestC.detailRequest,
                  );
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
        DataCell(Center(child: Text(item.desc!.capitalize!))),
        DataCell(Center(child: Text(item.categoryName!.capitalize!))),
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
                    await requestC.getDetailRequest(item.id!);
                    Get.back();
                    requestC.printReqForm();
                  },
                  icon: const Icon(
                    Icons.print,
                    size: 20,
                    color: Colors.blueAccent,
                  ),
                  splashRadius: 10,
                ),
                Visibility(
                  visible: requestC.branchCode != "HO000" ? false : true,
                  child: IconButton(
                    // tooltip: item.status! == "OPEN" ? 'Cancel' : 'Delete',
                    onPressed: () async {
                      loadingDialog("Memuat data...", "");
                      await requestC.getDetailRequest(item.id!);
                      Get.back();
                      requestC.grandTotal.value = 0;
                      addRequest(
                        Get.context!,
                        item.id!,
                        item.group!,
                        item.branchCode!,
                        item.desc!,
                        item.category!,
                        requestC.detailRequest,
                      );
                    },
                    icon: Icon(
                      Icons.edit_document,
                      size: 20,
                      color: Colors.greenAccent[700],
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
  int get rowCount => dataRequest.length;

  @override
  int get selectedRowCount => 0;
}
