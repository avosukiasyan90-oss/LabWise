import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/lab_marker.dart';
import '../models/medical_report.dart';
import '../models/user_profile.dart';
import '../models/wellness_plan.dart';

/// Builds a personalized daily plan from the user's profile and the markers
/// flagged in their recent reports.
///
/// The logic is deterministic and runs on-device, so the plan is available
/// offline and never sends health data anywhere.
class WellnessPlanner {
  const WellnessPlanner();

  WellnessPlan build({
    required AppL10n l10n,
    required UserProfile profile,
    List<MedicalReport> reports = const [],
  }) {
    final missing = <String>[
      if (profile.weightKg == null) l10n.fieldWeightLower,
      if (profile.heightCm == null) l10n.fieldHeightLower,
      if (profile.age == null) l10n.fieldAgeLower,
    ];

    if (profile.weightKg == null || profile.heightCm == null) {
      return WellnessPlan(
        isPersonalized: false,
        missingFields: missing,
        headline: l10n.planHeadlineFallback,
      );
    }

    final weight = profile.weightKg!;
    final height = profile.heightCm!;
    final age = profile.age ?? 35;
    final bmi = weight / ((height / 100) * (height / 100));

    final calories = _dailyCalories(weight: weight, height: height, age: age);
    final steps = _stepGoal(bmi: bmi, age: age);
    final water = double.parse((weight * 0.033).toStringAsFixed(1));
    final window = _eatingWindow(bmi);

    return WellnessPlan(
      isPersonalized: true,
      missingFields: missing,
      headline: _headline(l10n, profile.firstName, bmi),
      bmi: double.parse(bmi.toStringAsFixed(1)),
      bmiLabel: _bmiLabel(l10n, bmi),
      dailyCalories: calories,
      waterLitres: water,
      stepGoal: steps,
      eatingWindow: '${window.$1} – ${window.$2}',
      mealWindows: _meals(l10n, bmi: bmi, start: window.$1, end: window.$2),
      activities: _activities(l10n, bmi: bmi, age: age),
      habits: _habits(l10n, bmi: bmi, age: age, water: water),
      reportNotes: _reportNotes(l10n, reports),
    );
  }

  String _headline(AppL10n l10n, String firstName, double bmi) {
    final who = firstName.isEmpty ? l10n.planWhoFallback : firstName;
    if (bmi < 18.5) return l10n.planHeadlineUnder(who);
    if (bmi < 25) return l10n.planHeadlineHealthy(who);
    if (bmi < 30) return l10n.planHeadlineAbove(who);
    return l10n.planHeadlineWellAbove(who);
  }

  String _bmiLabel(AppL10n l10n, double bmi) {
    if (bmi < 18.5) return l10n.bmiUnder;
    if (bmi < 25) return l10n.bmiHealthy;
    if (bmi < 30) return l10n.bmiAbove;
    return l10n.bmiWellAbove;
  }

  /// Mifflin-St Jeor, averaged across sexes since we do not collect sex,
  /// then scaled for a lightly active day.
  int _dailyCalories({
    required double weight,
    required double height,
    required int age,
  }) {
    final bmr = (10 * weight) + (6.25 * height) - (5 * age) - 78;
    final maintenance = bmr * 1.45;
    final bmi = weight / ((height / 100) * (height / 100));

    final target = switch (bmi) {
      < 18.5 => maintenance + 300,
      < 25 => maintenance,
      < 30 => maintenance - 350,
      _ => maintenance - 500,
    };
    // Round to the nearest 50 so the number reads like guidance, not a lab value.
    return ((target / 50).round() * 50).clamp(1200, 4000).toInt();
  }

  int _stepGoal({required double bmi, required int age}) {
    var goal = 8000;
    if (bmi >= 25) goal = 9000;
    if (bmi >= 30) goal = 7000;
    if (age >= 60) goal -= 1000;
    if (age <= 30 && bmi < 30) goal += 1000;
    return goal.clamp(5000, 12000);
  }

  (String, String) _eatingWindow(double bmi) {
    if (bmi >= 30) return ('09:00', '19:00');
    if (bmi >= 25) return ('08:30', '19:30');
    if (bmi < 18.5) return ('07:30', '21:30');
    return ('08:00', '20:00');
  }

  List<MealWindow> _meals(
    AppL10n l10n, {
    required double bmi,
    required String start,
    required String end,
  }) {
    final meals = <MealWindow>[
      MealWindow(
        time: start,
        title: l10n.mealBreakfast,
        idea: l10n.mealBreakfastIdea,
        icon: Icons.wb_twilight_rounded,
      ),
      MealWindow(
        time: '13:00',
        title: l10n.mealLunch,
        idea: l10n.mealLunchIdea,
        icon: Icons.lunch_dining_outlined,
      ),
    ];

    if (bmi < 18.5) {
      meals.add(
        MealWindow(
          time: '16:30',
          title: l10n.mealSnack,
          idea: l10n.mealSnackIdea,
          icon: Icons.cookie_outlined,
        ),
      );
    } else if (bmi < 25) {
      meals.add(
        MealWindow(
          time: '16:30',
          title: l10n.mealLightSnack,
          idea: l10n.mealLightSnackIdea,
          icon: Icons.apple_rounded,
        ),
      );
    }

    meals.add(
      MealWindow(
        time: bmi >= 25 ? '18:30' : '19:30',
        title: l10n.mealDinner,
        idea: bmi >= 25
            ? l10n.mealDinnerIdeaLight
            : l10n.mealDinnerIdeaBalanced,
        icon: Icons.dinner_dining_outlined,
      ),
    );

    meals.add(
      MealWindow(
        time: end,
        title: l10n.mealKitchenClosed,
        idea: l10n.mealKitchenClosedIdea,
        icon: Icons.nightlight_round,
      ),
    );

    return meals;
  }

