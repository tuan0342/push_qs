import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

// data_table_2: ^2.6.0

class DataTable2Example extends StatelessWidget {
  const DataTable2Example({super.key});

  @override
  Widget build(BuildContext context) {
    final flights = <Map<String, String>>[
      {
        'id': 'VN123',
        'airline': 'Vietnam Airlines',
        'from': 'Hà Nội',
        'to': 'TP.HCM',
        'note':
            'Chuyến bay này có thời gian delay khá dài do điều kiện thời tiết xấu.',
      },
      {
        'id': 'VJ456',
        'airline': 'Vietjet Air',
        'from': 'Đà Nẵng',
        'to': 'Cần Thơ',
        'note':
            'Đây là một chuyến bay nội địa giá rẻ, phù hợp cho du lịch cuối tuần. Đây là một chuyến bay nội địa giá rẻ, phù hợp cho du lịch cuối tuần.',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('DataTable2')),
      body: Column(
        children: [
          Container(color: Colors.amber, height: 100),
          Expanded(
            child: DataTable2(
              empty: const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Không có dữ liệu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              minWidth: 900,
              columnSpacing: 16,
              horizontalMargin: 12,
              headingRowColor: WidgetStatePropertyAll(Colors.grey.shade500),
              dataRowHeight: 100,
              dataRowColor: WidgetStateProperty.all(Colors.grey.shade200),
              columns: const [
                DataColumn2(
                  label: Text('Mã'),
                  size: ColumnSize.S,
                  fixedWidth: 80,
                ),
                DataColumn2(
                  label: Text('Hãng bay'),
                  size: ColumnSize.M,
                  fixedWidth: 180,
                ),
                DataColumn2(
                  label: Text('Điểm đi'),
                  size: ColumnSize.M,
                  fixedWidth: 160,
                ),
                DataColumn2(
                  label: Text('Điểm đến'),
                  size: ColumnSize.M,
                  fixedWidth: 160,
                ),

                DataColumn2(label: Text('Ghi chú'), size: ColumnSize.L),
              ],

              rows:
                  flights.map((f) {
                    return DataRow(
                      onSelectChanged: (_) {},
                      cells: [
                        DataCell(_cell(f['id']!, 80)),
                        DataCell(_cell(f['airline']!, 180)),
                        DataCell(_cell(f['from']!, 160)),
                        DataCell(_cell(f['to']!, 160)),
                        DataCell(_cell(f['note']!)),
                        // DataCell(
                        //   IntrinsicHeight(
                        //     child: Text(
                        //       f['note']!,
                        //       softWrap: true,
                        //       overflow: TextOverflow.visible,
                        //       maxLines: null,
                        //     ),
                        //   ),
                        // ),
                      ],
                    );
                  }).toList(),
            ),
          ),

          Container(color: Colors.red, height: 100),
        ],
      ),
    );
  }

  Widget _cell(String text, [double? maxWidth]) {
    final child = Text(
      text,
      maxLines: null,
      overflow: TextOverflow.visible,
      softWrap: true,
    );
    return (maxWidth != null)
        ? ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        )
        : child;
  }
}
