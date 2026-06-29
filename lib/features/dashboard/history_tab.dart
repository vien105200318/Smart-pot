import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'History Data',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Monitor environmental trends over time.',
              style: TextStyle(color: Colors.white54, fontSize: 15),
            ),
            const SizedBox(height: 32),

            Container(
              height: 380, 
              padding: const EdgeInsets.only(right: 24, left: 12, top: 24, bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C896).withOpacity(0.03),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Row(
                      children: [
                        Icon(Icons.water_drop, color: Color(0xFF00C896), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Soil Moisture (%)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        Spacer(),
                        Text(
                          'Last 7 Days',
                          style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withOpacity(0.05), 
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (value.toInt() >= 0 && value.toInt() < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      days[value.toInt()], 
                                      style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 45),
                              FlSpot(1, 55),
                              FlSpot(2, 48),
                              FlSpot(3, 65),
                              FlSpot(4, 75),
                              FlSpot(5, 68),
                              FlSpot(6, 65),
                            ],
                            isCurved: true,
                            color: const Color(0xFF00C896),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                color: const Color(0xFF161B22),
                                strokeColor: const Color(0xFF00C896),
                                strokeWidth: 2,
                                radius: 4,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF00C896).withOpacity(0.3),
                                  const Color(0xFF00C896).withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                        maxY: 100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterChip('1 Day', isActive: false),
                _buildFilterChip('1 Week', isActive: true),
                _buildFilterChip('1 Month', isActive: false),
                _buildFilterChip('All Time', isActive: false),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00C896).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF00C896).withOpacity(0.5) : Colors.white12,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? const Color(0xFF00C896) : Colors.white54,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}