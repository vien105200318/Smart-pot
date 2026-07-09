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
  String _selectedFilter = '1 Week';

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
            // BỘ LỌC THỜI GIAN
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterChip('1 Day'),
                _buildFilterChip('1 Week'),
                _buildFilterChip('1 Month'),
                _buildFilterChip('All Time'),
              ],
            ),
            const SizedBox(height: 24),

            // ==========================================
            // TÁCH 3 BIỂU ĐỒ ĐỘC LẬP
            // ==========================================
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pots')
                  .doc('pot_001')
                  .collection('sensor_history')
                  .where('timestamp', isGreaterThanOrEqualTo: _getFilterDate())
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF00C896))),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Không có dữ liệu trong thời gian này.',
                      style: TextStyle(color: Colors.white38),
                    ),
                  );
                }

                List<FlSpot> airSpots = [];
                List<FlSpot> soilSpots = [];
                List<FlSpot> waterSpots = [];
                List<DateTime> dates = [];

                double maxSoil = 100; // Tìm giá trị cao nhất để fix trục Y

                for (int i = 0; i < docs.length; i++) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  
                  final airHum = (data['air_humidity'] ?? 0).toDouble();
                  final soilMoi = (data['soil_moisture'] ?? 0).toDouble();
                  final waterDur = (data['water_duration'] ?? 0).toDouble();
                  
                  if (soilMoi > maxSoil) maxSoil = soilMoi; // Nới rộng đồ thị nếu cảm biến lố 100

                  if (data['timestamp'] != null) {
                    dates.add((data['timestamp'] as Timestamp).toDate());
                    double x = i.toDouble();
                    airSpots.add(FlSpot(x, airHum));
                    soilSpots.add(FlSpot(x, soilMoi));
                    waterSpots.add(FlSpot(x, waterDur));
                  }
                }

                return Column(
                  children: [
                    _buildMiniChart(
                      title: 'Air Humidity (%)',
                      color: Colors.lightBlueAccent,
                      spots: airSpots,
                      dates: dates,
                      maxY: 100,
                    ),
                    const SizedBox(height: 16),
                    _buildMiniChart(
                      title: 'Soil Moisture (%)',
                      color: const Color(0xFF00C896),
                      spots: soilSpots,
                      dates: dates,
                      maxY: maxSoil > 100 ? maxSoil + 10 : 100, // Căng trục Y theo dữ liệu thật
                    ),
                    const SizedBox(height: 16),
                    _buildMiniChart(
                      title: 'Watering Duration (mins)',
                      color: Colors.orangeAccent,
                      spots: waterSpots,
                      dates: dates,
                      maxY: 10, // Chỉnh xuống 10 phút cho đồ thị tưới nảy lên rõ hơn
                      isWater: true, // Thêm chấm tròn cho thời gian tưới
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // ==========================================
            // DANH SÁCH LỊCH SỬ HOẠT ĐỘNG
            // ==========================================
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF00C896)),
                  ));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('No recent activities.',
                          style: TextStyle(color: Colors.white38)));
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
                    final timeString =
                        DateFormat('HH:mm - dd/MM/yyyy').format(time);

                    IconData iconData = Icons.history;
                    Color iconColor = Colors.white54;
                    final actionLower = action.toString().toLowerCase();
                    if (actionLower.contains('tưới') ||
                        actionLower.contains('bơm')) {
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
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: Icon(iconData, color: iconColor, size: 20),
                        ),
                        title: Text(action,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white)),
                        subtitle: Text(timeString,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                        trailing: Text(value,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF00C896),
                                fontWeight: FontWeight.w600)),
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
      onTap: () => setState(() => _selectedFilter = label),
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
                  : Colors.white12),
        ),
        child: Text(label,
            style: TextStyle(
                color: isActive ? const Color(0xFF00C896) : Colors.white54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 13)),
      ),
    );
  }

  // Widget vẽ biểu đồ con (Mini Chart)
  Widget _buildMiniChart({
    required String title,
    required Color color,
    required List<FlSpot> spots,
    required List<DateTime> dates,
    required double maxY,
    bool isWater = false,
  }) {
    return Container(
      height: 200, // Chiều cao nhỏ gọn
      padding: const EdgeInsets.only(right: 24, left: 12, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                clipData: const FlClipData.all(), // GIỮ BẢN VẼ TRONG KHUNG, KHÔNG CHO TRÀN RA NGOÀI
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
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < dates.length) {
                          String formatPattern =
                              _selectedFilter == '1 Day' ? 'HH:mm' : 'dd/MM';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat(formatPattern).format(dates[index]),
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
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
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: isWater, // Chỉ hiện chấm tròn nếu là đồ thị bơm nước
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        color: const Color(0xFF161B22),
                        strokeColor: color,
                        strokeWidth: 2,
                        radius: 3,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: maxY,
              ),
            ),
          ),
        ],
      ),
    );
  }
}