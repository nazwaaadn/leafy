import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'history_controller.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.put(HistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context, controller),
      body: Column(
        children: [
          _buildMonthHeader(controller),
          _buildCalendar(controller),
          // Banner "Menunggu Sinkronisasi" — hanya muncul jika ada pending
          Obx(() {
            final pending = controller.pendingCount.value;
            if (pending == 0) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFCA28), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      color: Color(0xFFF57F17), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$pending scan menunggu sinkronisasi ke server',
                      style: const TextStyle(
                        color: Color(0xFF5D4037),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Expanded(
            child: Obx(() {
              final records = controller.recordsForSelectedDate;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateLabel(controller),
                  const SizedBox(height: 12),
                  Expanded(
                    child: records.isEmpty
                        ? _buildEmptyState(context)
                        : _buildRecordList(context, records),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, HistoryController controller) {
    return AppBar(
      backgroundColor: const Color(0xFFEAE4D9),
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'Riwayat & Kalender',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF4A3728),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            tooltip: 'Pilih Bulan & Tahun',
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xFF6B3A2A),
              size: 24,
            ),
            onPressed: () => _showMonthYearPicker(context, controller),
          ),
        ),
      ],
    );
  }

  Future<void> _showMonthYearPicker(
      BuildContext context, HistoryController controller) async {
    final current = controller.activeMonth.value;

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2030, 12),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Pilih Bulan & Tahun',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B3A2A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF4A3728),
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B3A2A),
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.changeMonth(picked);
    }
  }

  Widget _buildMonthHeader(HistoryController controller) {
    return Obx(() => Container(
          width: double.infinity,
          color: const Color(0xFFEAE4D9),
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF8A7A6A),
              ),
              const SizedBox(width: 6),
              Text(
                controller.formattedActiveMonth(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A7A6A),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildCalendar(HistoryController controller) {
    return Obx(() {
      final days = controller.calendarDays;

      return Container(
        color: const Color(0xFFEAE4D9),
        child: Column(
          children: [
            SizedBox(
              height: 84,
              child: ListView.builder(
                controller: controller.calendarScrollController,
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final date = days[index];
                  return Obx(() {
                    final isActive = controller.isSelected(date);
                    final hasData = controller.hasData(date);

                    return GestureDetector(
                      onTap: () => controller.selectDate(date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        width: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF6B3A2A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isActive
                                  ? const Color(0xFF6B3A2A).withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.dayName(date),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.white70
                                    : const Color(0xFF8A7A6A),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF4A3728),
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasData
                                    ? (isActive
                                        ? Colors.white54
                                        : const Color(0xFF4A7C3F))
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF6B3A2A).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDateLabel(HistoryController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        'Hasil untuk: ${controller.formattedSelectedDate()}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A3728),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A7C3F).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 36,
                  color: Color(0xFF4A7C3F),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Belum ada pengecekan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A3728),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tidak ada data scan tanaman\nuntuk tanggal ini',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8A7A6A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7C3F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Pengecekan Baru',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordList(BuildContext context, List<ScanRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: records.length,
      itemBuilder: (context, index) {
        return _buildRecordCard(context, records[index]);
      },
    );
  }

  Widget _buildRecordCard(BuildContext context, ScanRecord record) {
    final isHealthy = record.healthStatus == HealthStatus.healthy;
    final isSynced = record.syncStatus == SyncStatus.synced;

    final Color accentColor =
        isHealthy ? const Color(0xFF4A7C3F) : const Color(0xFFE65100);
    final Color bgColor = isHealthy
        ? const Color(0xFF4A7C3F).withValues(alpha: 0.1)
        : const Color(0xFFE65100).withValues(alpha: 0.1);
    final IconData statusIcon = isHealthy
        ? Icons.check_circle_outline_rounded
        : Icons.warning_amber_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            context.push('/history-detail', extra: record);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            size: 13,
                            color: Color(0xFFBBAA99),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Log ID: ${record.logId}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFBBAA99),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            isSynced
                                ? Icons.cloud_done_outlined
                                : Icons.storage_outlined,
                            size: 13,
                            color: const Color(0xFFBBAA99),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSynced ? 'Tersinkron' : 'Lokal',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFBBAA99),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          statusIcon,
                          color: accentColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.conditionName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3A2A1E),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Pukul ${record.time}  •  Akurasi AI: ${record.accuracyPercent}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8A7A6A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFBBAA99),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      height: 70,
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.home_outlined,
            label: 'Beranda',
            isActive: false,
            onTap: () => context.go('/home'),
          ),
          const SizedBox(width: 40),
          _navItem(
            icon: Icons.history,
            label: 'Riwayat',
            isActive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFF6B3A2A) : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight:
                  isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Container(
      height: 75,
      width: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF4E342E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.fullscreen_exit_rounded,
          size: 35,
          color: Colors.white,
        ),
        onPressed: () => context.go('/home'),
      ),
    );
  }
}