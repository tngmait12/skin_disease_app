import 'dart:io';
import 'dart:isolate';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter/src/bindings/tensorflow_lite_bindings_generated.dart';
import 'package:image/image.dart' as img;

// Custom FlexDelegate implementation for supporting Select TensorFlow Ops (Flex)
class FlexDelegate implements Delegate {
  static DynamicLibrary? _flexLib;
  static int Function(Pointer<Void>, Pointer<Void>)? _createFn;
  static void Function(Pointer<Void>, Pointer<Void>, int)? _deleteFn;

  static void _init() {
    if (_flexLib != null) return;
    
    // Try to open litert_flex_jni first, then tensorflowlite_flex_jni
    try {
      _flexLib = DynamicLibrary.open('liblitert_flex_jni.so');
      print('✅ Dart FFI Flex: Loaded liblitert_flex_jni.so successfully');
    } catch (_) {
      // Ignore and try tensorflowlite_flex_jni
    }

    if (_flexLib == null) {
      try {
        _flexLib = DynamicLibrary.open('libtensorflowlite_flex_jni.so');
        print('✅ Dart FFI Flex: Loaded libtensorflowlite_flex_jni.so successfully');
      } catch (e) {
        print('❌ Dart FFI Flex: Failed to load both flex JNI libraries: $e');
        rethrow;
      }
    }

    try {
      try {
        _createFn = _flexLib!
            .lookup<NativeFunction<Int64 Function(Pointer<Void>, Pointer<Void>)>>(
                'Java_org_tensorflow_lite_flex_FlexDelegate_nativeCreateDelegate')
            .asFunction();
        _deleteFn = _flexLib!
            .lookup<NativeFunction<Void Function(Pointer<Void>, Pointer<Void>, Int64)>>(
                'Java_org_tensorflow_lite_flex_FlexDelegate_nativeDeleteDelegate')
            .asFunction();
        print('✅ Dart FFI Flex: Resolved Java_org_tensorflow_lite_flex_FlexDelegate native JNI symbols successfully.');
      } catch (e2) {
        try {
          _createFn = _flexLib!
              .lookup<NativeFunction<Int64 Function(Pointer<Void>, Pointer<Void>)>>(
                  'Java_com_google_ai_edge_litert_flex_FlexDelegate_nativeCreateDelegate')
              .asFunction();
          _deleteFn = _flexLib!
              .lookup<NativeFunction<Void Function(Pointer<Void>, Pointer<Void>, Int64)>>(
                  'Java_com_google_ai_edge_litert_flex_FlexDelegate_nativeDeleteDelegate')
              .asFunction();
          print('✅ Dart FFI Flex: Resolved Java_com_google_ai_edge_litert_flex_FlexDelegate native JNI symbols successfully.');
        } catch (_) {
          rethrow;
        }
      }
    } catch (e) {
      print('❌ Dart FFI Flex: Failed to resolve JNI Flex Delegate symbols: $e');
      rethrow;
    }
  }

  late final Pointer<TfLiteDelegate> _delegatePointer;
  bool _deleted = false;

  FlexDelegate() {
    _init();
    if (_createFn == null) {
      throw StateError('Flex Delegate JNI functions not initialized');
    }
    final address = _createFn!(nullptr, nullptr);
    if (address == 0) {
      throw StateError('Failed to create native Flex Delegate (returned null address)');
    }
    _delegatePointer = Pointer<TfLiteDelegate>.fromAddress(address);
    print('✅ Dart FFI Flex: Created native Flex Delegate pointer at address: $address');
  }

  @override
  Pointer<TfLiteDelegate> get base => _delegatePointer;

  @override
  void delete() {
    if (!_deleted) {
      if (_deleteFn != null && _delegatePointer.address != 0) {
        _deleteFn!(nullptr, nullptr, _delegatePointer.address);
        print('🧹 Dart FFI Flex: Deleted native Flex Delegate at address: ${_delegatePointer.address}');
      }
      _deleted = true;
    }
  }
}

