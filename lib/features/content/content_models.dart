String scalarText(Object? value) =>
    value is String || value is num ? value.toString().trim() : '';
Uri? contentUrl(Object? value, Uri baseUrl) {
  final raw = scalarText(value);
  if (raw.isEmpty) return null;
  final parsed = Uri.tryParse(raw);
  if (parsed == null) return null;
  final uri = baseUrl.resolveUri(parsed);
  return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty
      ? uri
      : null;
}

class TripPackage {
  const TripPackage({
    this.id = 0,
    required this.title,
    required this.price,
    this.imageUrl,
  });
  final int id;
  final String title, price;
  final Uri? imageUrl;
  factory TripPackage.fromJson(Map<String, dynamic> json, Uri base) =>
      TripPackage(
        id: int.tryParse(scalarText(json['id'])) ?? 0,
        title: scalarText(json['title']),
        price: scalarText(json['price']),
        imageUrl: contentUrl(json['image'], base),
      );
  bool get hasContent =>
      title.isNotEmpty || price.isNotEmpty || imageUrl != null;
  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'image': imageUrl?.toString(),
  };
}

class ServiceItem {
  const ServiceItem({
    required this.title,
    required this.description,
    this.imageUrl,
  });
  final String title, description;
  final Uri? imageUrl;
  factory ServiceItem.fromJson(Map<String, dynamic> json, Uri base) =>
      ServiceItem(
        title: scalarText(json['title']),
        description: scalarText(json['desc']),
        imageUrl: contentUrl(json['image'], base),
      );
  bool get hasContent =>
      title.isNotEmpty || description.isNotEmpty || imageUrl != null;
  Map<String, Object?> toJson() => {
    'title': title,
    'desc': description,
    'image': imageUrl?.toString(),
  };
}

class WebsiteContent {
  WebsiteContent({
    List<TripPackage> packages = const [],
    List<ServiceItem> services = const [],
  }) : packages = List.unmodifiable(packages),
       services = List.unmodifiable(services);
  final List<TripPackage> packages;
  final List<ServiceItem> services;
  factory WebsiteContent.fromJson(Map<String, dynamic> json, Uri base) {
    if (json['packages'] is! List || json['services'] is! List) {
      throw const FormatException('Invalid content lists');
    }
    return WebsiteContent(
      packages: (json['packages'] as List)
          .map(
            (value) =>
                TripPackage.fromJson(value as Map<String, dynamic>, base),
          )
          .where((value) => value.hasContent)
          .toList(),
      services: (json['services'] as List)
          .map(
            (value) =>
                ServiceItem.fromJson(value as Map<String, dynamic>, base),
          )
          .where((value) => value.hasContent)
          .toList(),
    );
  }
  Map<String, Object?> toJson() => {
    'packages': packages.map((p) => p.toJson()).toList(),
    'services': services.map((s) => s.toJson()).toList(),
  };
}
