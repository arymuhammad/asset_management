import 'package:assets_management/app/data/helper/currency_format.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:widget_zoom/widget_zoom.dart';

import '../../../../data/Repo/service_api.dart';
import '../../../../data/models/request_detail_model.dart';
import 'add_request.dart';

class DataTableReqform extends StatelessWidget {
  const DataTableReqform({super.key, this.listData});

  final RxList<RequestDetailModel>? listData;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DataTable2(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          // color: Colors.grey[350],
        ),
        headingRowDecoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.grey.shade300),
          // borderRadius: const BorderRadius.only(
          //   topLeft: Radius.circular(8),
          //   bottomLeft: Radius.circular(8),
          // ),
        ),
        
        headingRowHeight: 40,
        empty: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Belum ada data')],
        ),
        lmRatio: 1,
        minWidth: 1200,
        fixedLeftColumns: 1,
        columns: const [
          DataColumn2(label: Text('NO'), fixedWidth: 50),
          DataColumn2(label: Text('ITEM'), fixedWidth: 100),
          DataColumn2(label: Text('DESKRIPSI'), fixedWidth: 200),
          DataColumn2(label: Text('SOH'), fixedWidth: 100),
          DataColumn2(label: Text('REQUEST'), fixedWidth: 120),
          DataColumn2(label: Text('SATUAN'), fixedWidth: 120),
          DataColumn2(label: Text('HARGA/NILAI'), fixedWidth: 150),
          DataColumn2(label: Text('SUB TOTAL'), fixedWidth: 150),
        ],
        rows:
            listData!
                .asMap()
                .entries
                .map((entry) {
                  int index = entry.key;
                  RequestDetailModel data = entry.value;

                  int price = int.tryParse(data.price ?? '0') ?? 0;
                  int qtyReq = int.tryParse(data.qtyReq ?? '1') ?? 1;
                  requestC.total.value = qtyReq * price;

                  return DataRow(
                     color: index % 2 == 0
                                ? WidgetStateProperty.resolveWith((state) =>
                                    const Color.fromARGB(255, 221, 231, 236))
                                : null,
                    cells: [
                      DataCell(Text(data.id ?? '')),
                      DataCell(
                        WidgetZoom(
                          heroAnimationTag: 'product${data.assetName}',
                          zoomWidget: ClipRect(
                            child: Image.network(
                              '${ServiceApi().baseUrl}${data.image ?? ''}',
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Image.asset('assets/image/no-image.jpg'),
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(data.assetName ?? '')),
                      DataCell(Text(data.qtyStock?.toString() ?? '0')),
                      DataCell(
                        SizedBox(
                          height: 30,
                          child: CsTextField(
                            maxLines: 1,
                            label: '',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            initialValue: data.qtyReq ?? '1',
                            onChanged: (val) {
                              // Update the qtyReq in the listData
                              if (val.isEmpty) {
                                val = '1';
                              }
                                data.qtyReq = val;
                               listData!.refresh();
                            },
                          ),
                        ),
                      ),
                      DataCell(Text(data.unit ?? '')),
                      DataCell(Text(CurrencyFormat.convertToIdr(price, 0))),
                      DataCell(
                        Text(
                          CurrencyFormat.convertToIdr(requestC.total.value, 0),
                        ),
                      ),
                      // DataCell(
                      //   IconButton(
                      //     icon: Icon(Icons.delete, color: Colors.red[700],),
                      //     onPressed: () {
                      //       listData!.removeAt(index);
                      //       requestC.tempScanData.removeWhere(
                      //         (item) => item.id == data.id,
                      //       );
                      //       listData!.refresh();
                      //     },
                      //   ),
                      // ),
                    ],
                  );
                })
                .toList()
                .reversed
                .toList(),
      ),
    );
  }
}