class SkinClass {
  final String rawLabel;     // Tên đầy đủ: ví dụ "Viêm da cơ địa (Atopic Dermatitis Photos)"
  final String englishName;  // Tên tiếng Anh: ví dụ "Atopic Dermatitis Photos"

  SkinClass({required this.rawLabel, required this.englishName});
}

class TFLiteHelper {
  static List<SkinClass>? _labelsA;
  static List<SkinClass>? _labelsB;
  static Uint8List? _binaryModelBytes;
  static Uint8List? _expertModelABytes;
  static Uint8List? _expertModelBBytes;

  // Bộ nhớ đệm tĩnh cho các thực thể Interpreter và FlexDelegate của TensorFlow Lite
  static Interpreter? _binaryInterpreter;
  static Interpreter? _expertInterpreterA;
  static Interpreter? _expertInterpreterB;
  static FlexDelegate? _binaryFlexDelegate;
  static FlexDelegate? _expertFlexDelegateA;
  static FlexDelegate? _expertFlexDelegateB;

  // 10 nhãn của lớp A được người dùng cung cấp
  static const Set<String> _groupANames = {
    'Actinic Keratosis Basal Cell Carcinoma And Other Malignant Lesions',
    'Benign',
    'Eczema Photos',
    'Light Diseases And Disorders Of Pigmentation',
    'Malignant',
    'Nail Fungus And Other Nail Disease',
    'Psoriasis Pictures Lichen Planus And Related Diseases',
    'Seborrheic Keratoses And Other Benign Tumors',
    'Tinea Ringworm Candidiasis And Other Fungal Infections',
    'Warts Molluscum And Other Viral Infections',
  };

