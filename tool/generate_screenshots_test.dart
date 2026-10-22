// Regenerates the images of the README and of the pub.dev gallery in
// doc/images, by rendering the real widgets of the package.
//
// Run it from the package root:
//
//     flutter test tool/generate_screenshots_test.dart
//
// It is a test only so that it can render widgets without a device; it lives
// in tool/ (not test/) because it writes files and checks nothing. The text
// uses the Roboto font bundled with the Flutter SDK, so the images show the
// Android/Material look of the text, not the iOS system font.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _outDir = 'doc/images';

/// Logical width of the simulated phone.
const _phoneWidth = 390.0;

const _lightBackground = Color(0xFFF2F2F7);
const _darkBackground = Color(0xFF000000);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadRoboto();
    Directory(_outDir).createSync(recursive: true);
  });

  testWidgets('date picker', (t) async {
    await _shot(
        t,
        'date_picker',
        AwesomeDatePicker(
          dateFormat: AwesomeDateFormat.dMMy,
          minDate: const AwesomeDate(year: 2020, month: 1, day: 1),
          maxDate: const AwesomeDate(year: 2030, month: 12, day: 31),
          initialDate: const AwesomeDate(year: 2025, month: 3, day: 14),
        ));
  });

  testWidgets('time picker', (t) async {
    await _shot(
        t,
        'time_picker',
        AwesomeTimePicker(
          timeFormat: AwesomeTimeFormat.hm,
          minuteInterval: 5,
          initialTime: const AwesomeTime(hour: 9, minute: 30),
        ));
  });

  testWidgets('time picker with seconds', (t) async {
    await _shot(
        t,
        'time_picker_seconds',
        AwesomeTimePicker(
          timeFormat: AwesomeTimeFormat.Hms,
          initialTime: const AwesomeTime(hour: 14, minute: 5, second: 37),
        ));
  });

  testWidgets('date-time picker', (t) async {
    await _shot(t, 'datetime_picker', _dateTimePicker());
  });

  testWidgets('date range picker', (t) async {
    await _shot(
      t,
      'date_range_picker',
      AwesomeDateRangePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        minDate: const AwesomeDate(year: 2025, month: 1, day: 1),
        maxDate: const AwesomeDate(year: 2025, month: 12, day: 31),
        minLength: 1,
        maxLength: 14,
        initialRange: const AwesomeDateRange(
          start: AwesomeDate(year: 2025, month: 6, day: 10),
          end: AwesomeDate(year: 2025, month: 6, day: 17),
        ),
        startLabel: const _Label('Check-in'),
        endLabel: const _Label('Check-out'),
      ),
    );
  });

  testWidgets('dark mode', (t) async {
    await _shot(t, 'dark_mode', _dateTimePicker(), dark: true);
  });

  testWidgets('excluded values shown dimmed', (t) async {
    await _shot(
      t,
      'disabled_values',
      AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        showWeekday: true,
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
        showDisabledValues: true,
        minDate: const AwesomeDate(year: 2025, month: 1, day: 1),
        maxDate: const AwesomeDate(year: 2025, month: 12, day: 31),
        initialDate: const AwesomeDate(year: 2025, month: 6, day: 13),
      ),
    );
  });

  testWidgets('wheel style', (t) async {
    await _shot(
      t,
      'wheel_style',
      AwesomeTimePicker(
        timeFormat: AwesomeTimeFormat.hm,
        initialTime: const AwesomeTime(hour: 7, minute: 45),
        backgroundColor: const Color(0xFFFFF8E7),
        selectorColor: const Color(0x33FF9500),
        selectedTextStyle: const TextStyle(
          color: Color(0xFFB45F00),
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        wheelStyle: AwesomeWheelStyle(
          diameterRatio: 2.2,
          magnification: 1.15,
          overAndUnderCenterOpacity: 0.55,
          selectorBorderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  });

  testWidgets('localization', (t) async {
    const date = AwesomeDate(year: 2025, month: 2, day: 14);
    Widget picker(String name) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _Label("localeName: '$name'"),
            AwesomeDatePicker(
              dateFormat: AwesomeDateFormat.dMMy,
              localeName: name,
              visibleItemCount: 3,
              initialDate: date,
            ),
          ]),
        );
    await _shot(
        t,
        'localization',
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [picker('fr'), picker('es'), picker('de')],
        ));
  });

  testWidgets('wheel style presets', (t) async {
    Widget preset(String name, AwesomeWheelStyle? style) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _Label(name),
            AwesomeTimePicker(
              timeFormat: AwesomeTimeFormat.hm,
              initialTime: const AwesomeTime(hour: 9, minute: 41),
              itemWidth: 48,
              wheelStyle: style,
            ),
          ]),
        );
    await _shot(
      t,
      'wheel_presets',
      Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          preset('default', null),
          preset('ios()', const AwesomeWheelStyle.ios()),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisSize: MainAxisSize.min, children: [
          preset('material()', const AwesomeWheelStyle.material()),
          preset('minimal()', const AwesomeWheelStyle.minimal()),
        ]),
      ]),
      height: 1000,
    );
  });

  testWidgets('duration pickers', (t) async {
    Widget labelled(String label, Widget picker) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_Label(label), picker],
          ),
        );
    await _shot(
      t,
      'duration_picker',
      Column(mainAxisSize: MainAxisSize.min, children: [
        labelled(
          'hm, every 5 minutes',
          AwesomeDurationPicker(
            minuteInterval: 5,
            initialDuration: const Duration(hours: 1, minutes: 30),
            theme: const AwesomeDurationPickerTheme(
              hourTheme: ItemTheme(title: Text('hours')),
              minuteTheme: ItemTheme(title: Text('min')),
            ),
          ),
        ),
        labelled(
          'ms, up to 2 hours',
          AwesomeDurationPicker(
            format: AwesomeDurationFormat.ms,
            maxDuration: const Duration(minutes: 120),
            initialDuration: const Duration(minutes: 45, seconds: 20),
            theme: const AwesomeDurationPickerTheme(
              minuteTheme: ItemTheme(title: Text('min')),
              secondTheme: ItemTheme(title: Text('sec')),
            ),
          ),
        ),
      ]),
      height: 1100,
    );
  });

  testWidgets('modal sheet', (t) async {
    _phone(t);
    final boundary = GlobalKey();
    await t.pumpWidget(RepaintBoundary(
      key: boundary,
      child: _app(
        home: Scaffold(
          appBar: AppBar(title: const Text('Booking')),
          body: const Center(child: Text('Tap to choose your dates')),
        ),
      ),
    ));
    final context = t.element(find.byType(Scaffold));
    // ignore: unawaited_futures
    showAwesomeDateRangePicker(
      context,
      title: const Text('Dates'),
      dateFormat: AwesomeDateFormat.dMMy,
      minLength: 1,
      startLabel: const _Label('Check-in'),
      endLabel: const _Label('Check-out'),
      minDate: const AwesomeDate(year: 2025, month: 1, day: 1),
      maxDate: const AwesomeDate(year: 2025, month: 12, day: 31),
      initialRange: const AwesomeDateRange(
        start: AwesomeDate(year: 2025, month: 6, day: 10),
        end: AwesomeDate(year: 2025, month: 6, day: 17),
      ),
    );
    await t.pumpAndSettle();
    await _savePng(t, boundary, 'modal_sheet', pixelRatio: 2);
  });

  testWidgets('demo animation', (t) async {
    _phone(t);
    final boundary = GlobalKey();
    await t.pumpWidget(_app(
      home: Scaffold(
        backgroundColor: _lightBackground,
        body: Center(
          child: RepaintBoundary(
            key: boundary,
            child: ColoredBox(
              color: _lightBackground,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _dateTimePicker(),
              ),
            ),
          ),
        ),
      ),
    ));
    await t.pumpAndSettle();

    final frames = <_Frame>[];
    Future<void> grab() async => frames.add(await _grab(t, boundary, 1.5));

    // wheels: day, month, year, hour, minute
    final wheels = find.byType(ListWheelScrollView);
    Future<void> drag(int wheel, double step, int steps) async {
      final gesture = await t.startGesture(t.getCenter(wheels.at(wheel)));
      for (var i = 0; i < steps; i++) {
        await gesture.moveBy(Offset(0, step));
        await t.pump(const Duration(milliseconds: 16));
        if (i.isEven) await grab();
      }
      await gesture.up();
      for (var i = 0; i < 40; i++) {
        await t.pump(const Duration(milliseconds: 16));
        if (i.isEven) await grab();
      }
    }

    await grab();
    final firstHold = frames.length;
    await drag(0, -13, 9); // day forward
    await drag(1, -14, 8); // month forward
    await drag(4, 13, 10); // minute backward
    await drag(3, -13, 6); // hour forward
    await grab();

    final delays = List<int>.filled(frames.length, 4);
    delays[0] = 90; // hold the first image
    delays[frames.length - 1] = 150; // and the last one
    assert(firstHold >= 1);
    File('$_outDir/demo.gif')
        .writeAsBytesSync(_encodeGif(frames, delays: delays));
  });
}

