import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constant/app_design_system.dart';
import '../../painters/credential_painter.dart';
import '../../shapes/chamfer.dart';
import 'ascent_monogram.dart';

/// The Apex **athlete credential** — a premium, layered performance ID card that
/// headlines the trainee's Profile. It composes the [AscentMonogram] brand mark,
/// an engraved guilloché backdrop ([CredentialPainter]), a one-shot shine sweep,
/// a live "active" status pulse, and the athlete's identity block on the Apex
/// equipment-tag silhouette. Pure presentation — all copy is passed in already
/// localized.
class AthleteCredential extends StatefulWidget {
  final String overline;
  final String name;
  final String initial;
  final String athleteId;
  final String memberSince;
  final String? ageLabel;
  final String goalLabel;
  final bool active;
  final String statusLabel;

  const AthleteCredential({
    super.key,
    required this.overline,
    required this.name,
    required this.initial,
    required this.athleteId,
    required this.memberSince,
    required this.goalLabel,
    required this.active,
    required this.statusLabel,
    this.ageLabel,
  });

  @override
  State<AthleteCredential> createState() => _AthleteCredentialState();
}

class _AthleteCredentialState extends State<AthleteCredential>
    with SingleTickerProviderStateMixin {
  static const double _cut = 26;

  late final AnimationController _c;
  late final Animation<double> _rings;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _rings = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    _shine = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.35, 0.95, curve: Curves.easeInOut),
    );
    // Let the parent's staggered reveal land first, then animate the card.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 216.h,
      child: Stack(
        children: [
          // Backdrop: gradient + engraved texture + glow + chamfer border.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rings,
              builder: (_, _) => CustomPaint(
                painter: CredentialPainter(cut: _cut, t: _rings.value),
              ),
            ),
          ),
          // One-shot diagonal shine sweep, clipped to the silhouette.
          Positioned.fill(
            child: IgnorePointer(
              child: ClipPath(
                clipper: const ChamferClipper(cut: _cut),
                child: AnimatedBuilder(
                  animation: _shine,
                  builder: (_, _) {
                    final p = _shine.value;
                    final dx = -1.5 + 3.0 * p;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(dx - 0.35, -1),
                          end: Alignment(dx + 0.35, 1),
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.06 * (1 - (p - 0.5).abs() * 2).clamp(0.0, 1.0)),
                            Colors.white.withValues(alpha: 0),
                          ],
                          stops: const [0.4, 0.5, 0.6],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Content.
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDesignSystem.spacingLG.w,
              AppDesignSystem.spacingMD.h,
              AppDesignSystem.spacingLG.w,
              AppDesignSystem.spacingMD.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topRow(),
                const Spacer(),
                _identityRow(),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                Divider(
                  height: 1,
                  color: AppDesignSystem.borderColor,
                ),
                SizedBox(height: AppDesignSystem.spacingSM.h),
                _footerRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topRow() {
    return Row(
      children: [
        AscentMonogram(
          size: 30.w,
          background: AppDesignSystem.surfaceSunken,
        ),
        SizedBox(width: AppDesignSystem.spacingSM.w),
        Expanded(
          child: Text(
            widget.overline.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: AppDesignSystem.fontSizeSM.sp,
              fontWeight: AppDesignSystem.bold,
              letterSpacing: 2,
              color: AppDesignSystem.primaryStrong,
            ),
          ),
        ),
        _StatusChip(active: widget.active, label: widget.statusLabel),
      ],
    );
  }

  Widget _identityRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Medallion(initial: widget.initial),
        SizedBox(width: AppDesignSystem.spacingMD.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: AppDesignSystem.fontSize3XL.sp,
                  fontWeight: AppDesignSystem.extraBold,
                  height: 1.05,
                  letterSpacing: -0.5,
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                widget.athleteId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppDesignSystem.fontFamily,
                  fontSize: AppDesignSystem.fontSizeSM.sp,
                  fontWeight: AppDesignSystem.semiBold,
                  letterSpacing: 1.5,
                  color: AppDesignSystem.textMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _footerRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.memberSince.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: AppDesignSystem.fontSizeXS.sp,
              fontWeight: AppDesignSystem.semiBold,
              letterSpacing: 1.2,
              color: AppDesignSystem.textFaint,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _MetaChip(text: widget.goalLabel),
        if (widget.ageLabel != null) ...[
          SizedBox(width: AppDesignSystem.spacingXS.w),
          _MetaChip(text: widget.ageLabel!),
        ],
      ],
    );
  }
}

/// The initial "coin" — a chamfered Volt-tinted tile carrying the athlete's
/// initial, with a hairline border to read as embossed metal.
class _Medallion extends StatelessWidget {
  final String initial;
  const _Medallion({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.w,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppDesignSystem.primaryColor.withValues(alpha: 0.20),
            AppDesignSystem.primaryColor.withValues(alpha: 0.06),
          ],
        ),
        shape: ChamferBorder(
          cut: 14,
          side: BorderSide(
            color: AppDesignSystem.primaryColor.withValues(alpha: 0.55),
            width: 1.2,
          ),
        ),
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: AppDesignSystem.fontFamily,
          fontSize: AppDesignSystem.fontSize3XL.sp,
          fontWeight: AppDesignSystem.extraBold,
          color: AppDesignSystem.primaryStrong,
          height: 1,
        ),
      ),
    );
  }
}

/// A small metadata pill on the credential footer (goal / age).
class _MetaChip extends StatelessWidget {
  final String text;
  const _MetaChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignSystem.spacingSM.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceSunken.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
        border: Border.all(color: AppDesignSystem.borderColor),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          fontFamily: AppDesignSystem.fontFamily,
          fontSize: AppDesignSystem.fontSizeXS.sp,
          fontWeight: AppDesignSystem.bold,
          letterSpacing: 0.3,
          color: AppDesignSystem.textMuted,
        ),
      ),
    );
  }
}

/// "ACTIVE" status chip with a live pulsing dot.
class _StatusChip extends StatelessWidget {
  final bool active;
  final String label;

  const _StatusChip({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    final color =
        active ? AppDesignSystem.successColor : AppDesignSystem.textFaint;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignSystem.spacingSM.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active) _PulseDot(color: color) else _dot(color),
          SizedBox(width: AppDesignSystem.spacingXS.w),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: AppDesignSystem.fontSizeXS.sp,
              fontWeight: AppDesignSystem.bold,
              letterSpacing: 1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) =>
      Container(width: 7.w, height: 7.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10.w,
      height: 10.w,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final t = _c.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Expanding halo.
              Container(
                width: (4 + 8 * t).w,
                height: (4 + 8 * t).w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: (0.5 * (1 - t)).clamp(0.0, 1.0)),
                ),
              ),
              Container(
                width: 7.w,
                height: 7.w,
                decoration:
                    BoxDecoration(color: widget.color, shape: BoxShape.circle),
              ),
            ],
          );
        },
      ),
    );
  }
}
