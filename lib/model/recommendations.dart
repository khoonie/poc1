class Recommendations {
  String user_id = '';
  String address = '';
  String property_id = '';
  String latitude = '';
  String longitude = '';
  String leasing = '';
  String no_of_bathrooms = '';
  String no_of_bedrooms = '';
  String no_of_hawkers = '';
  String no_of_malls = '';
  String no_of_parks = '';
  String no_of_preschools = '';
  String no_of_schools = '';
  String no_of_stations = '';
  String no_of_supermarkets = '';
  String plotRatio = '';
  String price = '';
  String properties_name = '';
  String property_type = '';
  String rental = '';
  String size = '';
  String subdistrict = '';
  String year_of_built = '';

  Recommendations(
      this.user_id,
      this.address,
      this.property_id,
      this.latitude,
      this.leasing,
      this.longitude,
      this.no_of_bathrooms,
      this.no_of_bedrooms,
      this.no_of_hawkers,
      this.no_of_malls,
      this.no_of_parks,
      this.no_of_preschools,
      this.no_of_schools,
      this.no_of_stations,
      this.no_of_supermarkets,
      this.plotRatio,
      this.price,
      this.properties_name,
      this.property_type,
      this.rental,
      this.size,
      this.subdistrict,
      this.year_of_built);

  factory Recommendations.fromJson(Map<String, dynamic> json) =>
      _RecommendationsFromJson(json);

  Map<String, dynamic> toJson() => _RecommendationsToJson(this);
  @override
  String toString() => "Home<$address>";
}

Map<String, dynamic> _RecommendationsToJson(Recommendations instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'address': instance.address,
      'property_id': instance.property_id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'leasing': instance.leasing,
      'no_of_baths': instance.no_of_bathrooms,
      'no_of_bedrooms': instance.no_of_bedrooms,
      'no_of_hawkers': instance.no_of_hawkers,
      'no_of_malls': instance.no_of_malls,
      'no_of_parks': instance.no_of_parks,
      'no_of_preschools': instance.no_of_preschools,
      'no_of_schools': instance.no_of_schools,
      'no_of_stations': instance.no_of_stations,
      'no_of_supermarkets': instance.no_of_supermarkets,
      'plotRatio': instance.plotRatio,
      'price': instance.price,
      'properties_name': instance.properties_name,
      'property_type': instance.property_type,
      'rental': instance.rental,
      'size': instance.size,
      'subdistrict': instance.subdistrict,
      'year_of_built': instance.year_of_built
    };

Recommendations _RecommendationsFromJson(Map<String, dynamic> json) {
  return Recommendations(
      (json['user_id'] ?? "") as String,
      (json['address'] ?? "") as String,
      (json['property_id'] ?? "").toString() as String,
      (json['latitude'] ?? "").toString() as String,
      (json['leasing'] ?? "") as String,
      (json['longitude'] ?? "").toString() as String,
      (json['no_of_bathrooms'] ?? "").toString() as String,
      (json['no_of_bedrooms'] ?? "").toString() as String,
      (json['no_of_hawkers'] ?? "").toString() as String,
      (json['no_of_malls'] ?? "").toString() as String,
      (json['no_of_parks'] ?? "").toString() as String,
      (json['no_of_preschools'] ?? "").toString() as String,
      (json['no_of_schools'] ?? "").toString() as String,
      (json['no_of_stations'] ?? "").toString() as String,
      (json['no_of_supermarkets'] ?? "").toString() as String,
      (json['plot ratio'] ?? "").toString() as String,
      (json['price'] ?? "").toString() as String,
      (json['properties_name'] ?? "") as String,
      (json['property_type'] ?? "") as String,
      (json['rental'] ?? "").toString() as String,
      (json['size'] ?? "").toString() as String,
      (json['subdistrict'] ?? "") as String,
      (json['year_of_built'] ?? "").toString() as String);
}
