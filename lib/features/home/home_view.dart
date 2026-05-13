import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _controller = HomeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Aksi Cepat",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037))),
                  const SizedBox(height: 15),
                  _buildScanActionCard(),
                  const SizedBox(height: 30),
                  const Text("Statistik Tanaman",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037))),
                  const SizedBox(height: 15),
                  _buildStatisticsGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF6D4C41)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Halo, ${_controller.displayName}!",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Serif')),
                    const Text("Tanaman Anda terlihat lebih baik hari ini.",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF8D6E63),
                    child: Text(_controller.avatarInitial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _controller.logout(context),
                    icon: const Icon(Icons.logout, color: Colors.white),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF4E342E).withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_outlined, color: Colors.white, size: 30),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("STATUS SYNC CLOUD",
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1)),
                    Text(_controller.syncStatus,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScanActionCard() {
    return InkWell(
      onTap: () => _controller.onScanPressed(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 35),
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  size: 35, color: Colors.white),
            ),
            const SizedBox(height: 15),
            const Text("Mulai Deteksi YOLOv8",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const Text("Gunakan kamera untuk cek daun",
                style: TextStyle(color: Colors.white60, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Row(
      children: [
        _buildStatCard("Daun Sehat", _controller.healthyCount.toString(),
            Icons.check_circle_outline, const Color(0xFF2E7D32)),
        const SizedBox(width: 15),
        _buildStatCard("Terindikasi Sakit", _controller.sickCount.toString(),
            Icons.warning_amber_rounded, const Color(0xFFC62828)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 15),
            Text(value,
                style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E342E))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      height: 70,
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.home_outlined,
            label: 'Beranda',
            isActive: true,
            onTap: () {},
          ),
          const SizedBox(width: 40),
          _navItem(
            icon: Icons.history,
            label: 'Riwayat',
            isActive: false,
            onTap: () => context.go('/history'),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF1B5E20) : Colors.grey),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isActive ? const Color(0xFF1B5E20) : Colors.grey,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildFab() {
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
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.fullscreen_exit_rounded,
            size: 35, color: Colors.white),
        onPressed: () => _controller.onScanPressed(context),
      ),
    );
  }
}
