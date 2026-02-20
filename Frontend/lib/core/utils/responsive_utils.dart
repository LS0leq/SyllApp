import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart' as platform;









class ResponsiveUtils {
  

  
  static const double mobileBreakpoint = 600;

  
  static const double tabletBreakpoint = 900;

  

  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  

  
  
  
  
  static bool shouldUseDesktopLayout(BuildContext context) {
    if (kIsWeb) return isDesktop(context);
    return platform.isNativeDesktop;
  }

  

  
  
  static bool get isMobilePlatform => platform.isNativeMobile;

  
  
  static bool get isDesktopPlatform {
    if (kIsWeb) return false;
    return platform.isNativeDesktop;
  }

  
  
  static bool get hasNativeFileSystem {
    if (kIsWeb) return false;
    return platform.isNativeDesktop;
  }

  

  
  static double getFontSize(BuildContext context,
      {double desktop = 13, double mobile = 15}) =>
      isMobile(context) ? mobile : desktop;

  
  static double getIconSize(BuildContext context,
      {double desktop = 16, double mobile = 24}) =>
      isMobile(context) ? mobile : desktop;

  
  static double getTouchTarget(BuildContext context) =>
      isMobile(context) ? 48.0 : 32.0;

  
  static EdgeInsets getPadding(BuildContext context, {
    EdgeInsets desktop = const EdgeInsets.all(8),
    EdgeInsets mobile = const EdgeInsets.all(16),
  }) => isMobile(context) ? mobile : desktop;
}
