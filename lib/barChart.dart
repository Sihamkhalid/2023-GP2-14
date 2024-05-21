import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample2 extends StatefulWidget {
   final String pid;
  BarChartSample2({super.key, required this.pid});
  final Color leftBarColor = Color.fromARGB(255, 0, 138, 237);
  final Color rightBarColor = AppColors.contentColorRed;
  final Color avgColor =
      AppColors.contentColorOrange.avg(AppColors.contentColorRed);
  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

extension ColorExtension on Color {
  /// Convert the color to a darken color based on the [percent]
  Color darken([int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * value).round(),
      (green * value).round(),
      (blue * value).round(),
    );
  }

  Color lighten([int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    final value = percent / 100;
    return Color.fromARGB(
      alpha,
      (red + ((255 - red) * value)).round(),
      (green + ((255 - green) * value)).round(),
      (blue + ((255 - blue) * value)).round(),
    );
  }

  Color avg(Color other) {
    final red = (this.red + other.red) ~/ 2;
    final green = (this.green + other.green) ~/ 2;
    final blue = (this.blue + other.blue) ~/ 2;
    final alpha = (this.alpha + other.alpha) ~/ 2;
    return Color.fromARGB(alpha, red, green, blue);
  }
}
// class AppAssets {
//   static String getChartIcon(ChartType type) {
//     switch (type) {
//       case ChartType.line:
//         return 'assets/icons/ic_line_chart.svg';
//       case ChartType.bar:
//         return 'assets/icons/ic_bar_chart.svg';
//       case ChartType.pie:
//         return 'assets/icons/ic_pie_chart.svg';
//       case ChartType.scatter:
//         return 'assets/icons/ic_scatter_chart.svg';
//       case ChartType.radar:
//         return 'assets/icons/ic_radar_chart.svg';
//     }
//   }

//   static const flChartLogoIcon = 'assets/icons/fl_chart_logo_icon.png';
//   static const flChartLogoText = 'assets/icons/fl_chart_logo_text.svg';
// }
class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}
class AppDimens {
  static const double menuMaxNeededWidth = 304;
  static const double menuRowHeight = 74;
  static const double menuIconSize = 32;
  static const double menuDocumentationIconSize = 44;
  static const double menuTextSize = 20;

  static const double chartBoxMinWidth = 350;

  static const double defaultRadius = 8;
  static const double chartSamplesSpace = 32.0;
  static const double chartSamplesMinWidth = 350;
}
class AppTexts {
  static const appName = 'FL Chart App';
}

class BarChartSample2State extends State<BarChartSample2> {
  final double width = 20;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 0, 5); // Value of 0.5
    final barGroup2 = makeGroupData(1, 0, 10);   // Value of 1
 final barGroup3 = makeGroupData(2, 0, 7);   // Extra bar with value 5

    final items = [barGroup1, barGroup2, barGroup3];  // Three groups

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
  }


  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          
            const SizedBox(
              height: 0,
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: 25,
                  
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 150,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: showingBarGroups,
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
           
          ],
        ),
      ),
    );
  }

 Widget leftTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Color(0xff7589a2),
    fontWeight: FontWeight.bold,
    fontSize: 17,
  );
  String text;
  if (value == 0) {
    text = '0';
  } else if (value == 5) {
    text = '0.5';
  } else if (value == 10) {
    text = '0.7';
  }  else if (value == 15) {
    text = '1';
  }
  else {
    return Container();
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 0,
    child: Text(text, style: style),
  );
}


  Widget bottomTitles(double value, TitleMeta meta) {
  final titles = <String>['IR', 'Abduction','EE'];

  if (value.toInt() >= 0 && value.toInt() < titles.length) {
    final text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10, //margin top
      child: text,
    );
  } else {
    return Container();
  }
}


 BarChartGroupData makeGroupData(int x, double y, double toy) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          fromY: y,
          color: widget.leftBarColor,
          width: width,
          toY: toy,
        ),
      ],
    );
  }



  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}