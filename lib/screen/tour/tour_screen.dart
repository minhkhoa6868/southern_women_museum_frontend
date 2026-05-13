import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';
import '../map/widgets/shared_floor_maps.dart'; // Ensure this path is correct
import '../quiz/quiz_entry_screen.dart';

class TourStep {
  final String title;
  final String subtitle;
  final String description;
  final String floor;
  final String location;
  final IconData icon;
  final bool isGF;
  final Offset dotPosition;

  TourStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.floor,
    required this.location,
    required this.icon,
    required this.isGF,
    required this.dotPosition,
  });
}

class TourScreen extends StatefulWidget {
  const TourScreen({
    super.key,
    required this.roomId,
    required this.userId,
  });

  final String roomId;
  final String userId;

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  int _currentStep = 0;

  final List<TourStep> _steps = [
    TourStep(
      title: 'Welcome to the Museum',
      subtitle: 'GO STRAIGHT',
      description: 'You are at the Entrance of the Museum. Walk straight ahead to take the stairs to the First floor. You can stop by the information booth on the right for questions or request a human tour guide. ',
      floor: 'Ground Floor',
      location: 'Entrance Way',
      icon: Icons.arrow_upward_rounded,
      isGF: true,
      dotPosition: const Offset(215, 185), 
    ),
    TourStep(
      title: 'Take the Grand Staircase',
      subtitle: 'GO UPSTAIRS',
      description: 'Head toward the right side at the end of the pathway and ascend the Grand Staircase to reach the 1st Floor. Hold the wooden railing as you climb.',
      floor: 'Ground Floor',
      location: 'Main Lobby',
      icon: Icons.stairs_rounded,
      isGF: true,
      dotPosition: const Offset(315, 150),
    ),
    TourStep(
      title: 'Visit the Ao Dai Gallery',
      subtitle: 'GO STRAIGHT',
      description: 'At the top of the stairs, go straight ahead and visit the Ao Dai Gallery. Explore the evolution of this traditional Vietnamese outfit throughout many historical periods.',
      floor: '1st Floor',
      location: 'Ao Dai Gallery',
      icon: Icons.arrow_upward_rounded,
      isGF: false,
      dotPosition: const Offset(220, 155),
    ),
    TourStep(
      title: 'Exit & Follow the Hallway',
      subtitle: 'TURN RIGHT',
      description: 'Exit the Ao Dai Gallery through the main door. Turn right into the connecting hallway on the 1st floor. You can briefly view the Vo Thi Sau street through the open space.',
      floor: '1st Floor',
      location: 'First Floor Hallway',
      icon: Icons.turn_right_rounded,
      isGF: false,
      dotPosition: const Offset(135, 125),
    ),
    TourStep(
      title: 'Visit the Ceramic Gallery',
      subtitle: 'GO STRAIGHT',
      description: 'Continue to the far end of the hallway and enter the Ceramic Gallery on your right. Marvel at the process of making ceramics, pottery and other earthwork products spanning over thousands of years.',
      floor: '1st Floor',
      location: 'Ceramic Gallery',
      icon: Icons.arrow_upward_rounded,
      isGF: false,
      dotPosition: const Offset(85, 105),
    ),
    TourStep(
      title: 'Return to the Ground Floor',
      subtitle: 'GO DOWNSTAIRS',
      description: 'Exit the Ceramic Gallery and turn right. Take the  staircase back down to the Ground Floor. Watch your step on the way down.',
      floor: '1st Floor',
      location: 'First Floor Hallway',
      icon: Icons.stairs_rounded,
      isGF: false,
      dotPosition: const Offset(25, 80),
    ),
    TourStep(
      title: 'Visit the Weaving Gallery',
      subtitle: 'GO STRAIGHT',
      description: 'At the bottom of the stairs, turn left. The Weaving Gallery is right next to the staircase on the Ground Floor. Step into the historic beauty of traditional woven craft of Ma ethnic women from Dong Nai province.',
      floor: 'Ground Floor',
      location: 'Weaving Gallery',
      icon: Icons.arrow_upward_rounded,
      isGF: true,
      dotPosition: const Offset(30, 85),
    ),
    TourStep(
      title: 'Tour Complete!',
      subtitle: 'TOUR COMPLETE',
      description: 'Congratulations! You\'ve completed the full museum tour at Southern Women\'s Museum. We hope these extraordinary artifacts have transported you through time. Take the quiz to test your memory of what you\'ve seen at the museum.',
      floor: 'Ground Floor',
      location: 'Museum Lobby',
      icon: Icons.check_circle_outline_rounded,
      isGF: true,
      dotPosition: const Offset(260, 185),
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _takeQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizEntryScreen(
          roomId: widget.roomId,
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primaryLightTheme;
    final textColor = isDark ? AppColors.textDarkTheme : AppColors.textLightTheme;
    final accent = isDark ? AppColors.accentDarkTheme : AppColors.accentLightTheme;
    final surface = isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLightTheme;
    
    final currentTourStep = _steps[_currentStep];
    
    // Determine the color for the currently active instruction card
    final isFinalStep = _currentStep == _steps.length - 1;
    final activeThemeColor = isFinalStep ? accent : primary;

    return Scaffold(
      backgroundColor: surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(15, 40, 15, 15),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: textColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.explore_rounded, color: primary, size: 28),
                      const SizedBox(width: 10),
                      Text('Tour Guide', style: AppTextStyles.h3(textColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Follow the guided tour through all ${_steps.length} steps. Tap on any gallery room to view artifacts.',
                    style: AppTextStyles.p(textColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // PROGRESS BAR & NAVIGATION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _currentStep > 0 ? _prevStep : null,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentStep > 0 
                                ? textColor.withValues(alpha: 0.08) 
                                : textColor.withValues(alpha: 0.03),
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded, 
                            size: 28,
                            color: _currentStep > 0 ? textColor.withValues(alpha: 0.8) : textColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      Text(
                        'Step ${_currentStep + 1} of ${_steps.length}',
                        style: AppTextStyles.h5(textColor).copyWith(fontWeight: FontWeight.w600),
                      ),
                      // if (_currentStep == _steps.length - 1)
                      //   // Take Quiz button on last step
                      //   ElevatedButton.icon(
                      //     onPressed: _takeQuiz,
                      //     icon: const Icon(Icons.quiz_rounded, size: 20),
                      //     label: const Text(
                      //       'Take Quiz',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 14,
                      //       ),
                      //     ),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: accent,
                      //       foregroundColor: Colors.white,
                      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //     ),
                      //   )
                      // else
                        // Next button for other steps
                        InkWell(
                          onTap: _currentStep < _steps.length - 1 ? _nextStep : null,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentStep < _steps.length - 1 
                                  ? primary.withValues(alpha: 0.15) 
                                  : textColor.withValues(alpha: 0.03),
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded, 
                              size: 28,
                              color: _currentStep < _steps.length - 1 ? primary : textColor.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(_steps.length, (index) {
                      final isActive = index <= _currentStep;
                      // Use accent for the progress bar if it's the final step and it's active
                      final barColor = (isActive && index == _steps.length - 1) ? accent : primary;
                      
                      return Expanded(
                        child: Container(
                          height: 6,
                          margin: EdgeInsets.only(right: index == _steps.length - 1 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: isActive ? barColor.withValues(alpha: 0.8) : textColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // MAP AREA
            Container(
              height: 220,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: SizedBox(
                  key: ValueKey<bool>(currentTourStep.isGF),
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: currentTourStep.isGF
                            ? GroundFloorMap(
                                textColor: primary, 
                                primary: primary,
                                accent: accent,
                              )
                            : FirstFloorMap(
                                textColor: primary,
                                primary: primary,
                                accent: accent,
                              ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        left: currentTourStep.dotPosition.dx - 8,
                        top: currentTourStep.dotPosition.dy - 8,
                        // Use activeThemeColor so the dot turns to accent on the final step
                        child: _GlowingDot(color: activeThemeColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // INSTRUCTION CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: activeThemeColor.withValues(alpha: 0.3)),
                            color: activeThemeColor.withValues(alpha: 0.1), // Colored background restored
                          ),
                          child: Icon(currentTourStep.icon, color: activeThemeColor, size: 28), // Colored icon restored
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTourStep.subtitle,
                                style: AppTextStyles.s2(textColor.withValues(alpha: 0.7)).copyWith(letterSpacing: 2.0),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentTourStep.title,
                                style: AppTextStyles.h4(textColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Divider(height: 1, color: primary.withValues(alpha: 0.15)),
                  
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      currentTourStep.description,
                      style: AppTextStyles.p(textColor).copyWith(
                        height: 1.5, 
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  Divider(height: 1, color: primary.withValues(alpha: 0.15)),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: textColor.withValues(alpha: 0.5)),
                        const SizedBox(width: 8),
                        Text(
                          currentTourStep.location, 
                          style: AppTextStyles.s1(textColor.withValues(alpha: 0.7)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: textColor.withValues(alpha: 0.2)),
                            color: textColor.withValues(alpha: 0.05),
                          ),
                          child: Text(
                            currentTourStep.floor.toUpperCase(),
                            style: AppTextStyles.s2(textColor.withValues(alpha: 0.8)).copyWith(letterSpacing: 1.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // TOUR ROUTE LIST
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: textColor.withValues(alpha: 0.15)),
                color: textColor.withValues(alpha: 0.02), // Slight background to pop the list container
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'TOUR ROUTE',
                      style: AppTextStyles.s1(textColor.withValues(alpha: 0.8)).copyWith(letterSpacing: 3.0),
                    ),
                  ),
                  
                  ...List.generate(_steps.length, (index) {
                    final step = _steps[index];
                    final isActive = index == _currentStep;
                    final isCompleted = index < _currentStep;
                    
                    // Specific color for the step in the list (accent if it's the last step)
                    final isLastListItem = index == _steps.length - 1;
                    final stepThemeColor = isLastListItem ? accent : primary;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _currentStep = index),
                      child: Column(
                        children: [
                          Divider(height: 1, color: textColor.withValues(alpha: 0.15)),
                          Container(
                            color: isActive ? stepThemeColor.withValues(alpha: 0.08) : Colors.transparent, // Active row highlight
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    // Colored background for active or completed states
                                    color: (isActive || isCompleted) ? stepThemeColor.withValues(alpha: 0.12) : Colors.transparent,
                                    border: Border.all(
                                      color: (isActive || isCompleted) ? stepThemeColor : textColor.withValues(alpha: 0.15),
                                      width: isActive ? 2 : 1, // Thicker border for currently active
                                    ),
                                  ),
                                  child: Center(
                                    child: isCompleted 
                                      ? Icon(Icons.check, size: 16, color: stepThemeColor)
                                      : Text(
                                          '${index + 1}',
                                          style: AppTextStyles.s1(
                                            (isActive || isCompleted) ? stepThemeColor : textColor.withValues(alpha: 0.6)
                                          ).copyWith(fontWeight: isActive ? FontWeight.bold : FontWeight.w500),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.title,
                                        style: AppTextStyles.s1(textColor).copyWith(
                                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        step.floor,
                                        style: AppTextStyles.p(textColor.withValues(alpha: 0.5)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TOUR-SPECIFIC WIDGETS
// ============================================================================

class _GlowingDot extends StatelessWidget {
  final Color color;

  const _GlowingDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.9), // Solid core
        boxShadow: [
          // Inner bright glow
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 4,
          ),
          // Outer soft halo
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 10,
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
    );
  }
}