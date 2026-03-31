class AdModel {
  final String adId;
  final String title;
  final String imageUrl;
  final String redirectUrl;
  final String advertiserName;
  final String description;
  final int displayOrder;

  AdModel({
    required this.adId,
    required this.title,
    required this.imageUrl,
    required this.redirectUrl,
    required this.advertiserName,
    required this.description,
    required this.displayOrder,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      adId: json['adId'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      redirectUrl: json['redirectUrl'] ?? '',
      advertiserName: json['advertiserName'] ?? '',
      description: json['description'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}