  static Future<void> loadModel() async {
    try {
      print('⏳ Bắt đầu phân tích và nạp danh sách nhãn...');

      // Nạp động các thư viện Flex Delegate Native qua Dart FFI để tự động đăng ký với runtime trong tiến trình
      if (Platform.isAndroid) {
        try {
          DynamicLibrary.open('liblitert_flex_jni.so');
          print('✅ Dart FFI: Đã nạp thành công liblitert_flex_jni.so');
        } catch (e) {
          print('⚠️ Dart FFI: Không thể nạp liblitert_flex_jni.so: $e');
        }

        try {
          DynamicLibrary.open('libtensorflowlite_flex_jni.so');
          print('✅ Dart FFI: Đã nạp thành công libtensorflowlite_flex_jni.so');
        } catch (e) {
          print('⚠️ Dart FFI: Không thể nạp libtensorflowlite_flex_jni.so: $e');
        }
      }

      // Nạp từ điển tên bệnh (labels_35classes.txt)
      final labelData = await rootBundle.loadString('assets/models/labels_35classes.txt');

      final rawLines = labelData.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      List<SkinClass> allClasses = [];
      for (var line in rawLines) {
        // Trích xuất tên tiếng Anh nằm trong dấu ngoặc đơn ()
        final match = RegExp(r'\(([^)]+)\)').firstMatch(line);
        final englishName = match?.group(1)?.trim() ?? '';
        allClasses.add(SkinClass(rawLabel: line, englishName: englishName));
      }

      // Tách thành 2 nhóm A và B dựa trên groupANames
      final groupA = allClasses.where((c) => _groupANames.contains(c.englishName)).toList();
      final groupB = allClasses.where((c) => !_groupANames.contains(c.englishName)).toList();

      // Sắp xếp Alphabetical theo englishName để khớp chuẩn xác thứ tự output của model chuyên gia
      groupA.sort((a, b) => a.englishName.toLowerCase().compareTo(b.englishName.toLowerCase()));
      groupB.sort((a, b) => a.englishName.toLowerCase().compareTo(b.englishName.toLowerCase()));

      _labelsA = groupA;
      _labelsB = groupB;

      // Nạp bytes các mô hình TFLite vào bộ nhớ đệm RAM
      print('⏳ Đang nạp các tệp mô hình TFLite vào bộ nhớ đệm RAM...');
      final binaryData = await rootBundle.load('assets/models/Binary_Model.tflite');
      _binaryModelBytes = binaryData.buffer.asUint8List();

      final expertAData = await rootBundle.load('assets/models/Expert_Model_A.tflite');
      _expertModelABytes = expertAData.buffer.asUint8List();

      final expertBData = await rootBundle.load('assets/models/Expert_Model_B.tflite');
      _expertModelBBytes = expertBData.buffer.asUint8List();

      print('✅ Nạp nhãn và toàn bộ mô hình vào RAM thành công!');
      print('   - Số lượng lớp A: ${_labelsA?.length} (kỳ vọng: 10)');
      print('   - Số lượng lớp B: ${_labelsB?.length} (kỳ vọng: 25)');

      // Khởi tạo sẵn các Interpreter tĩnh một lần duy nhất từ RAM
      print('🧠 Đang khởi tạo sẵn các Interpreter mô hình TFLite vào bộ nhớ đệm RAM...');

      // 1. Khởi tạo Binary Model Interpreter
      final binaryOptions = InterpreterOptions();
      if (Platform.isAndroid) {
        try {
          _binaryFlexDelegate = FlexDelegate();
          binaryOptions.addDelegate(_binaryFlexDelegate!);
          print('✅ [Binary Model] Đã thêm FlexDelegate vào InterpreterOptions.');
        } catch (e) {
          print('⚠️ [Binary Model] Không thể khởi tạo/thêm FlexDelegate: $e');
        }
      }
      _binaryInterpreter = Interpreter.fromBuffer(
        _binaryModelBytes!,
        options: binaryOptions,
      );

      // 2. Khởi tạo Expert A Model Interpreter
      final expertAOptions = InterpreterOptions();
      if (Platform.isAndroid) {
        try {
          _expertFlexDelegateA = FlexDelegate();
          expertAOptions.addDelegate(_expertFlexDelegateA!);
          print('✅ [Expert A Model] Đã thêm FlexDelegate vào InterpreterOptions.');
        } catch (e) {
          print('⚠️ [Expert A Model] Không thể khởi tạo/thêm FlexDelegate: $e');
        }
      }
      _expertInterpreterA = Interpreter.fromBuffer(
        _expertModelABytes!,
        options: expertAOptions,
      );

      // 3. Khởi tạo Expert B Model Interpreter
      final expertBOptions = InterpreterOptions();
      if (Platform.isAndroid) {
        try {
          _expertFlexDelegateB = FlexDelegate();
          expertBOptions.addDelegate(_expertFlexDelegateB!);
          print('✅ [Expert B Model] Đã thêm FlexDelegate vào InterpreterOptions.');
        } catch (e) {
          print('⚠️ [Expert B Model] Không thể khởi tạo/thêm FlexDelegate: $e');
        }
      }
      _expertInterpreterB = Interpreter.fromBuffer(
        _expertModelBBytes!,
        options: expertBOptions,
      );

      print('✅ Khởi tạo và đệm toàn bộ Interpreter vào RAM thành công!');
    } catch (e) {
      print('❌ Lỗi khi nạp nhãn/mô hình: $e');
    }
  }

