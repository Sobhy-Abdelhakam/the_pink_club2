class ProviderAd {
  final int id;
  final String name;
  final String nameEn;
  final String shortDesc;
  final String shortDescEn;
  final String details;
  final String detailsEn;
  final String image;

  ProviderAd({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.shortDesc,
    required this.shortDescEn,
    required this.details,
    required this.detailsEn,
    required this.image,
  });

  factory ProviderAd.fromJson(Map<String, dynamic> json) {
    return ProviderAd(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      shortDesc: json['short_desc'] as String? ?? '',
      shortDescEn: json['short_desc_en'] as String? ?? '',
      details: json['details'] as String? ?? '',
      detailsEn: json['details_en'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  String getImageUrl() {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return 'https://thepinkclub.net$image';
  }

  String getName(String locale) {
    return locale == 'ar' ? name : nameEn;
  }

  String getShortDesc(String locale) {
    return locale == 'ar' ? shortDesc : shortDescEn;
  }

  String getDetails(String locale) {
    return locale == 'ar' ? details : detailsEn;
  }
}

