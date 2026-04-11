import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Responsive container that adapts to different screen sizes
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BoxDecoration? decoration;
  final double? maxWidth;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.decoration,
    this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? Responsive.padding(context),
      decoration: decoration ??
          (backgroundColor != null
              ? BoxDecoration(color: backgroundColor)
              : null),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? Responsive.maxContentWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Responsive grid that adjusts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double? childAspectRatio;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16,
    this.childAspectRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: Responsive.gridColumns(context),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio ?? 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Responsive text that scales based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final double? mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  final TextAlign? textAlign;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.baseStyle,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = Responsive.fontSize(
      context,
      mobile: mobileSize ?? 14,
      tablet: tabletSize ?? 16,
      desktop: desktopSize ?? 18,
    );

    return Text(
      text,
      style: (baseStyle ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
    );
  }
}

/// Responsive button that scales based on screen size
class ResponsiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;

  const ResponsiveButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = Responsive.buttonHeight(context);
    final fontSize = Responsive.fontSize(context, mobile: 14, tablet: 16, desktop: 18);

    if (isOutlined) {
      return SizedBox(
        height: height,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
          style: OutlinedButton.styleFrom(
            textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