  static Future<Map<String, dynamic>?> runInference(String imagePath) async {
    // Nạp nhãn và khởi tạo mô hình trên luồng chính nếu chưa được nạp
    if (_labelsA == null || _labelsB == null || _binaryInterpreter == null || _expertInterpreterA == null || _expertInterpreterB == null) {
      print('Tài nguyên chưa được nạp đầy đủ! Tiến hành nạp trên luồng chính...');
      await loadModel();
      if (_labelsA == null || _labelsB == null || _binaryInterpreter == null || _expertInterpreterA == null || _expertInterpreterB == null) {
        print('Không thể nạp đầy đủ tài nguyên trên luồng chính!');
        return null;
      }
    }

    // --- TIỀN XỬ LÝ ẢNH ---
    File imageFile = File(imagePath);
    if (!imageFile.existsSync()) {
      print('File ảnh không tồn tại: $imagePath');
      return null;
    }

    img.Image? rawImage = img.decodeImage(imageFile.readAsBytesSync());
    if (rawImage == null) {
      print('Không thể decode ảnh!');
      return null;
    }

    // Resize về đúng 224x224 như lúc huấn luyện
    img.Image resizedImage = img.copyResize(rawImage, width: 224, height: 224);

    // Chuyển ảnh thành mảng Float32List có kích thước [1, 224, 224, 3]
    var input = List.generate(
      1,
      (i) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            // Lấy mã màu RGB và chuẩn hóa hoặc giữ nguyên tùy theo cấu trúc model gốc
            return [
              pixel.r,
              pixel.g,
              pixel.b,
            ];
          },
        ),
      ),
    );

    double binaryConf = 0.0;
    bool isClassA = true;

    // --- BƯỚC 1: DỰ ĐOÁN NHỊ PHÂN (Sử dụng static cached interpreter) ---
    try {
      var binaryOutput = List.generate(1, (i) => List.filled(2, 0.0));
      print('🧠 [Bước 1] Đang chạy dự đoán Binary Model từ bộ đệm RAM...');
      _binaryInterpreter!.run(input, binaryOutput);

      double probA = binaryOutput[0][0];
      double probB = binaryOutput[0][1];
      print('📊 Kết quả Binary Model: Lớp A (0) = ${(probA * 100).toStringAsFixed(2)}%, Lớp B (1) = ${(probB * 100).toStringAsFixed(2)}%');

      if (probA >= probB) {
        isClassA = true;
        binaryConf = probA;
      } else {
        isClassA = false;
        binaryConf = probB;
      }
    } catch (e) {
      print('❌ Lỗi trong quá trình suy luận Binary Model: $e');
      return null;
    }

    // --- BƯỚC 2: DỰ ĐOÁN CHUYÊN GIA (Sử dụng static cached interpreter) ---
    final Interpreter expertInterpreter = isClassA ? _expertInterpreterA! : _expertInterpreterB!;
    final List<SkinClass> chosenLabels = isClassA ? _labelsA! : _labelsB!;

    try {
      var expertOutput = List.generate(1, (i) => List.filled(chosenLabels.length, 0.0));
      print('🧠 [Bước 2] Đang chạy dự đoán Expert Model từ bộ đệm RAM...');
      expertInterpreter.run(input, expertOutput);

      List<double> probabilities = expertOutput[0];
      double maxExpertConf = 0.0;
      int maxIndex = -1;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxExpertConf) {
          maxExpertConf = probabilities[i];
          maxIndex = i;
        }
      }

      if (maxIndex == -1) {
        print('❌ Không tìm thấy chỉ mục dự đoán hợp lệ từ Expert Model.');
        return null;
      }

      // Độ tin cậy tính bằng: độ tin cậy model nhị phân x độ tin cậy model chuyên gia
      double finalConfidence = binaryConf * maxExpertConf;
      final matchedClass = chosenLabels[maxIndex];

      print('🎯 Chẩn đoán hoàn tất:');
      print('   - Nhóm quyết định: ${isClassA ? "Lớp A" : "Lớp B"} (Độ tin cậy: ${(binaryConf * 100).toStringAsFixed(2)}%)');
      print('   - Bệnh dự đoán: ${matchedClass.englishName} (Độ tin cậy: ${(maxExpertConf * 100).toStringAsFixed(2)}%)');
      print('   - Độ tin cậy tích hợp (Binary x Expert): ${(finalConfidence * 100).toStringAsFixed(2)}%');

      return {
        'disease_name': matchedClass.rawLabel,
        'confidence': (finalConfidence * 100).toStringAsFixed(2),
      };
    } catch (e) {
      print('❌ Lỗi trong quá trình suy luận Expert Model: $e');
      return null;
    }
  }

  static void close() {
    _binaryInterpreter?.close();
    _expertInterpreterA?.close();
    _expertInterpreterB?.close();
    _binaryFlexDelegate?.delete();
    _expertFlexDelegateA?.delete();
    _expertFlexDelegateB?.delete();
    print('🧹 Đã giải phóng toàn bộ TFLite Interpreters và FlexDelegates khỏi RAM.');
  }
}
