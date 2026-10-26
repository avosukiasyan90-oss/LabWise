import 'package:flutter/material.dart';

class MealWindow {
  const MealWindow({
    required this.time,
    required this.title,
    required this.idea,
    required this.icon,
  });

  final String time;
  final String title;
  final String idea;
  final IconData icon;
}

class ActivityIdea {
  const ActivityIdea({
    required this.name,
    required this.schedule,
    required this.why,
    required this.icon,
  });

  final String name;
  final String schedule;
  final String why;
  final IconData icon;
}

/// A personalized daily plan derived from the profile the user filled in.
class WellnessPlan {
  const WellnessPlan({
    required this.isPersonalized,
    required this.missingFields,
    required this.headline,
    this.bmi,
    this.bmiLabel,
    this.dailyCalories,
    this.waterLitres,
    this.stepGoal,
    this.eatingWindow,
    this.mealWindows = const [],
    this.activities = const [],
    this.habits = const [],
    this.reportNotes = const [],
  });

  /// False when the profile is too empty to compute anything useful.
  final bool isPersonalized;

  /// Human-readable profile fields still needed, e.g. "weight".
  final List<String> missingFields;

  final String headline;

  final double? bmi;
  final String? bmiLabel;
  final int? dailyCalories;
  final double? waterLitres;
  final int? stepGoal;

  /// e.g. "08:00 – 20:00"
  final String? eatingWindow;

  final List<MealWindow> mealWindows;
  final List<ActivityIdea> activities;
  final List<String> habits;

  /// Notes generated from markers that need attention in recent reports.
  final List<String> reportNotes;
}
