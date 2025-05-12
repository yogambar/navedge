class Place {
  final String? formattedAddress;

  Place({this.formattedAddress});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      formattedAddress: json['formatted_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatted_address': formattedAddress,
    };
  }
}
