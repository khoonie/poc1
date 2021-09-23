import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.pink, width: 2.0),
  ),
);

class Constants {
  static const String leasing_Freehold = "Freehold";
  static const String leasing_999 = "999-year Leasehold";
  static const String leasing_99 = "99-year Leasehold";
  static const String leasing_other = "Other";

  static const String proptype_dh = "Detached House";
  static const String proptype_condo = "Condominium";
  static const String proptype_th = "Terranced House";
  static const String proptype_bh = "Bungalow House";
  static const String proptype_sdh = "Semi-Detached House";
  static const String proptype_exec_condo = "Executive Condominium";
  static const String proptype_hdb = "HDB Flat";
  static const String proptype_apt = "Apartment";
}
