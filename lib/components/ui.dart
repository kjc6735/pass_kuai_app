import 'package:flutter/material.dart';
import 'package:pass_kuai/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 18,
    this.color = AppColors.surface,
    this.shadow = true,
    this.outlined = true,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final bool shadow;

  final bool outlined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: outlined ? const BorderSide(color: AppColors.line) : BorderSide.none,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ? cardShadow : null,
      ),
      child: Material(
        color: color,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled ? primaryShadow : null,
      ),
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            : _Label(icon: icon, label: label),
      ),
    );
  }
}

class SoftButton extends StatelessWidget {
  const SoftButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primarySoft,
        foregroundColor: AppColors.primarySoftText,
        textStyle: const TextStyle(fontSize: 16, fontWeight: AppWeights.title),
      ),
      child: _Label(icon: icon, label: label),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.label});

  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
    );
  }
}

enum IconTileStyle { soft, outline, filled, plain }

class IconTileButton extends StatelessWidget {
  const IconTileButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.style = IconTileStyle.soft,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final IconTileStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (style) {
      IconTileStyle.soft => (AppColors.primarySoft, AppColors.primarySoftText, null),
      IconTileStyle.outline => (Colors.white, AppColors.primaryText, AppColors.border),
      IconTileStyle.filled => (AppColors.primary, Colors.white, null),
      IconTileStyle.plain => (Colors.transparent, AppColors.ink, null),
    };
    final radius = BorderRadius.circular(size * 0.28);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: border == null ? BorderSide.none : BorderSide(color: border, width: 1.5),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: RoundedRectangleBorder(borderRadius: radius),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.45, color: fg),
          ),
        ),
      ),
    );
  }
}

class PinyinHanzi extends StatelessWidget {
  const PinyinHanzi({
    super.key,
    required this.hanzi,
    required this.pinyin,
    required this.color,
    this.hanziSize = 36,
    this.pinyinColor,
  });

  final String hanzi;
  final String pinyin;
  final Color color;
  final Color? pinyinColor;
  final double hanziSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          pinyin,
          style: TextStyle(
            fontSize: hanziSize * 0.37,
            fontWeight: AppWeights.pinyin,
            color: pinyinColor ?? color,
          ),
        ),
        Text(
          hanzi,
          style: TextStyle(
            fontSize: hanziSize,
            fontWeight: AppWeights.hanzi,
            color: color,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: AppWeights.title)),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          Text(trailing!, style: const TextStyle(fontSize: 13, color: AppColors.sub)),
        ],
      ],
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 34, color: AppColors.primaryText),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: AppWeights.title),
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.sub, fontSize: 15, height: 1.5),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.sub),
                ),
              Text(
                title,
                style: const TextStyle(fontSize: 26, fontWeight: AppWeights.title, letterSpacing: -0.5),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
