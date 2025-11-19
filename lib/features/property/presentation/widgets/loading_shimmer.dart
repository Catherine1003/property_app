import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';

class LoadingShimmer extends StatefulWidget {
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    Key? key,
    this.height = 200,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: const Offset(1, 0),
      ).animate(_animationController),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.surface,
              AppColors.border,
              AppColors.surface,
            ],
          ),
        ),
      ),
    );
  }
}