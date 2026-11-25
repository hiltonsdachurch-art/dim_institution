import 'package:flutter/material.dart';

class LikertScaleWidget extends StatelessWidget {
  final String questionText;
  final int? selectedScore; // -3 to +3 (null if unselected)
  final ValueChanged<int> onScoreSelected;

  const LikertScaleWidget({
    super.key,
    required this.questionText,
    required this.selectedScore,
    required this.onScoreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedScore != null
              ? const Color(0xFFD4AF37).withOpacity(0.4)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          // Question Statement
          Text(
            questionText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // 7-Point Circle Gradient
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "AGREE",
                style: TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 14),

              // +3: Strongly Agree (Large Green)
              _buildCircle(score: 3, size: 36, color: const Color(0xFF10B981)),
              const SizedBox(width: 10),

              // +2: Agree (Medium Green)
              _buildCircle(score: 2, size: 28, color: const Color(0xFF34D399)),
              const SizedBox(width: 10),

              // +1: Slightly Agree (Small Green)
              _buildCircle(score: 1, size: 22, color: const Color(0xFF6EE7B7)),
              const SizedBox(width: 10),

              // 0: Neutral (Gray)
              _buildCircle(score: 0, size: 18, color: Colors.white38),
              const SizedBox(width: 10),

              // -1: Slightly Disagree (Small Purple)
              _buildCircle(score: -1, size: 22, color: const Color(0xFFC084FC)),
              const SizedBox(width: 10),

              // -2: Disagree (Medium Purple)
              _buildCircle(score: -2, size: 28, color: const Color(0xFFA855F7)),
              const SizedBox(width: 10),

              // -3: Strongly Disagree (Large Purple)
              _buildCircle(score: -3, size: 36, color: const Color(0xFF9333EA)),
              const SizedBox(width: 14),

              const Text(
                "DISAGREE",
                style: TextStyle(
                  color: Color(0xFFA855F7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircle({
    required int score,
    required double size,
    required Color color,
  }) {
    final bool isSelected = selectedScore == score;

    return InkWell(
      onTap: () => onScoreSelected(score),
      borderRadius: BorderRadius.circular(size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: isSelected ? size + 6 : size,
        height: isSelected ? size + 6 : size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? color : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.white : color.withOpacity(0.6),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
      ),
    );
  }
}