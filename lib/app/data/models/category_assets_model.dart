class CategoryAssets {
  late String? id;
  late String? catName;
  late String? desc;
  late String? assetsGroup;
  late String? total;

  CategoryAssets({
    this.id,
    this.catName,
    this.desc,
    this.assetsGroup,
    this.total,
  });

  CategoryAssets.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    catName = json['category_name'];
    desc = json['description'];
    assetsGroup = json['group'];
    total = json['total'];
  }
}
