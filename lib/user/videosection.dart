import 'package:flutter/material.dart';
import 'package:gtech/user/zoom.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MainSection extends StatelessWidget {
  const MainSection({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 0,
              title: TabBar(
                labelStyle: TextStyle(
                  fontSize: isMobile ? 14 : screenWidth * 0.013,
                  fontWeight: FontWeight.w800,
                ),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                isScrollable: true,
                padding: EdgeInsets.zero,
                indicatorSize: TabBarIndicatorSize.label,
                labelPadding: const EdgeInsets.only(right: 16, left: 0),
                tabs: const [
                  Tab(text: "Course Content"),
                  Tab(text: "Priority Task"),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              const CourseContent(),
              const PriorityTask(),
            ],
          ),
        ),
      ),
    );
  }
}

// Course Content Section
class CourseContent extends StatefulWidget {
  const CourseContent({Key? key}) : super(key: key);

  @override
  State<CourseContent> createState() => _CourseContentState();
}

class _CourseContentState extends State<CourseContent> {
  List<bool> expandedStates = List.generate(8, (index) => false);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Video Lessons",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 18 : 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Unlock everything you need to become a pro!",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 8,
            itemBuilder: (ctx, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        expandedStates[index] = !expandedStates[index];
                      });
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircularPercentIndicator(
                                radius: isMobile ? 20 : 24,
                                lineWidth: isMobile ? 2 : 4,
                                percent: 0.8,
                                center: Text(
                                  "4/4",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                                progressColor: Colors.green,
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Module ${index + 1} - Ice breaking",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isMobile ? 14 : 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.tv,
                                          size: isMobile ? 14 : 16,
                                          color: Colors.blueAccent,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "4 Recorded Videos",
                                          style: TextStyle(
                                            fontSize: isMobile ? 12 : 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                expandedStates[index]
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: isMobile ? 20 : 24,
                              ),
                            ],
                          ),
                        ),
                        if (expandedStates[index])
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Column(
                              children: List.generate(3, (videoIndex) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                          size: isMobile ? 16 : 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Lesson ${videoIndex + 1} - Introduction",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: isMobile ? 12 : 14,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.tv,
                                                    size: isMobile ? 12 : 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Recorded Video",
                                                    style: TextStyle(
                                                      fontSize: isMobile ? 10 : 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Open video
                                          },
                                          child: const Text("View"),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Priority Task Section
