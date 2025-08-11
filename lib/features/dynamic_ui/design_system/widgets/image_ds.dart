import 'package:flutter/material.dart';
import '../base_ds.dart';
import '../ds_helpers.dart';

class ImageDS extends BaseDS<Image> {
  ImageDS({required this.url, this.width, this.height, this.fit});
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  String get type => 'image';

  @override
  Image build() => Image.network(url, width: width, height: height, fit: fit);

  factory ImageDS.fromJson(Map<String, dynamic> json) => ImageDS(
        url: (json['url'] ?? '').toString(),
        width: (json['width'] as num?)?.toDouble(),
        height: (json['height'] as num?)?.toDouble(),
        fit: stringToBoxFit(json['fit']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'url': url,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (fit != null) 'fit': boxFitToString(fit!),
      };
}

