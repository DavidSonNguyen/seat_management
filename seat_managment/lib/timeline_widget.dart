import 'package:flutter/material.dart';

class TimeLineWidget extends StatelessWidget {
  final int limit;
  final double sectionSize;
  final ScrollController? scrollController;
  final ScrollController? textController;

  const TimeLineWidget({
    super.key,
    required this.limit,
    required this.sectionSize,
    this.scrollController,
    this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.0,
            child: ListView.builder(
              key: const ObjectKey('time title'),
              padding: EdgeInsets.zero,
              controller: textController,
              scrollDirection: Axis.horizontal,
              itemCount: limit + 1,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: index == 0 || index == limit - 1
                      ? (sectionSize - 18.0)
                      : index == limit
                          ? null
                          : sectionSize + 1,
                  child: Text('$index:00'),
                );
              },
            ),
          ),
          SizedBox(
            height: 10.0,
            child: ListView.separated(
              // keep list view
              key: const ObjectKey('timeline'),
              padding: EdgeInsets.zero,
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: limit * 10 + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const SizedBox();
                }
                return _buildDivider(isLargeDivide: index % 5 == 0);
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: (sectionSize - 9) / 10,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDivider({
    bool isLargeDivide = false,
    // bool
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: isLargeDivide ? 7.0 : 4.0,
          width: 1.0,
          color: Colors.black,
        ),
      ],
    );
  }

// Widget _buildSection() {
//   final sections = <Widget>[];
//   for (var index = 0; index < 10; index++) {
//     sections.add(
//       Padding(
//         padding: EdgeInsets.only(
//           left: index == 0 ? 0.0 : division / 2,
//           right: index == 9 ? 0.0 : division / 2,
//         ),
//         child: _buildDivider(
//           isLargeDivide: index % 4 == 0,
//         ),
//       ),
//     );
//   }
//   return Row(
//     children: sections,
//   );
// }
}
