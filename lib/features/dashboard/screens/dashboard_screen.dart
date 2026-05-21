import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/core/widgets/appbar_with_drawer.dart';
import '../../../core/constants/app_sizes.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/conditions_breakdown_card.dart';
import '../widgets/current_status_card.dart';
import '../widgets/trend_chart_card.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWithDrawer(
        title: 'Skin Health Dashboard',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            CurrentStatusCard(),
            SizedBox(height: AppSizes.p24),
            TrendChartCard(),
            SizedBox(height: AppSizes.p24),
            ConditionsBreakdownCard(),
            SizedBox(height: AppSizes.p32),
          ],
        ),
      ),
    );
  }
}