// ===== Pickers shown in several images =====

Widget _dateTimePicker() => const AwesomeDateTimePicker(
      dateFormat: AwesomeDateFormat.dMy,
      timeFormat: AwesomeTimeFormat.Hm,
      minDateTime: AwesomeDateTime(
        date: AwesomeDate(year: 2020, month: 1, day: 1),
        time: AwesomeTime(hour: 0, minute: 0),
      ),
      maxDateTime: AwesomeDateTime(
        date: AwesomeDate(year: 2030, month: 12, day: 31),
        time: AwesomeTime(hour: 23, minute: 59),
      ),
      initialDateTime: AwesomeDateTime(
        date: AwesomeDate(year: 2025, month: 3, day: 14),
        time: AwesomeTime(hour: 10, minute: 25),
      ),
    );

/// A small caption above a picker.
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
          ),
        ),
      );
}

// ===== Rendering helpers =====

void _phone(WidgetTester t, {double height = 844}) {
  t.view.physicalSize = Size(_phoneWidth * 3, height * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

Widget _app({required Widget home, bool dark = false}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: home,
    );

/// Renders [picker] on a phone-wide background and saves it as [name].png.
Future<void> _shot(
  WidgetTester t,
  String name,
  Widget picker, {
  bool dark = false,
  double height = 844,
}) async {
  _phone(t, height: height);
  final boundary = GlobalKey();
  final background = dark ? _darkBackground : _lightBackground;
  await t.pumpWidget(_app(
    dark: dark,
    home: Scaffold(
      backgroundColor: background,
      body: Center(
        child: RepaintBoundary(
          key: boundary,
          child: ColoredBox(
            color: background,
            child: Padding(padding: const EdgeInsets.all(24), child: picker),
          ),
        ),
      ),
    ),
  ));
  await t.pumpAndSettle();
  await _savePng(t, boundary, name);
}

Future<void> _savePng(
  WidgetTester t,
  GlobalKey boundary,
  String name, {
  double pixelRatio = 3,
}) async {
  final render =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await t.runAsync(() async {
    final image = await render.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_outDir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

Future<void> _loadRoboto() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    throw StateError('FLUTTER_ROOT is not set: run this with `flutter test`.');
  }
  final loader = FontLoader('Roboto');
  for (final file in ['Light', 'Regular', 'Medium', 'Bold']) {
    final path = '$root/bin/cache/artifacts/material_fonts/Roboto-$file.ttf';
    loader.addFont(Future.value(
      ByteData.sublistView(File(path).readAsBytesSync()),
    ));
  }
  await loader.load();
}

// ===== Animated GIF =====

class _Frame {
  _Frame(this.width, this.height, this.rgba);

  final int width;
  final int height;
  final Uint8List rgba;
}

Future<_Frame> _grab(
    WidgetTester t, GlobalKey boundary, double pixelRatio) async {
  final render =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await t.runAsync(() async {
    final image = await render.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return _Frame(image.width, image.height, data!.buffer.asUint8List());
  }))!;
}

/// A fixed 256-color palette: a 6x6x6 color cube plus 40 extra greys, which
/// is plenty for flat UI with anti-aliased grey text.
List<int> _palette() {
  final colors = <int>[];
  for (var r = 0; r < 6; r++) {
    for (var g = 0; g < 6; g++) {
      for (var b = 0; b < 6; b++) {
        colors.add((r * 51 << 16) | (g * 51 << 8) | (b * 51));
      }
    }
  }
  for (var i = 0; i < 40; i++) {
    final v = (i * 255 / 39).round();
    colors.add((v << 16) | (v << 8) | v);
  }
  return colors;
}

/// Index of the nearest palette color for each 5-bit RGB value.
Uint8List _paletteLookup(List<int> palette) {
  final lookup = Uint8List(32 * 32 * 32);
  for (var r = 0; r < 32; r++) {
    for (var g = 0; g < 32; g++) {
      for (var b = 0; b < 32; b++) {
        final rr = (r << 3) | (r >> 2);
        final gg = (g << 3) | (g >> 2);
        final bb = (b << 3) | (b >> 2);
        var best = 0;
        var bestDistance = 1 << 30;
        for (var i = 0; i < palette.length; i++) {
          final dr = ((palette[i] >> 16) & 255) - rr;
          final dg = ((palette[i] >> 8) & 255) - gg;
          final db = (palette[i] & 255) - bb;
          final d = dr * dr + dg * dg + db * db;
          if (d < bestDistance) {
            bestDistance = d;
            best = i;
          }
        }
        lookup[(r << 10) | (g << 5) | b] = best;
      }
    }
  }
  return lookup;
}

Uint8List _encodeGif(List<_Frame> frames, {required List<int> delays}) {
  final palette = _palette();
  final lookup = _paletteLookup(palette);
  final out = BytesBuilder();
  void u16(int v) => out
    ..addByte(v & 255)
    ..addByte((v >> 8) & 255);

  final width = frames.first.width;
  final height = frames.first.height;
  out.add('GIF89a'.codeUnits);
  u16(width);
  u16(height);
  out
    ..addByte(0xF7) // global color table, 8 bits per color, 256 entries
    ..addByte(0)
    ..addByte(0);
  for (final c in palette) {
    out
      ..addByte((c >> 16) & 255)
      ..addByte((c >> 8) & 255)
      ..addByte(c & 255);
  }
  // loop forever
  out
    ..add([0x21, 0xFF, 0x0B])
    ..add('NETSCAPE2.0'.codeUnits)
    ..add([0x03, 0x01, 0x00, 0x00, 0x00]);

  for (var f = 0; f < frames.length; f++) {
    final frame = frames[f];
    out
      ..add([0x21, 0xF9, 0x04, 0x04]) // graphic control: do not dispose
      ..addByte(delays[f] & 255)
      ..addByte((delays[f] >> 8) & 255)
      ..add([0x00, 0x00]);
    out.addByte(0x2C);
    u16(0);
    u16(0);
    u16(width);
    u16(height);
    out.addByte(0);

    final indices = Uint8List(width * height);
    for (var i = 0; i < indices.length; i++) {
      final r = frame.rgba[i * 4] >> 3;
      final g = frame.rgba[i * 4 + 1] >> 3;
      final b = frame.rgba[i * 4 + 2] >> 3;
      indices[i] = lookup[(r << 10) | (g << 5) | b];
    }
    out.addByte(8); // minimum LZW code size
    final data = _lzw(indices, 8);
    for (var offset = 0; offset < data.length; offset += 255) {
      final length = math.min(255, data.length - offset);
      out.addByte(length);
      out.add(data.sublist(offset, offset + length));
    }
    out.addByte(0);
  }
  out.addByte(0x3B);
  return out.toBytes();
}

/// GIF flavor of LZW compression.
Uint8List _lzw(Uint8List indices, int minCodeSize) {
  final clear = 1 << minCodeSize;
  final end = clear + 1;
  final out = BytesBuilder();
  var buffer = 0;
  var bits = 0;
  void write(int code, int size) {
    buffer |= code << bits;
    bits += size;
    while (bits >= 8) {
      out.addByte(buffer & 255);
      buffer >>= 8;
      bits -= 8;
    }
  }

  var codeSize = minCodeSize + 1;
  var next = end + 1;
  var dictionary = <int, int>{};

  write(clear, codeSize);
  var prefix = indices[0];
  for (var i = 1; i < indices.length; i++) {
    final k = indices[i];
    final key = (prefix << 8) | k;
    final found = dictionary[key];
    if (found != null) {
      prefix = found;
      continue;
    }
    write(prefix, codeSize);
    dictionary[key] = next++;
    if (next - 1 == (1 << codeSize) && codeSize < 12) codeSize++;
    if (next == 4096) {
      write(clear, codeSize);
      dictionary = <int, int>{};
      codeSize = minCodeSize + 1;
      next = end + 1;
    }
    prefix = k;
  }
  write(prefix, codeSize);
  write(end, codeSize);
  if (bits > 0) out.addByte(buffer & 255);
  return out.toBytes();
}
