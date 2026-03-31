import 'package:assets_management/app/data/models/detail_adj_model.dart';

import 'stock_detail_model.dart';
import 'stok_model.dart';

class DetailSummModel {
  final List<StockDetail>? stockDetail;
  final List<DetailAdjModel>? adjDetail;
  final List<Stok>? stock;

  DetailSummModel({this.stockDetail, this.adjDetail, this.stock});
}
