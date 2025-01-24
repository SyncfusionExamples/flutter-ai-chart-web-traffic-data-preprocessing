import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Chart import.
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      home: const AIDataPreProcessing(),
    );
  }
}

///Renders default Line series Chart.
class AIDataPreProcessing extends StatefulWidget {
  const AIDataPreProcessing({super.key});

  @override
  AIDataPreProcessingState createState() => AIDataPreProcessingState();
}

class AIDataPreProcessingState extends State<AIDataPreProcessing>
    with SingleTickerProviderStateMixin {
  AIDataPreProcessingState();

  late List<_WebTraffic> _webTrafficData;
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  final String _apiKey = '';

  @override
  void initState() {
    _webTrafficData = _generateWebTrafficData();
    super.initState();
  }

  // Note: For data preprocessing, some values in the web traffic dataset have
  // been intentionally set to null.
  List<_WebTraffic> _generateWebTrafficData() {
    return <_WebTraffic>[
      _WebTraffic(DateTime(2020, 1, 25, 00, 30), 273),
      _WebTraffic(DateTime(2020, 1, 25, 01, 30), 75),
      _WebTraffic(DateTime(2020, 1, 25, 02, 30), 193),
      _WebTraffic(DateTime(2020, 1, 25, 03, 30), null),
      _WebTraffic(DateTime(2020, 1, 25, 04, 30), 53),
      _WebTraffic(DateTime(2020, 1, 25, 05, 30), 156),
      _WebTraffic(DateTime(2020, 1, 25, 06, 30), 98),
      _WebTraffic(DateTime(2020, 1, 25, 07, 30), 291),
      _WebTraffic(DateTime(2020, 1, 25, 08, 30), null),
      _WebTraffic(DateTime(2020, 1, 25, 09, 30), 1020),
      _WebTraffic(DateTime(2020, 1, 25, 10, 30), 1155),
      _WebTraffic(DateTime(2020, 1, 25, 11, 30), null),
      _WebTraffic(DateTime(2020, 1, 25, 12, 30), 1484),
      _WebTraffic(DateTime(2020, 1, 25, 13, 30), 770),
      _WebTraffic(DateTime(2020, 1, 25, 14, 30), null),
      _WebTraffic(DateTime(2020, 1, 25, 15, 30), 990),
      _WebTraffic(DateTime(2020, 1, 25, 16, 30), 730),
      _WebTraffic(DateTime(2020, 1, 25, 17, 30), 1105),
      _WebTraffic(DateTime(2020, 1, 25, 18, 30), null),
      _WebTraffic(DateTime(2020, 1, 25, 19, 30), 645),
      _WebTraffic(DateTime(2020, 1, 25, 20, 30), 1038),
      _WebTraffic(DateTime(2020, 1, 25, 21, 30), 1163),
      _WebTraffic(DateTime(2020, 1, 25, 22, 30), 78),
      _WebTraffic(DateTime(2020, 1, 25, 23, 30), null),
    ];
  }

  /// Builds the circular progress indicator while updating the predicted data.
  Widget _buildCircularProgressIndicator() {
    return ValueListenableBuilder(
      valueListenable: _isLoadingNotifier,
      builder: (BuildContext context, bool value, Widget? child) {
        return Visibility(
          visible: _isLoadingNotifier.value,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<void> _loadNewData() async {
    if (_apiKey.isEmpty || !mounted) return;

    // Sets the loading state for asynchronous operations.
    if (mounted) {
      setState(() {
        _isLoadingNotifier.value = true;
      });
    }

    // Refresh data source for every button click.
    _webTrafficData = _generateWebTrafficData();

    await Future.delayed(const Duration(seconds: 2));
    final String prompt = _generatePrompt();
    _sendAIChatMessage(prompt, _apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            _buildCartesianChart(),
            _buildCircularProgressIndicator(),
            _buildAIButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the customized AI prediction button.
  Widget _buildAIButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 30, 20, 0),
        child: Tooltip(
          message: 'Data preprocessing',
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: _AIButton(
            onPressed: () {
              _loadNewData();
            },
          ),
        ),
      ),
    );
  }

  /// Return the Cartesian Chart with Spline series.
  SfCartesianChart _buildCartesianChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0.1,
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.top,
      ),
      title: ChartTitle(
        text: 'AI-Powered Website Traffic Analytics with Data Preprocessing',
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      primaryXAxis: DateTimeAxis(
        minimum: DateTime(2020, 1, 25, 00, 00),
        maximum: DateTime(2020, 1, 25, 24, 00),
        interval: 1,
        dateFormat: DateFormat().add_H(),
        majorGridLines: const MajorGridLines(
          dashArray: [8, 8],
          width: 0.8,
        ),
        title: AxisTitle(
          text: 'Time during 25th January 2020',
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          if (args.value == 1579977000000) {
            return ChartAxisLabel('24', args.textStyle);
          }
          return ChartAxisLabel(args.text, args.textStyle);
        },
      ),
      primaryYAxis: const NumericAxis(
        minimum: 0,
        maximum: 1600,
        interval: 200,
        majorGridLines: MajorGridLines(width: 0),
        title: AxisTitle(
          text: 'Traffic Count',
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      onMarkerRender: (MarkerRenderArgs args) {
        // Set series color as marker color.
        args.color = args.borderColor;
        // Improve UI setting the white for marker border.
        args.borderColor = Colors.white;
      },
      onTrackballPositionChanging: (TrackballArgs args) {
        if (args.chartPointInfo.chartPoint != null) {
          args.chartPointInfo.chartPoint!.color = args.chartPointInfo.color;
        }
      },
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipSettings: InteractiveTooltip(
          arrowWidth: 0,
          arrowLength: 0,
        ),
        markerSettings: TrackballMarkerSettings(
          markerVisibility: TrackballVisibilityMode.visible,
          borderWidth: 2.5,
        ),
        builder: (BuildContext context, TrackballDetails trackballDetails) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade100,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: trackballDetails.point!.color!,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Time Stamp : ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('DD-MM-yyyy HH:mm:ss')
                                .format(trackballDetails.point!.x),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Traffic Count : ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${trackballDetails.point!.y}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      series: _buildSpLineSeries(),
    );
  }

  /// Returns the list of Cartesian Line series.
  List<SplineSeries<_WebTraffic, DateTime>> _buildSpLineSeries() {
    return <SplineSeries<_WebTraffic, DateTime>>[
      SplineSeries<_WebTraffic, DateTime>(
        dataSource: _webTrafficData,
        xValueMapper: (_WebTraffic data, int index) => data.timeStamp,
        yValueMapper: (_WebTraffic data, int index) => data.trafficCount,
        pointColorMapper: (_WebTraffic data, int index) => data.color,
        animationDuration: 0,
        legendItemText: 'Web traffic',
        markerSettings: MarkerSettings(isVisible: true),
      ),
    ];
  }

  String _generatePrompt() {
    final String rules =
        'Only include values in the yyyy-MM-dd-HH-m-ss:Value format,'
        'and ensure they strictly adhere to this format without any additional explanations.'
        'Unwanted content should be strictly avoided.';

    final String data = _webTrafficData
        .map((d) =>
            "${DateFormat('yyyy-MM-dd-HH-m-ss').format(d.timeStamp)}: ${d.trafficCount}")
        .join('\n');

    final String prompt =
        'Clean the following traffic data and fill in any missing values:\n$data\n'
        'The cleaned output should strictly follow the yyyy-MM-dd-HH-m-ss:Value format.\n$rules';

    return prompt;
  }

  List<_WebTraffic> _convertAIResponseToChartData(String? data) {
    if (data == null || data.isEmpty) {
      return [];
    }

    int count = 0;
    Color? color;
    final List<_WebTraffic> aiData = [];
    final int webTrafficDataLength = _webTrafficData.length;
    for (final line in data.split('\n')) {
      final parts = line.split(':');
      if (parts.length == 2) {
        try {
          final date = DateFormat('yyyy-MM-dd-HH-m-ss').parse(parts[0].trim());
          final visitors = double.tryParse(parts[1].trim());
          if (visitors != null) {
            final bool isCurrDataNull =
                _webTrafficData[count].trafficCount == null;
            final bool isNextDataNull = count + 1 < webTrafficDataLength &&
                _webTrafficData[count + 1].trafficCount == null;
            color = isCurrDataNull || isNextDataNull
                ? const Color(0xFFD84227)
                : Colors.blue;
            aiData.add(_WebTraffic(date, visitors, color));
            count = count + 1;
          }
        } catch (e) {
          // Handle catch
        }
      }
    }

    return aiData;
  }

  /// Sends the created prompt to the Google AI.
  /// Converts the response into chart data.
  Future<void> _sendAIChatMessage(String prompt, String apiKey) async {
    try {
      final GenerativeModel model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey, // Replace your api key here.
      );
      final ChatSession chat = model.startChat();
      final GenerateContentResponse response = await chat.sendMessage(
        Content.text(prompt),
      );

      _webTrafficData = _convertAIResponseToChartData(response.text);

      setState(() {
        _isLoadingNotifier.value = false;
      });
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Some error has been occurred $error'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _isLoadingNotifier.dispose();
    _webTrafficData.clear();
    super.dispose();
  }
}

class _AIButton extends StatefulWidget {
  const _AIButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  State<_AIButton> createState() => _AIButtonState();
}

class _AIButtonState extends State<_AIButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isPressed = false; // Track the pressed state.

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _isPressed ? 1 : _animation.value,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              iconColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(10),
            ),
            onPressed: () {
              setState(() {
                _isPressed = !_isPressed; // Toggle the pressed state
              });
              widget.onPressed();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Image.asset(
                  'assets/ai_assist_view.png',
                  height: 30,
                  width: 30,
                  color: Colors.white,
                ),
                const Text(
                  'Generate AI Data',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _isPressed = false;
    super.dispose();
  }
}

class _WebTraffic {
  _WebTraffic(this.timeStamp, this.trafficCount, [this.color]);

  final DateTime timeStamp;
  final double? trafficCount;
  Color? color;
}
