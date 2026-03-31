import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/helper/currency_format.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
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
  const DataTableReqform({
    super.key,
    required this.listData,
    this.id,
    this.branch,
    this.desc,
  });

  final RxList<RequestDetailModel> listData;
  final String? id;
  final String? branch;
  final String? desc;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Expanded(
            child: DataTable2(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                // borderRadius: BorderRadius.circular(8),
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
              columns: [
                const DataColumn2(label: Text('NO'), fixedWidth: 50),
                const DataColumn2(label: Text('ITEM'), fixedWidth: 100),
                const DataColumn2(label: Text('DESKRIPSI'), fixedWidth: 200),
                const DataColumn2(label: Text('SOH'), fixedWidth: 100),
                const DataColumn2(label: Text('REQUEST'), fixedWidth: 120),
                const DataColumn2(label: Text('SATUAN'), fixedWidth: 120),
                const DataColumn2(label: Text('HARGA/NILAI'), fixedWidth: 150),
                const DataColumn2(label: Text('SUB TOTAL'), fixedWidth: 150),
                DataColumn2(
                  label: Text(branch == "HO000" ? 'ACTION' : 'STATUS'),
                  fixedWidth: id!.isNotEmpty ? 100 : 0,
                ),
              ],
              rows:
                  listData.asMap().entries.map((entry) {
                    int index = entry.key;
                    RequestDetailModel data = entry.value;
                    int price = int.tryParse(data.price ?? '0') ?? 0;
                    int qtyReq = int.tryParse(data.qtyReq ?? '0') ?? 0;
                    final int subTotal = qtyReq * price;
                    // requestC.grandTotal.value = requestC.tempData.fold(
                    //   0,
                    //   (prev, item) =>
                    //       prev +
                    //       ((int.tryParse(item.price ?? '0') ?? 0) *
                    //           (int.tryParse(item.qtyReq ?? '0') ?? 0)),
                    // );
                    // requestC.tempData.refresh();
                    return DataRow(
                      color:
                          index % 2 == 0
                              ? WidgetStateProperty.resolveWith(
                                (state) =>
                                    const Color.fromARGB(255, 221, 231, 236),
                              )
                              : null,
                      cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(
                          WidgetZoom(
                            heroAnimationTag:
                                'product_${data.assetCode ?? index}',
                            zoomWidget: ClipRect(
                              child: Image.network(
                                '${ServiceApi().baseUrl}${data.image ?? ''}',
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Image.asset(
                                      'assets/image/no-image.jpg',
                                    ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text((data.assetName ?? '').capitalize ?? '')),
                        DataCell(Text(data.qtyStock?.toString() ?? '0')),
                        DataCell(
                          SizedBox(
                            height: 30,
                            child: CsTextField(
                              enabled:
                                  data.sts != "accepted" &&
                                  data.sts != "canceled",
                              maxLines: 1,
                              label: '',
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              initialValue: data.qtyReq ?? '0',
                              onChanged: (val) {
                                // Update the qtyReq in the listData
                                if (val.isEmpty) {
                                  val = '0';
                                }
                                data.qtyReq = val;
                                requestC.recalcTotal();
                                listData.refresh();
                              },
                            ),
                          ),
                        ),
                        DataCell(Text(data.unit ?? '')),
                        DataCell(Text(CurrencyFormat.convertToIdr(price, 0))),
                        DataCell(
                          Text(CurrencyFormat.convertToIdr(subTotal, 0)),
                        ),
                        id!.isNotEmpty
                            ? DataCell(
                              Visibility(
                                visible: (data.qtyReq ?? '0') != "0",
                                child:
                                    (data.sts ?? "") == ""
                                        ? Row(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                loadingDialog(
                                                  "memuat data",
                                                  '',
                                                );
                                                await requestC.accReqItem(
                                                  id!,
                                                  data.assetCode!,
                                                );
                                                await requestC.getDetailRequest(
                                                  id!,
                                                );
                                                Get.back();
                                                Get.back();
                                                requestC.grandTotal.value = 0;

                                                addRequest(
                                                  Get.context!,
                                                  id!,
                                                  '',
                                                  branch!,
                                                  desc!,
                                                  '',
                                                  requestC.detailRequest,
                                                );
                                              },
                                              child: const Icon(
                                                Icons.check_circle,
                                                color:
                                                    AppColors
                                                        .contentColorGreenAccent,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            InkWell(
                                              onTap: () async {
                                                loadingDialog(
                                                  "memuat data",
                                                  '',
                                                );
                                                await requestC.cnlReqItem(
                                                  id!,
                                                  data.assetCode!,
                                                );
                                                await requestC.getDetailRequest(
                                                  id!,
                                                );
                                                Get.back();
                                                Get.back();
                                                requestC.grandTotal.value = 0;

                                                addRequest(
                                                  Get.context!,
                                                  id!,
                                                  '',
                                                  branch!,
                                                  desc!,
                                                  '',
                                                  requestC.detailRequest,
                                                );
                                              },
                                              child: const Icon(
                                                Icons.cancel,
                                                color:
                                                    AppColors.contentColorRed,
                                              ),
                                            ),
                                          ],
                                        )
                                        : Text(
                                          data.sts!.capitalize!,
                                          style: TextStyle(
                                            color:
                                                data.sts == "accepted"
                                                    ? AppColors
                                                        .contentColorGreenAccent
                                                    : AppColors.contentColorRed,
                                          ),
                                        ),
                              ),
                            )
                            : DataCell(Container()),
                      ],
                    );
                  }).toList(),
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Total: ${CurrencyFormat.convertToIdr(requestC.grandTotal.value, 0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
