import 'package:cloud_firestore/cloud_firestore.dart';

class Home {
  String id = '';
  String address = '';
  String ID = '';
  String latitude = '';
  String leasing = '';
  String longitude = '';
  String baths = '';
  String bedrs = '';
  String hawks = '';
  String malls = '';
  String parks = '';
  String presch = '';
  String school = '';
  String station = '';
  String supermark = '';
  String plotRatio = '';
  String price = '';
  String propname = '';
  String proptype = '';
  String rental = '';
  String size = '';
  String subDist = '';
  String yearbuilt = '';
  DocumentReference reference;

  Home(
      this.id,
      this.address,
      this.ID,
      this.latitude,
      this.longitude,
      this.leasing,
      this.baths,
      this.bedrs,
      this.hawks,
      this.malls,
      this.parks,
      this.presch,
      this.school,
      this.station,
      this.supermark,
      this.plotRatio,
      this.price,
      this.propname,
      this.proptype,
      this.rental,
      this.size,
      this.subDist,
      this.yearbuilt,
      this.reference);

  factory Home.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Home newHome = Home.fromJson(snapshot.data()!);
    newHome.reference = snapshot.reference;
    return newHome;
  }

  factory Home.fromJson(Map<String, dynamic> json) => _HomeFromJson(json);

  Map<String, dynamic> toJson() => _HomeToJson(this);
  @override
  String toString() => "Home<$address>";
}

Home _HomeFromJson(Map<String, dynamic> json) {
  return Home(
      json['id'] as String,
      json['address'] as String,
      json['ID'] as String,
      json['latitude'] as String,
      json['longitutde'] as String,
      json['leasing'] as String,
      json['noOfBathrooms'] as String,
      json['noOfBedrooms'] as String,
      json['noOfHawkers'] as String,
      json['noOfMalls'] as String,
      json['noOfParks'] as String,
      json['noOfPreschools'] as String,
      json['noOfSchools'] as String,
      json['noOfStations'] as String,
      json['noOfSupermarkets'] as String,
      json['plotRatio'] as String,
      json['price'] as String,
      json['propertiesName'] as String,
      json['propertyType'] as String,
      json['rental'] as String,
      json['size'] as String,
      json['subdistrict'] as String,
      json['yearOfBuilt'] as String,
      json['reference'] as DocumentReference);
}

Map<String, dynamic> _HomeToJson(Home instance) => <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'ID': instance.ID,
      'latitude': instance.latitude,
      'longitutde': instance.longitude,
      'leasing': instance.leasing,
      'baths': instance.baths,
      'bedrs': instance.bedrs,
      'hawks': instance.hawks,
      'malls': instance.malls,
      'parks': instance.parks,
      'presch': instance.presch,
      'school': instance.school,
      'station': instance.station,
      'supermark': instance.supermark,
      'plotRatio': instance.plotRatio,
      'price': instance.price,
      'propname': instance.propname,
      'proptype': instance.proptype,
      'rental': instance.rental,
      'size': instance.size,
      'subDist': instance.subDist,
      'yearbuilt': instance.yearbuilt,
      'reference': instance.reference
    };
