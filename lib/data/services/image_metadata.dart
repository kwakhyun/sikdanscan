import 'dart:typed_data';

/// Removes GPS location data from a JPEG's EXIF block.
///
/// Image pickers copy the camera's EXIF (including the location) into the
/// resized file, and meal photos are uploaded to cloud storage and sent for
/// recognition. The rest of the EXIF data is kept, notably the orientation,
/// so photos still display upright. The GPS directory is emptied in place,
/// so no offsets in the file change.
///
/// Returns [bytes] unchanged when it is not a JPEG, has no GPS data or
/// cannot be parsed.
Uint8List stripJpegGps(Uint8List bytes) {
  if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) return bytes;
  try {
    final out = Uint8List.fromList(bytes);
    var offset = 2;
    var changed = false;
    while (offset + 4 <= out.length && out[offset] == 0xFF) {
      final marker = out[offset + 1];
      // Start of scan / end of image: no metadata segments follow.
      if (marker == 0xDA || marker == 0xD9) break;
      final length = (out[offset + 2] << 8) | out[offset + 3];
      if (length < 2 || offset + 2 + length > out.length) break;
      final start = offset + 4;
      if (marker == 0xE1 && _isExifHeader(out, start)) {
        changed =
            _emptyGpsDirectory(out, start + 6, offset + 2 + length) || changed;
      }
      offset += 2 + length;
    }
    return changed ? out : bytes;
  } catch (_) {
    return bytes;
  }
}

bool _isExifHeader(Uint8List data, int start) {
  const header = [0x45, 0x78, 0x69, 0x66, 0x00, 0x00]; // "Exif\0\0"
  if (start + header.length > data.length) return false;
  for (var i = 0; i < header.length; i++) {
    if (data[start + i] != header[i]) return false;
  }
  return true;
}

/// [tiff] is the start of the TIFF header, [end] the end of the segment.
bool _emptyGpsDirectory(Uint8List data, int tiff, int end) {
  if (tiff + 8 > end) return false;
  final view = ByteData.sublistView(data);
  final Endian endian;
  if (data[tiff] == 0x49 && data[tiff + 1] == 0x49) {
    endian = Endian.little;
  } else if (data[tiff] == 0x4D && data[tiff + 1] == 0x4D) {
    endian = Endian.big;
  } else {
    return false;
  }

  final ifd0 = tiff + view.getUint32(tiff + 4, endian);
  if (ifd0 + 2 > end) return false;
  final entries = view.getUint16(ifd0, endian);
  int? gpsDirectory;
  for (var i = 0; i < entries; i++) {
    final entry = ifd0 + 2 + i * 12;
    if (entry + 12 > end) return false;
    if (view.getUint16(entry, endian) == 0x8825) {
      gpsDirectory = tiff + view.getUint32(entry + 8, endian);
      break;
    }
  }
  if (gpsDirectory == null || gpsDirectory + 2 > end) return false;

  final gpsEntries = view.getUint16(gpsDirectory, endian);
  for (var i = 0; i < gpsEntries; i++) {
    final entry = gpsDirectory + 2 + i * 12;
    if (entry + 12 > end) break;
    final size =
        _typeSize(view.getUint16(entry + 2, endian)) *
        view.getUint32(entry + 4, endian);
    if (size > 4) {
      // Values that do not fit in the entry live elsewhere in the block.
      final valueStart = tiff + view.getUint32(entry + 8, endian);
      final valueEnd = valueStart + size;
      if (valueStart >= tiff && valueEnd <= end) {
        data.fillRange(valueStart, valueEnd, 0);
      }
    }
    data.fillRange(entry, entry + 12, 0);
  }
  // An empty directory: zero entries, no next directory.
  view.setUint16(gpsDirectory, 0, endian);
  final next = gpsDirectory + 2;
  if (next + 4 <= end) data.fillRange(next, next + 4, 0);
  return gpsEntries > 0;
}

int _typeSize(int type) {
  return switch (type) {
    1 || 2 || 6 || 7 => 1, // BYTE, ASCII, SBYTE, UNDEFINED
    3 || 8 => 2, // SHORT, SSHORT
    4 || 9 || 11 => 4, // LONG, SLONG, FLOAT
    5 || 10 || 12 => 8, // RATIONAL, SRATIONAL, DOUBLE
    _ => 1,
  };
}