  List<ActivityIdea> _activities(
    AppL10n l10n, {
    required double bmi,
    required int age,
  }) {
    final list = <ActivityIdea>[];

    if (bmi >= 30) {
      list.addAll([
        ActivityIdea(
          name: l10n.activityWalking,
          schedule: l10n.activityWalkingSchedule,
          why: l10n.activityWalkingWhy,
          icon: Icons.directions_walk_rounded,
        ),
        ActivityIdea(
          name: l10n.activitySwimming,
          schedule: l10n.activitySwimmingSchedule,
          why: l10n.activitySwimmingWhy,
          icon: Icons.pool_outlined,
        ),
        ActivityIdea(
          name: l10n.activityLightStrength,
          schedule: l10n.activityLightStrengthSchedule,
          why: l10n.activityLightStrengthWhy,
          icon: Icons.fitness_center_rounded,
        ),
      ]);
    } else if (bmi >= 25) {
      list.addAll([
        ActivityIdea(
          name: l10n.activityBriskWalk,
          schedule: l10n.activityBriskWalkSchedule,
          why: l10n.activityBriskWalkWhy,
          icon: Icons.directions_bike_rounded,
        ),
        ActivityIdea(
          name: l10n.activityStrength,
          schedule: l10n.activityStrengthSchedule2,
          why: l10n.activityStrengthWhyMuscle,
          icon: Icons.fitness_center_rounded,
        ),
        ActivityIdea(
          name: l10n.activityPostMeal,
          schedule: l10n.activityPostMealSchedule,
          why: l10n.activityPostMealWhy,
          icon: Icons.nordic_walking_rounded,
        ),
      ]);
    } else if (bmi < 18.5) {
      list.addAll([
        ActivityIdea(
          name: l10n.activityStrength,
          schedule: l10n.activityStrengthSchedule3,
          why: l10n.activityStrengthWhyGain,
          icon: Icons.fitness_center_rounded,
        ),
        ActivityIdea(
          name: l10n.activityEasyWalk,
          schedule: l10n.activityEasyWalkSchedule,
          why: l10n.activityEasyWalkWhy,
          icon: Icons.directions_walk_rounded,
        ),
      ]);
    } else {
      list.addAll([
        ActivityIdea(
          name: l10n.activityMixedCardio,
          schedule: l10n.activityMixedCardioSchedule,
          why: l10n.activityMixedCardioWhy,
          icon: Icons.directions_run_rounded,
        ),
        ActivityIdea(
          name: l10n.activityStrength,
          schedule: l10n.activityStrengthSchedule2,
          why: l10n.activityStrengthWhyBone,
          icon: Icons.fitness_center_rounded,
        ),
        ActivityIdea(
          name: l10n.activityEnjoy,
          schedule: l10n.activityEnjoySchedule,
          why: l10n.activityEnjoyWhy,
          icon: Icons.sports_soccer_rounded,
        ),
      ]);
    }

    if (age >= 60) {
      list.add(
        ActivityIdea(
          name: l10n.activityBalance,
          schedule: l10n.activityBalanceSchedule,
          why: l10n.activityBalanceWhy,
          icon: Icons.self_improvement_rounded,
        ),
      );
    }

    return list;
  }

  List<String> _habits(
    AppL10n l10n, {
    required double bmi,
    required int age,
    required double water,
  }) {
    return [
      l10n.habitWater(water.toString()),
      l10n.habitSleep,
      if (bmi >= 25) l10n.habitSugar,
      if (bmi < 18.5) l10n.habitFrequentMeals,
      if (age >= 50) l10n.habitCalcium,
      l10n.habitStand,
    ];
  }

  List<String> _reportNotes(AppL10n l10n, List<MedicalReport> reports) {
    final recent = reports.take(5);
    final flagged = <String>{};

    for (final report in recent) {
      for (final marker in report.markers) {
        if (!marker.isAbnormal) continue;
        final note = _noteForMarker(l10n, marker);
        if (note != null) flagged.add(note);
      }
    }

    return flagged.take(4).toList();
  }

  String? _noteForMarker(AppL10n l10n, LabMarker marker) {
    return switch (marker.id) {
      'ldl' || 'cholesterol' => l10n.noteCholesterol,
      'hdl' => l10n.noteHdl,
      'triglycerides' => l10n.noteTriglycerides,
      'glucose' || 'hba1c' => l10n.noteGlucose,
      'hemoglobin' => l10n.noteHemoglobin,
      'vitamin_d' => l10n.noteVitaminD,
      'tsh' => l10n.noteThyroid,
      'h_pylori' => l10n.noteHPylori,
      _ => null,
    };
  }
}
