import 'dart:math';
import 'package:flutter/material.dart';
import 'package:apex_dart/apex_dart.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'dart:html' as html;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApexController lineChartController = ApexController();

  final Debouncer _debouncer = Debouncer();
  bool isLoading = true;

  bool showOverLayOnGraph = true;

  void onOverlayDebounce(bool value) {
    _debouncer.debounce(
      duration: const Duration(milliseconds: 1000),
      onDebounce: () {
        updateOverLayState(value);
      },
    );
  }

  void updateOverLayState(bool value) {
    setState(() {
      showOverLayOnGraph = value;
    });
  }

  onStartScroll() async {
    print("${DateTime.now()} Flutter Scroll Start");
    updateOverLayState(true);
  }

  onUpdateScroll() {
    print("${DateTime.now()} Flutter Scroll Update");
  }

  onEndScroll() async {
    print("${DateTime.now()} Flutter Scroll End");
    onOverlayDebounce(false);
  }

  @override
  void initState() {
    super.initState();
    // Add event listener to handle messages from iframes
    html.window.addEventListener('message', _handleMessage);
  }

  @override
  void dispose() {
    // Remove event listener to avoid memory leaks
    html.window.removeEventListener('message', _handleMessage);
    super.dispose();
  }

  void _handleMessage(html.Event event) {
    final message = event as html.MessageEvent;
    if (message.data['type'] == 'scroll_start') {
      print('Scroll started inside iframe');
      onStartScroll();
      // Handle scroll start as needed
    } else if (message.data['type'] == 'scroll_end') {
      print('Scroll ended inside iframe');
      onEndScroll();
      // Handle scroll end as needed
    } else if (message.data['type'] == 'scroll_direction') {
      final direction = message.data['direction'];
      print('Scroll direction inside iframe: $direction');
      setState(() {
        // scrollDirection = direction;
      });
    } else if (message.data['type'] == 'scroll_top_attempt') {
      print('User attempted to scroll beyond the top of the iframe');
      onStartScroll();
      // Handle scroll top attempt as needed
    } else if (message.data['type'] == 'scroll_bottom_attempt') {
      print('User attempted to scroll beyond the bottom of the iframe');
      onStartScroll();
      // Handle scroll bottom attempt as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Apex Dart example app'),
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollStartNotification) {
                onStartScroll();
              } else if (scrollNotification is ScrollUpdateNotification) {
                onUpdateScroll();
              } else if (scrollNotification is ScrollEndNotification) {
                onEndScroll();
              }
              return true;
            },
            child: SingleChildScrollView(
              controller: ScrollController(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 200),
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 100),
                        width: double.infinity,
                        child: ApexDart(
                          width: 800,
                          height: 450,
                          options: '''
                    {
          series: [{
            name: "Session Duration",
            data: [45, 52, 38, 24, 33, 26, 21, 20, 6, 8, 15, 10]
          },
          {
            name: "Page Views",
            data: [35, 41, 62, 42, 13, 18, 29, 37, 36, 51, 32, 35]
          },
          {
            name: 'Total Visits',
            data: [87, 57, 74, 99, 75, 38, 62, 47, 82, 56, 45, 47]
          }
        ],
          chart: {
          height: 350,
          type: 'line',
          zoom: {
            enabled: true
          },
        },
        dataLabels: {
          enabled: false
        },
        stroke: {
          width: [5, 7, 5],
          curve: 'straight',
          dashArray: [0, 8, 5]
        },
        title: {
          text: 'Page Statistics',
          align: 'left'
        },
        legend: {
          tooltipHoverFormatter: function(val, opts) {
            return val + ' - <strong>' + opts.w.globals.series[opts.seriesIndex][opts.dataPointIndex] + '</strong>'
          }
        },
        markers: {
          size: 0,
          hover: {
            sizeOffset: 6
          }
        },
        xaxis: {
          categories: ['01 Jan', '02 Jan', '03 Jan', '04 Jan', '05 Jan', '06 Jan', '07 Jan', '08 Jan', '09 Jan',
            '10 Jan', '11 Jan', '12 Jan'
          ],
        },
        tooltip: {
          y: [
            {
              title: {
                formatter: function (val) {
                  return val + " (mins)"
                }
              }
            },
            {
              title: {
                formatter: function (val) {
                  return val + " per session"
                }
              }
            },
            {
              title: {
                formatter: function (val) {
                  return val;
                }
              }
            }
          ]
        },
        grid: {
          borderColor: '#f1f1f1',
        }
        }''',
                          onPageFinished: (src) async {
                            await Future.delayed(const Duration(milliseconds: 800));
                            setState(() {
                              isLoading = false;
                            });
                          },
                        ),
                      ),
                      Visibility(
                        visible: showOverLayOnGraph,
                        child: PointerInterceptor(
                          child: InkWell(
                            onTap: () {
                              updateOverLayState(false);
                            },
                            child: Container(
                              color: Colors.orange.withOpacity(0.3),
                              width: double.infinity,
                              height: 400,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isLoading,
                        child: Positioned.fill(
                          child: Container(
                            color: Colors.blue,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                        const SizedBox(height: 50),
                        Stack(
                          children: [
                            Container(
                              height: 400,
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 100),
                              child: const ApexDart(options: '''{
                  series: [{
                  name: 'PRODUCT A',
                  data: [44, 55, 41, 67, 22, 43]
                          }, {
                  name: 'PRODUCT B',
                  data: [13, 23, 20, 8, 13, 27]
                          }, {
                  name: 'PRODUCT C',
                  data: [11, 17, 15, 15, 21, 14]
                          }, {
                  name: 'PRODUCT D',
                  data: [21, 7, 25, 13, 22, 8]
                          }],
                  chart: {
                  type: 'bar',
                  height: 350,
                  stacked: true,
                  toolbar: {
                    show: true
                  },
                  zoom: {
                    enabled: true
                  }
                          },
                          responsive: [{
                  breakpoint: 480,
                  options: {
                    legend: {
                      position: 'bottom',
                      offsetX: -10,
                      offsetY: 0
                    }
                  }
                          }],
                          plotOptions: {
                  bar: {
                    horizontal: false,
                    borderRadius: 10,
                    borderRadiusApplication: 'end', // 'around', 'end'
                    borderRadiusWhenStacked: 'last', // 'all', 'last'
                    dataLabels: {
                      total: {
                        enabled: true,
                        style: {
                          fontSize: '13px',
                          fontWeight: 900
                        }
                      }
                    }
                  },
                          },
                          xaxis: {
                  type: 'datetime',
                  categories: ['01/01/2011 GMT', '01/02/2011 GMT', '01/03/2011 GMT', '01/04/2011 GMT',
                    '01/05/2011 GMT', '01/06/2011 GMT'
                  ],
                          },
                          legend: {
                  position: 'right',
                  offsetY: 40
                          },
                          fill: {
                  opacity: 1
                          }
                          }'''),
                            ),
                            Visibility(
                              visible: showOverLayOnGraph,
                              child: PointerInterceptor(
                                child: InkWell(
                                  onTap: () {
                                    updateOverLayState(false);
                                  },
                                  child: Container(
                                    height: 400,
                                    color: Colors.orange.withOpacity(0.3),
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 50),
                        Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 500,
                                height: 500,
                                // padding: EdgeInsets.symmetric(horizontal: 200),
                                child: ApexDart(
                                  options: '''{
                  series: [44, 55, 41, 17, 15],
                  chart: {
                  type: 'donut',
                          },
                          responsive: [{
                  breakpoint: 480,
                  options: {
                    chart: {
                      width: 200
                    },
                    legend: {
                      position: 'bottom'
                    }
                  }
                          }]
                          }''',
                                ),
                              ),
                            ),
                            Visibility(
                              visible: showOverLayOnGraph,
                              child: PointerInterceptor(
                                child: InkWell(
                                  onTap: () {
                                    updateOverLayState(false);
                                  },
                                  child: Container(
                                    color: Colors.orange.withOpacity(0.3),
                                    width: double.infinity,
                                    height: 500,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              lineChartController.adjustViewHeight();

              // lineChartController.downloadSvg();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  int _rand([int next = 100]) => Random().nextInt(next);

  List<int> randomizeData() => List.generate(10, (index) => _rand());
}
