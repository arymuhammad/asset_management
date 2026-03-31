import 'package:assets_management/app/modules/barang_masuk/views/widget/add_edit_stok_in.dart';
import 'package:assets_management/app/modules/stok/views/widget/data_table_stock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/stock_detail_model.dart';

detailStock({
  required BuildContext context,
  required String type,
  required String itemCode,
  required String itemName,
  required String cabang,
}) async {
  showDialog(
    context: context,
    builder:
        (context) => LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth >= 800;
            return AlertDialog(
              insetPadding: const EdgeInsets.all(8.0),
              title: Text('Detail Stock $type'),
              content: Container(
                width:
                    MediaQuery.of(context).size.width /
                    (isWideScreen ? 1.3 : 1.6),
                height: MediaQuery.of(context).size.height / 1.3,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    FutureBuilder(
                      future:
                          type == 'SUMMARY'
                              ? Future.wait<List<StockDetail>>([
                                stokC.getDetailStock(
                                  'stock_in',
                                  cabang,
                                  itemCode,
                                ),
                                stokC.getDetailStock(
                                  'stock_out',
                                  cabang,
                                  itemCode,
                                ),
                                stokC.getDetailStock(
                                  'adj_in',
                                  cabang,
                                  itemCode,
                                ),
                                stokC.getDetailStock(
                                  'adj_out',
                                  cabang,
                                  itemCode,
                                ),
                              ])
                              : stokC.getDetailStock(
                                type == 'ADJ IN'
                                    ? 'adj_in'
                                    : type == 'ADJ OUT'
                                    ? 'adj_out'
                                    : type == 'IN'
                                    ? 'stock_in'
                                    : 'stock_out',
                                cabang,
                                itemCode,
                              ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<StockDetail> combinedData = [];
                          if (type == 'SUMMARY') {
                            // Ambil hasil dari Future.wait (List<List<StockDetail>>)
                            final results =
                                snapshot.data as List<List<StockDetail>>;
                            // Gabungkan hasil IN dan OUT tanpa duplikat
                            final inList = results[0];
                            final outList = results[1];
                            final adjInList = results[2];
                            final adjOutList = results[3];

                            combinedData = [
                              ...inList,
                              ...outList,
                              ...adjInList,
                              ...adjOutList,
                            ];
                            final totalIn = [...inList, ...adjInList].fold<int>(
                              0,
                              (prev, item) =>
                                  prev + (int.tryParse(item.qty ?? '0') ?? 0),
                            );

                            final totalOut = [
                              ...outList,
                              ...adjOutList,
                            ].fold<int>(
                              0,
                              (prev, item) =>
                                  prev + (int.tryParse(item.qty ?? '0') ?? 0),
                            );

                            stokC.grandTotal.value = totalIn - totalOut;
                          } else {
                            combinedData = snapshot.data as List<StockDetail>;
                            stokC.grandTotal.value = combinedData.fold(
                              0,
                              (prev, item) =>
                                  prev + ((int.tryParse(item.qty ?? '0') ?? 0)),
                            );
                          }
                          stokC.dataDetailStok.value = combinedData;
                          stokC.dataDetailStok.sort(
                            (a, b) => a.createdAt!.compareTo(b.createdAt!),
                          );
                          // Assign hanya ke detailDataFiltered untuk tampilan modal
                          return SizedBox(
                            height: 480,
                            child: DataTabelStock(
                              status: type,
                              itemName: itemName,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        }
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
  );
}
