// screens/comparison_screen.dart
// Side-by-side comparison table for up to three properties.
// Highlights best values in green, worst in red.

import 'package:flutter/material.dart';

class ComparisonScreen extends StatelessWidget {
  final List<Map<String, dynamic>> properties; // Must be 2–3 items

  const ComparisonScreen({super.key, required this.properties});

  // Metrics to compare
  final List<String> metrics = const [
    "value",
    "bedrooms",
    "bathrooms",
    "sqft",
    "year",
  ];

  final Map<String, String> metricLabels = const {
    "value": "Price",
    "bedrooms": "Bedrooms",
    "bathrooms": "Bathrooms",
    "sqft": "Sqft",
    "year": "Year Built",
  };

  // Determine best/worst for highlighting
  Map<String, dynamic> _metricStats(String metric) {
    final values = properties
        .map(
          (p) =>
              p[metric] is int ? p[metric] : int.tryParse("${p[metric]}") ?? 0,
        )
        .toList();

    int minVal = values.reduce((a, b) => a < b ? a : b);
    int maxVal = values.reduce((a, b) => a > b ? a : b);

    // For PRICE, GREEN = lower price = better value
    bool invert = metric == "value";

    return {
      "min": invert ? maxVal : minVal,
      "max": invert ? minVal : maxVal,
      "invert": invert,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Compare Properties")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade400, width: 0.8),
          columnWidths: {
            0: const FlexColumnWidth(1.4), // metric column
            1: const FlexColumnWidth(1),
            if (properties.length >= 2) 2: const FlexColumnWidth(1),
            if (properties.length == 3) 3: const FlexColumnWidth(1),
          },
          children: [
            // HEADER ROW: Titles
            TableRow(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Metric",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                for (var p in properties)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      p["title"] ?? "Listing",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),

            // METRIC ROWS
            for (var metric in metrics)
              _buildMetricRow(metric, _metricStats(metric)),
          ],
        ),
      ),
    );
  }

  TableRow _buildMetricRow(String metric, Map<String, dynamic> stats) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(metricLabels[metric] ?? metric),
        ),

        for (var p in properties)
          _buildMetricCell(metric: metric, value: p[metric], stats: stats),
      ],
    );
  }

  Widget _buildMetricCell({
    required String metric,
    required dynamic value,
    required Map<String, dynamic> stats,
  }) {
    if (value == null) value = 0;

    final numericValue = value is int
        ? value
        : int.tryParse(value.toString()) ?? 0;

    final minVal = stats["min"] as int;
    final maxVal = stats["max"] as int;

    Color? bg;

    if (numericValue == maxVal) {
      bg = Colors.green.withOpacity(.2); // Best
    } else if (numericValue == minVal) {
      bg = Colors.red.withOpacity(.2); // Worst
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: bg,
      child: Text(
        metric == "value" ? "\$$numericValue" : numericValue.toString(),
        textAlign: TextAlign.center,
      ),
    );
  }
}
