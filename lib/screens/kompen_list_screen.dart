import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class KompenListScreen extends StatefulWidget {
  const KompenListScreen({super.key});

  @override
  State<KompenListScreen> createState() => _KompenListScreenState();
}

class _KompenListScreenState extends State<KompenListScreen> {
  String _selectedSemester = 'Semester Ini';
  String _selectedStatus = 'Semua Status';

  final List<Map<String, String>> _listData = [
    {
      'nama': 'Seli Permata',
      'matkul': 'Matkul Database',
      'tanggalKompen': '24 Sab 2024',
      'tanggalAjukan': '4 april 2024',
      'status': 'Approved',
    },
    {
      'nama': 'Seli Permata',
      'matkul': 'Matkul Kalkulus',
      'tanggalKompen': '20 Sab 2024',
      'tanggalAjukan': '20 april 2024',
      'status': 'Pending',
    },
    {
      'nama': 'Seli Permata',
      'matkul': 'Matkul Jaringan Komputer II',
      'tanggalKompen': '18 April 2024',
      'tanggalAjukan': '18 april 2024',
      'status': 'Approved',
    },
    {
      'nama': 'Seli Permata',
      'matkul': 'Matkul Database',
      'tanggalKompen': '18 April 2024',
      'tanggalAjukan': '18 april 2024',
      'status': 'Approved',
    },
  ];

  List<Map<String, String>> get _filteredData {
    if (_selectedStatus == 'Semua Status') return _listData;
    return _listData
        .where((item) =>
            item['status']!.toLowerCase() == _selectedStatus.toLowerCase())
        .toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.approved;
      case 'pending':
        return AppTheme.pending;
      default:
        return AppTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('Pengajuan Kompen'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Pengajuan Kompen',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),

            // Filter Row
            Row(
              children: [
                _buildDropdown(
                  value: _selectedSemester,
                  items: ['Semester Ini', 'Semester Lalu'],
                  onChanged: (val) =>
                      setState(() => _selectedSemester = val ?? _selectedSemester),
                ),
                const SizedBox(width: 10),
                _buildDropdown(
                  value: _selectedStatus,
                  items: ['Semua Status', 'Approved', 'Pending'],
                  onChanged: (val) =>
                      setState(() => _selectedStatus = val ?? _selectedStatus),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredData.length,
                itemBuilder: (context, index) {
                  final item = _filteredData[index];
                  return _buildListCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppTheme.textDark,
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(Map<String, String> item) {
    final statusColor = _statusColor(item['status']!);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.lightRed.withValues(alpha: 0.3),
            child: const Icon(Icons.person, color: AppTheme.primaryRed, size: 24),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama']!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  item['matkul']!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.tagBeige,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['tanggalKompen']!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Date + Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['tanggalAjukan']!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['status']!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}