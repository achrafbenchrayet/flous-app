import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ExpenseLineChart extends StatelessWidget {
  final List> dailyExpenses;
  const ExpenseLineChart({super.key, required this.dailyExpenses});

  @override
  Widget build(BuildContext context) {
    if (dailyExpenses.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    double maxAmt = 50.0;
    for (int i = 0; i < dailyExpenses.length; i++) {
      final double amt = (dailyExpenses[i]['amount'] as int) / 1000.0;
      spots.add(FlSpot(i.toDouble(), amt));
      if (amt > maxAmt) maxAmt = amt;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dépenses (7 derniers jours)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 0, maxY: maxAmt * 1.25,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, reservedSize: 22,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < dailyExpenses.length) {
                            return Text(dailyExpenses[idx]['day'], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(spots: spots, isCurved: true, color: AppColors.primary, barWidth: 3, dotData: const FlDotData(show: false)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
