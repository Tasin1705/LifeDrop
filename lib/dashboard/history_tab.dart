import 'package:flutter/material.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Donation History',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
              dataRowMinHeight: 48,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              columns: const [
                DataColumn(label: Text('DATE')),
                DataColumn(label: Text('LOCATION')),
                DataColumn(label: Text('BLOOD TYPE')),
                DataColumn(label: Text('AMOUNT')),
                DataColumn(label: Text('STATUS')),
              ],
              rows: [
                _historyRow('2023-11-15', 'City Blood Center', 'O+', '450ml'),
                _historyRow('2023-08-20', 'Community Hospital', 'O+', '450ml'),
                _historyRow('2023-05-10', 'Red Cross Center', 'O+', '450ml'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

DataRow _historyRow(
  String date,
  String location,
  String bloodType,
  String amount,
) {
  return DataRow(
    cells: [
      DataCell(Text(date)),
      DataCell(Text(location)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            bloodType,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      DataCell(Text(amount)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'completed',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ],
  );
}
