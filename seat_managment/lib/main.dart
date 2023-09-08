import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:seat_managment/select_time_data.dart';

import 'timeline_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Seat management'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final limit = 24;
  final LinkedScrollControllerGroup verticalLinkedController =
      LinkedScrollControllerGroup();
  final LinkedScrollControllerGroup horizontalLinkedController =
      LinkedScrollControllerGroup();
  late ScrollController seatScrollController;
  late ScrollController timeSlotController;

  late ScrollController timeScrollController;
  late ScrollController textScrollController;
  final List<ScrollController> timeSlotControllers = [];

  final Map<int, SelectTimeData> seatTimes = <int, SelectTimeData>{};

  @override
  void initState() {
    super.initState();
    // re-use controller when rebuild UI
    seatScrollController = verticalLinkedController.addAndGet();
    timeSlotController = verticalLinkedController.addAndGet();
    timeScrollController = horizontalLinkedController.addAndGet();
    textScrollController = horizontalLinkedController.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: LayoutBuilder(builder: (context, constraint) {
        return Column(
          children: [
            buildHeader(),
            Expanded(
              child: Row(
                children: [
                  _buildSeatNumber(),
                  Flexible(
                    child: _buildSeat(),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.amber,
          width: 100.0,
          height: 30.0,
          child: const Center(
            child: Text('Seat'),
          ),
        ),
        Expanded(
          child: TimeLineWidget(
            sectionSize: 100.0,
            limit: limit,
            scrollController: timeScrollController,
            textController: textScrollController,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatNumber() {
    return SizedBox(
      width: 100.0,
      child: ListView.builder(
        // keep listview
        key: const ObjectKey('seatScrollController'),
        controller: seatScrollController,
        itemCount: 100,
        itemBuilder: (context, index) {
          return buildContent(
            content: 'Seat $index',
            color:
                index % 2 == 0 ? Colors.amber.withOpacity(0.2) : Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildSeat() {
    return ListView.builder(
      controller: timeSlotController,
      itemCount: 100,
      itemBuilder: (context, index) {
        if (timeSlotControllers.isEmpty ||
            timeSlotControllers.length <= index) {
          timeSlotControllers.add(
            horizontalLinkedController.addAndGet(),
          );
        }
        final widgets = <Widget>[];
        for (var i = 0; i < limit; i++) {
          widgets.add(buildItem(
            index,
            i,
            color:
                index % 2 == 0 ? Colors.black.withOpacity(0.2) : Colors.white,
          ));
          widgets.add(Container(
            width: 1.0,
            color: Colors.black.withOpacity(0.1),
          ));
        }

        return SizedBox(
          height: 30.0,
          child: SingleChildScrollView(
            key: ObjectKey('$index'),
            scrollDirection: Axis.horizontal,
            controller: timeSlotControllers[index],
            child: Stack(
              children: [
                Row(
                  children: widgets,
                ),
                buildSelectLayer(index),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildItem(
    int seatIndex,
    int timeIndex, {
    String? content,
    Color? color,
  }) {
    return GestureDetector(
      onTapUp: (detail) {
        setState(() {
          final minute = calcPositionToTime(detail.localPosition.dx);
          seatTimes[seatIndex] = SelectTimeData(
            minute,
            timeIndex,
            minute * 100 / 60 + (101 * timeIndex),
          );
        });
      },
      child: buildContent(
        color: color,
        content: content,
      ),
    );
  }

  Widget buildContent({
    Color? color,
    String? content,
  }) {
    return Container(
      color: color,
      height: 30.0,
      width: 100.0,
      child: Center(
        child: Text(content ?? ''),
      ),
    );
  }

  int calcPositionToTime(double position) {
    final minute = position * 60 ~/ 100;
    return minute - (minute % 5);
  }

  Widget buildSelectLayer(int index) {
    if (seatTimes[index] == null) {
      return const SizedBox.shrink();
    }
    final timeData = seatTimes[index]!;
    return Container(
      margin: EdgeInsets.only(
        left: timeData.position.toDouble(),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            seatTimes.remove(index);
          });
        },
        child: Container(
          width: 200.0,
          height: 30.0,
          color: Colors.blue,
          child: Center(
            child: Text(
              genTimeContent(timeData),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String genTimeContent(SelectTimeData data) {
    if (data.minute < 10) {
      return '${data.timeIndex}:0${data.minute} - ${data.timeIndex + 2}:0${data.minute}';
    } else {
      return '${data.timeIndex}:${data.minute} - ${data.timeIndex + 2}:${data.minute}';
    }
  }

  @override
  void dispose() {
    seatScrollController.dispose();
    timeSlotController.dispose();
    timeScrollController.dispose();
    textScrollController.dispose();
    for (final controller in timeSlotControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
