import 'package:assets_management/app/data/models/detail_adj_model.dart';

import 'detail_barang_masuk_keluar_model.dart';

class StockResponse {
  final List<DetailBarangMasukKeluar> detailBarangMasukKeluar;
  final List<DetailAdjModel> detailAdj;

  StockResponse({
    required this.detailBarangMasukKeluar,
    required this.detailAdj,
  });
}