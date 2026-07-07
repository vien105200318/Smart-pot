import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  // Biến lưu trạng thái bộ lọc thời gian
  String _selectedFilter = '1 Week';

  // Hàm tính mốc thời gian truy vấn Firebase
  DateTime _getFilterDate() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case '1 Day':
        return now.subtract(const Duration(days: 1));
      case '1 Week':
        return now.subtract(const Duration(days: 7));
      case '1 Month':
        return now.subtract(const Duration(days: 30));
      case 'All Time':
      default:
        return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

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
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Monitor all environmental trends over time.',
              style: TextStyle(color: Colors.white54, fontSize: 15),
            ),
            const SizedBox(height: 32),

            // ==========================================
            // 1. BIỂU ĐỒ 3 ĐƯỜNG (Từ collection: sensor_history)
            // ==========================================
            Container(
              height: 420, 
              padding: const EdgeInsets.only(
                  right: 24, left: 12, top: 20, bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withOpacity(0.05), width: 1.5),
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
                  // CHÚ THÍCH MÀU SẮC (LEGEND)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildLegendItem(Colors.lightBlueAccent, 'Air Hum (%)'),
                        _buildLegendItem(const Color(0xFF00C896), 'Soil Moi (%)'),
                        _buildLegendItem(Colors.orangeAccent, 'Water (mins)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // VẼ BIỂU ĐỒ
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('pots')
                          .doc('pot_001')
                          .collection('sensor_history') 
                          .where('timestamp', isGreaterThanOrEqualTo: _getFilterDate())
                          .orderBy('timestamp')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(color: Color(0xFF00C896)));
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'Không có dữ liệu cảm biến trong thời gian này.',
                              style: TextStyle(color: Colors.white38),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        List<FlSpot> airSpots = [];
                        List<FlSpot> soilSpots = [];
                        List<FlSpot> waterSpots = [];
                        List<DateTime> dates = [];

                        for (int i = 0; i < docs.length; i++) {
                          final data = docs[i].data() as Map<String, dynamic>;
                          
                          final airHum = (data['air_humidity'] ?? 0).toDouble();
                          final soilMoi = (data['soil_moisture'] ?? 0).toDouble();
                          final waterDur = (data['water_duration'] ?? 0).toDouble();
                          
                          if (data['timestamp'] != null) {
                            dates.add((data['timestamp'] as Timestamp).toDate());
                            double x = i.toDouble();
                            airSpots.add(FlSpot(x, airHum));
                            soilSpots.add(FlSpot(x, soilMoi));
                            waterSpots.add(FlSpot(x, waterDur));
                          }
                        }

                        return LineChart(
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
                                    style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= 0 && index < dates.length) {
                                      String formatPattern = _selectedFilter == '1 Day' ? 'HH:mm' : 'dd/MM';
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Text(
                                          DateFormat(formatPattern).format(dates[index]),
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              // ĐƯỜNG 1: KHÔNG KHÍ
                              LineChartBarData(
                                spots: airSpots,
                                isCurved: true,
                                color: Colors.lightBlueAccent,
                                barWidth: 3,
                                dotData: const FlDotData(show: false), 
                              ),
                              // ĐƯỜNG 2: ĐẤT
                              LineChartBarData(
                                spots: soilSpots,
                                isCurved: true,
                                color: const Color(0xFF00C896),
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                              ),
                              // ĐƯỜNG 3: TƯỚI NƯỚC
                              LineChartBarData(
                                spots: waterSpots,
                                isCurved: true,
                                color: Colors.orangeAccent,
                                barWidth: 3,
                                dotData: FlDotData(
                                  show: true, 
                                  getDotPainter: (spot, percent, barData, index) =>
                                      FlDotCirclePainter(
                                    color: const Color(0xFF161B22),
                                    strokeColor: Colors.orangeAccent,
                                    strokeWidth: 2,
                                    radius: 4,
                                  ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orangeAccent.withOpacity(0.3),
                                      Colors.orangeAccent.withOpacity(0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                            minY: 0,
                            maxY: 100, 
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterChip('1 Day'),
                _buildFilterChip('1 Week'),
                _buildFilterChip('1 Month'),
                _buildFilterChip('All Time'),
              ],
            ),
            const SizedBox(height: 40),

            const Text(
              'Recent Activities',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pots')
                  .doc('pot_001')
                  .collection('history') 
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Lỗi tải dữ liệu hoạt động!',
                        style: TextStyle(color: Colors.redAccent)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Color(0xFF00C896)),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Text(
                      'No recent activities.',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final action = data['action'] ?? 'Unknown';
                    final value = data['value'] ?? '';

                    DateTime time = DateTime.now();
                    if (data['timestamp'] != null) {
                      time = (data['timestamp'] as Timestamp).toDate();
                    }
                    final timeString = DateFormat('HH:mm - dd/MM/yyyy').format(time);

                    IconData iconData = Icons.history;
                    Color iconColor = Colors.white54;

                    final actionLower = action.toString().toLowerCase();
                    if (actionLower.contains('tưới') || actionLower.contains('bơm')) {
                      iconData = Icons.water_drop;
                      iconColor = const Color(0xFF00C896);
                    } else if (actionLower.contains('sương')) {
                      iconData = Icons.cloudy_snowing;
                      iconColor = Colors.lightBlueAccent;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.05), width: 1.5),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, color: iconColor, size: 20),
                        ),
                        title: Text(
                          action,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            timeString,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12),
                          ),
                        ),
                        trailing: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF00C896),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isActive = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF00C896).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF00C896).withOpacity(0.5)
                : Colors.white12,
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
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}