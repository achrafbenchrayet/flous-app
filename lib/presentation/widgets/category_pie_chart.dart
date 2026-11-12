import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final List categoryDistribution;
  const CategoryPieChart({super.key, required this.categoryDistribution});

  @override
  Widget build(BuildContext context) {
    if (categoryDistribution.isEmpty) return const SizedBox.shrink();

    final int total = categoryDistribution.fold<int>(0, (s, e) => s + (e['amount'] as int));
    final sections = categoryDistribution.take(5).map((e) {
      final int amt = e['amount'] as int;
      final double pct = total > 0 ? (amt / total) * 100 : 0;
      return PieChartSectionData(
        value: amt.toDouble(), color: Color(e['color'] as int), radius: 32,
        title: pct >= 10 ? '${pct.toStringAsFixed(0)}%' : '',
        titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Répartition par catégorie', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 32, sections: sections)),
            ),
          ],
        ),
      ),
    );
  }
}
