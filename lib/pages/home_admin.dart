import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:objetos_perdidos/pages/porfile_screen.dart';
import 'package:objetos_perdidos/pages/posts_admin.dart';
import 'package:objetos_perdidos/pages/users_admin.dart';

import 'package:objetos_perdidos/services/dashboard_get_carreers.dart';
import 'package:objetos_perdidos/services/dashboard_get_months.dart';
import 'package:objetos_perdidos/services/dashboard_lost_categories.dart';
import 'package:objetos_perdidos/services/dashboard_lost_locations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _usersStats = [];
  List<Map<String, dynamic>> _lostItemsStatsByMonth = [];
  List<Map<String, dynamic>> _lostItemsStatsByCategory = [];
  List<Map<String, dynamic>> _lostItemsStatsByLocation = [];

  bool _isLoadingUsers = true;
  bool _isLoadingLostItemsByMonth = true;
  bool _isLoadingLostItemsByCategory = true;
  bool _isLoadingLostItemsByLocation = true;

  String _errorUsers = '';
  String _errorLostItemsByMonth = '';
  String _errorLostItemsByCategory = '';
  String _errorLostItemsByLocation = '';

  int _currentIndex = 0; // Para gestionar la selección de la pantalla

  @override
  void initState() {
    super.initState();
    _fetchUsersStatsByCarrera();
    _fetchLostItemsByMonth();
    _fetchLostItemsByCategory();
    _fetchLostItemsByLocation();
  }

  Future<void> _fetchUsersStatsByCarrera() async {
    try {
      final data = await fetchUsersStatsByCarrera();
      setState(() {
        _usersStats = data;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _errorUsers = e.toString();
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _fetchLostItemsByMonth() async {
    try {
      final data = await fetchLostItemsByMonth();
      setState(() {
        _lostItemsStatsByMonth = data;
        _isLoadingLostItemsByMonth = false;
      });
    } catch (e) {
      setState(() {
        _errorLostItemsByMonth = e.toString();
        _isLoadingLostItemsByMonth = false;
      });
    }
  }

  Future<void> _fetchLostItemsByCategory() async {
    try {
      final data = await fetchLostItemsByCategory();
      setState(() {
        _lostItemsStatsByCategory = data;
        _isLoadingLostItemsByCategory = false;
      });
    } catch (e) {
      setState(() {
        _errorLostItemsByCategory = e.toString();
        _isLoadingLostItemsByCategory = false;
      });
    }
  }

  Future<void> _fetchLostItemsByLocation() async {
    try {
      final data = await fetchLostItemsByLocation();
      setState(() {
        _lostItemsStatsByLocation = data;
        _isLoadingLostItemsByLocation = false;
      });
    } catch (e) {
      setState(() {
        _errorLostItemsByLocation = e.toString();
        _isLoadingLostItemsByLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrador')),
      body: _getScreenForIndex(
          _currentIndex), // Renderiza la pantalla según el índice
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex =
                index; // Cambia la pantalla según el ítem seleccionado
          });
        },
        selectedItemColor: Colors.red, // Cambiar color del ítem seleccionado
        unselectedItemColor:
            Colors.grey, // Cambiar color del ítem no seleccionado
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Publicaciones',
          ),
        ],
      ),
    );
  }

  // Función que renderiza las pantallas según el índice seleccionado en el BottomNavigationBar
  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return _buildDashboardScreen(); // Pantalla principal (Dashboard)
      case 1:
        return const UserListScreen(); // Pantalla de usuarios con userType: normal
      case 2:
        return const ProfileScreen(); // Pantalla de perfil
      case 3:
        return const PostsAdmin();
      default:
        return _buildDashboardScreen();
    }
  }

  Widget _buildDashboardScreen() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildStatsCard(
          title: 'Usuarios por Carrera',
          isLoading: _isLoadingUsers,
          errorMessage: _errorUsers,
          data: _normalizeData(_usersStats),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          title: 'Objetos Perdidos por Mes',
          isLoading: _isLoadingLostItemsByMonth,
          errorMessage: _errorLostItemsByMonth,
          data: _normalizeData(_lostItemsStatsByMonth),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          title: 'Categorías más Perdidas',
          isLoading: _isLoadingLostItemsByCategory,
          errorMessage: _errorLostItemsByCategory,
          data: _normalizeData(_lostItemsStatsByCategory),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          title: 'Ubicaciones con Más Pérdidas',
          isLoading: _isLoadingLostItemsByLocation,
          errorMessage: _errorLostItemsByLocation,
          data: _normalizeData(_lostItemsStatsByLocation),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required String title,
    required bool isLoading,
    required String errorMessage,
    required Map<String, int> data,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _buildBarChart(data),
          ],
        ),
      ),
    );
  }

  Map<String, int> _normalizeData(List<Map<String, dynamic>> data) {
    final Map<String, int> combinedData = {};
    for (var item in data) {
      String key = item['_id'].toString();
      int count = item['count'];
      combinedData[key] = (combinedData[key] ?? 0) + count;
    }
    return combinedData;
  }

  Widget _buildBarChart(Map<String, int> data) {
    final dataList = data.keys.toList();

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(enabled: true),
          titlesData: _buildTitlesData(dataList),
          borderData: FlBorderData(show: false),
          barGroups: _createBarGroups(data),
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
        ),
      ),
    );
  }

  FlTitlesData _buildTitlesData(List<String> dataList) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value < 0 || value >= dataList.length) {
              return const SizedBox.shrink();
            }
            return Text(
              dataList[value.toInt()],
              style: const TextStyle(fontSize: 10, color: Colors.black),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _createBarGroups(Map<String, int> data) {
    final dataList = data.keys.toList();

    return List.generate(dataList.length, (index) {
      final value = data[dataList[index]] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: Colors.blueAccent,
            width: 16,
          ),
        ],
      );
    });
  }
}
