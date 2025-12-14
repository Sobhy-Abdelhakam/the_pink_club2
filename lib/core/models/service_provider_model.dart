class ServiceProvider {
  final String governorate;
  final String type;
  final String name;
  final String address;
  final String phone;
  final String discount;

  ServiceProvider({
    required this.governorate,
    required this.type,
    required this.name,
    required this.address,
    required this.phone,
    required this.discount,
  });

  // تحويل قائمة إلى كائن ServiceProvider (للتوافق مع البيانات القديمة)
  factory ServiceProvider.fromRawList(List<dynamic> row) {
    return ServiceProvider(
      governorate: row.isNotEmpty && row.length > 0 ? row[0] ?? '' : '',
      type: row.isNotEmpty && row.length > 1 ? row[1] ?? '' : '',
      name: row.isNotEmpty && row.length > 2 ? row[2] ?? '' : '',
      address: row.isNotEmpty && row.length > 3 ? row[3] ?? '' : '',
      phone: row.isNotEmpty && row.length > 4 ? row[4] ?? '' : '',
      discount: row.isNotEmpty && row.length > 5 ? row[5] ?? '' : '',
    );
  }

  // تحويل بيانات API الجديدة إلى كائن ServiceProvider
  factory ServiceProvider.fromApiData(Map<String, dynamic> data) {
    return ServiceProvider(
      governorate: data['city'] ?? data['district'] ?? '',
      type: data['type'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      discount: data['discount_pct'] ?? '',
    );
  }
}
