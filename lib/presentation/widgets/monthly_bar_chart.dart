import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MonthlyBarChart extends StatelessWidget {
  final List monthlyData;
  const MonthlyBarChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) return const SizedBox.shrink();

    double maxY = 100.0;
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < monthlyData.length; i++) {
      final double inc = (monthlyData[i]['income'] as int) / 1000.0;
      final double exp = (monthlyData[i]['expense'] as int) / 1000.0;
      if (inc > maxY) maxY = inc;
      if (exp > maxY) maxY = exp;
      groups.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: inc, color: AppColors.income, width: 8),
        BarChartRodData(toY: exp, color: AppColors.expense, width: 8),
      ]));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Comparatif Recettes / Dépenses', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  maxY: maxY * 1.2, barGroups: groups,
                  borderData: FlBorderData(show: false), gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < monthlyData.length) {
                            return Text(monthlyData[idx]['month'], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
