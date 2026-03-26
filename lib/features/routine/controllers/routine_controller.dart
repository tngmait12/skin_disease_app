import 'package:get/get.dart';
import '../models/routine_model.dart';


class RoutineController extends GetxController {
  final String diseaseName;
  late SkinRoutine routine;

  var completedMorning = <bool>[].obs;
  var completedEvening = <bool>[].obs;

  RoutineController({required this.diseaseName});

  @override
  void onInit() {
    super.onInit();
    routine = getRoutineForDisease(diseaseName);

    completedMorning.assignAll(List.generate(routine.morningRoutine.length, (_) => false));
    completedEvening.assignAll(List.generate(routine.eveningRoutine.length, (_) => false));
  }

  void toggleMorning(int index) {
    completedMorning[index] = !completedMorning[index];
  }

  void toggleEvening(int index) {
    completedEvening[index] = !completedEvening[index];
  }

  // Tính % hoàn thành trong ngày để vẽ thanh Progress Bar
  double get progress {
    int total = completedMorning.length + completedEvening.length;
    if (total == 0) return 0;
    int done = completedMorning.where((e) => e).length + completedEvening.where((e) => e).length;
    return done / total;
  }
}