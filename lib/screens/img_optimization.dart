import 'package:flutter/material.dart';
import 'package:opencv/opencv.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:exif/exif.dart';
import 'package:image/image.dart' as im;

/// A helper class to provide support for Photo optimizations.
///
/// All methods provided are static (stateless) and available as follows:
/// * getPhotoFileMeta - returning the exif metadata on the provided image / photo file.
/// * getPhotoFileMetaInString - returning the exif metadata in String format.
/// * optimizeByResize - optimization based on resizing the given photo by a certain dimension value.
class PhotoOptimizerForOCR {

  /// The exif metadata key representing a photo's length (corresponding to width of an [ui.Image])
  static const exifTagImageLength = "EXIF ExifImageLength";
  /// The exif metadata key representing a photo's width (corresponding to height of an [ui.Image])
  static const exifTagImageWidth  = "EXIF ExifImageWidth";

  /// Returns the raw Map of exif metadata on the [path].
  ///
  /// __PS__. Not every photo would have exif metadata; hence it is normal to return an empty [Map].
  static Future<Map<String, IfdTag>> getPhotoFileMeta(String path) async {
    Future<Map<String, IfdTag>> _meta = readExifFromBytes(File(path).readAsBytesSync());
    return _meta;
  }

  /// Returns the String description of the exif metadata on [path].
  ///
  /// __PS__. Not every photo would have exif metadata;
  /// hence if no metadata available a message "oops, no exif data available for this photo!!!" would be returned
  static Future<String> getPhotoFileMetaInString(String path) async {
    Map<String, IfdTag> _meta = await readExifFromBytes(File(path).readAsBytesSync());
    StringBuffer _s = StringBuffer();

    if (_meta == null || _meta.isEmpty) {
      _s.writeln("oops, no exif data available for this photo!!!");
      return _s.toString();
    }
    // Iterate all keys and its value.
    _meta.keys.forEach((_k) {
      _s.writeln("[$_k]: (${_meta[_k].tagType} - ${_meta[_k]})");
    });
    return _s.toString();
  }

  /// Optimizes the photo at [path] by a constraint of [maxWidthOrLength].
  ///
  /// Resize logic is based on comparing the width and height of the image on [path] with the [maxWidthOrLength];
  /// if either dimension is larger than [maxWidthOrLength], a corresponding resizing would be implemented.
  /// Aspect ratio would be maintained to prevent image distortion. Finally the resized image would replace the original one.
  static Future<bool> optimizeByResize(String path, {int maxWidthOrLength = 1500}) async {
    int _w = 0;
    int _h = 0;
    dynamic res;
    File file = File(path);
    Map<String, IfdTag> _meta = await PhotoOptimizerForOCR.getPhotoFileMeta(path);

    // Note that not every photo might have exif information~~~
    if (_meta == null || _meta.isEmpty ||
        _meta[PhotoOptimizerForOCR.exifTagImageWidth] == null ||
        _meta[PhotoOptimizerForOCR.exifTagImageLength] == null)
    {
      // Use the old fashion ImageProvider to resolve the photo's dimensions.
      Completer _completer = Completer();
      FileImage(File(path)).
      resolve(ImageConfiguration()).
      addListener(ImageStreamListener((imgInfo, _) {
        _completer.complete(imgInfo.image);
      }));
      var _img = await _completer.future as ui.Image;
      _w = _img.height;
      _h = _img.width;

    } else {
      _w = _meta[PhotoOptimizerForOCR.exifTagImageWidth].values as int;
      _h = _meta[PhotoOptimizerForOCR.exifTagImageLength].values as int;
    }

    double _factor = 1.0;
    // Update the resized w and h after resizing.
    if (_w >= _h) {
      _factor = maxWidthOrLength / _w;
      _w = (_w * _factor).round();
      _h = (_h * _factor).round();
    } else {
      _factor = maxWidthOrLength / _h;
      _w = (_w * _factor).round();
      _h = (_h * _factor).round();
    }

    // [DOC] note the exif width = height of the image !! whilst exif length = width of the image !!
    im.Image _resizedImage = im.copyResize(
        im.decodeImage(File(path).readAsBytesSync()),
        width: _h,
        height: _w);

    // Overwrite existing file with the resized one.
    File(path)..writeAsBytesSync(im.encodeJpg(_resizedImage));

    res = await ImgProc.threshold(
        await file.readAsBytes(), 80, 255, ImgProc.threshBinary);
    im.Image _img = im.decodeImage(res);
    File(file.path)..writeAsBytesSync(im.encodeJpg(_img));


    return true;
  }

}