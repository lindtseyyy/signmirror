import 'package:flutter/material.dart';
import '../widgets//dynamic_bar_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        ), // Sets color for icons and text
      ),
      backgroundColor: Color(0xffF4F4F8),

      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 175,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xff2A2C41),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsGeometry.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DAILY CHALLENGE",
                            style: TextStyle(
                              color: Color(0xffF9A825),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Master the basics",
                            style: TextStyle(
                              color: Color(0xffffffff),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Complete 5 alphabet signs today",
                            style: TextStyle(
                              color: Color(0xffffffff).withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 20),
                          FilledButton(
                            onPressed: () {},

                            style: FilledButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.all(
                                  Radius.circular(10),
                                ),
                              ),
                              backgroundColor: Color(0xff2D68FF),
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            child: const Text(
                              "PRACTICE NOW",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  DynamicBarChart(
                    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                    data: [
                      [12, 18],
                      [10, 14],
                      [15, 9],
                      [11, 15],
                      [8, 12],
                      [20, 18],
                      [14, 16],
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    "STRUGGLED SIGN THIS WEEK",
                    style: TextStyle(
                      color: Color(0xff000000).withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 7),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        StruggledSign(
                          signTitle: "Good Morning",
                          percentage: 67,
                        ),
                        StruggledSign(signTitle: "Hospital", percentage: 39),
                        StruggledSign(signTitle: "Thank you", percentage: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Struggled Sign Widget
class StruggledSign extends StatelessWidget {
  final String signTitle;
  final int percentage;

  const StruggledSign({
    super.key,
    required this.signTitle,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xffffffff),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(1, 1), // Bottom-right shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(signTitle, style: TextStyle(fontWeight: FontWeight.w700)),
          Text(
            percentage.toString() + ("% Accurracy"),
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
