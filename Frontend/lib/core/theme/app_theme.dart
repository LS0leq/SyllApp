import 'package:flutter/material.dart';

class AppTheme {
  
  static const Color editorBackground = Color(0xFF1E1E1E);
  static const Color sidebarBackground = Color(0xFF252526);
  static const Color activityBarBackground = Color(0xFF333333);
  static const Color titleBarBackground = Color(0xFF323233);
  static const Color statusBarBackground = Color(0xFF007ACC);
  static const Color tabsBackground = Color(0xFF2D2D2D);
  static const Color tabActiveBackground = Color(0xFF1E1E1E);
  static const Color tabHoverBackground = Color(0xFF2A2D2E);
  
  
  static const Color border = Color(0xFF3C3C3C);
  static const Color borderLight = Color(0xFF474747);
  static const Color divider = Color(0xFF3C3C3C);
  
  
  static const Color selectionBackground = Color(0xFF264F78);
  static const Color lineHighlight = Color(0xFF2A2D2E);
  static const Color hoverBackground = Color(0xFF2A2D2E);
  static const Color focusBorder = Color(0xFF007ACC);
  
  
  static const Color textPrimary = Color(0xFFCCCCCC);
  static const Color textSecondary = Color(0xFF808080);
  static const Color textMuted = Color(0xFF6A6A6A);
  static const Color textAccent = Color(0xFF4FC1FF);
  
  
  static const Color accent = Color(0xFF007ACC);
  static const Color accentLight = Color(0xFF0098FF);
  static const Color accentDark = Color(0xFF0E639C);
  
  
  static const Color syntaxKeyword = Color(0xFFC586C0);    
  static const Color syntaxFunction = Color(0xFFDCDCAA);   
  static const Color syntaxVariable = Color(0xFF9CDCFE);   
  static const Color syntaxString = Color(0xFFCE9178);     
  static const Color syntaxNumber = Color(0xFFB5CEA8);     
  static const Color syntaxComment = Color(0xFF6A9955);    
  
  
  static const List<Color> rhymeColors = [
    Color(0xFF4FC1FF),  
    Color(0xFFC586C0),  
    Color(0xFFCE9178),  
    Color(0xFF4EC9B0),  
    Color(0xFFDCDCAA),  
    Color(0xFFB5CEA8),  
    Color(0xFFFF6B6B),  
    Color(0xFF6BFFB8),  
    Color(0xFFFFB86B),  
    Color(0xFF6B9FFF),  
    Color(0xFFFF6BDF),  
    Color(0xFFFFFF6B),  
  ];
  
  
  static const Color tooltipBackground = Color(0xFF3C3C3C);
  static const Color tooltipBorder = Color(0xFF4A4A4A);

  
  static const Color iconActive = Color(0xFFFFFFFF);
  static const Color iconInactive = Color(0xFF858585);
  static const Color iconFolder = Color(0xFFE8AB53);
  static const Color iconFile = Color(0xFF519ABA);
  
  
  static const Color errorColor = Color(0xFFF14C4C);
  static const Color warningColor = Color(0xFFCCA700);
  static const Color infoColor = Color(0xFF3794FF);
  static const Color successColor = Color(0xFF89D185);
  
  
  static const Color appleBlur = Color(0x99252526); 
  static const Color appleCardBackground = Color(0xFF2C2C2E);
  static const Color appleElevatedBackground = Color(0xFF3A3A3C);
  static const Color appleSystemGray = Color(0xFF8E8E93);
  static const Color appleSystemGray2 = Color(0xFF636366);
  static const Color appleSystemGray3 = Color(0xFF48484A);
  static const Color appleSystemGray4 = Color(0xFF3A3A3C);
  static const Color appleSystemGray5 = Color(0xFF2C2C2E);
  static const Color appleSystemGray6 = Color(0xFF1C1C1E);
  
  
  static List<BoxShadow> get appleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get appleShadowSmall => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
  ];
  
  
  static const double appleSpacingXS = 8.0;
  static const double appleSpacingS = 12.0;
  static const double appleSpacingM = 16.0;
  static const double appleSpacingL = 20.0;
  static const double appleSpacingXL = 24.0;
  
  
  static const double appleRadiusS = 10.0;
  static const double appleRadiusM = 16.0;
  static const double appleRadiusL = 20.0;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: editorBackground,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentLight,
        surface: sidebarBackground,
        error: errorColor,
      ),
      fontFamily: 'Consolas',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontFamily: 'Consolas',
          height: 1.5,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 13,
          fontFamily: 'Consolas',
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontFamily: 'Consolas',
        ),
        labelSmall: TextStyle(
          color: textSecondary,
          fontSize: 11,
          fontFamily: 'Segoe UI',
          fontWeight: FontWeight.w400,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 13,
          fontFamily: 'Segoe UI',
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 11,
          fontFamily: 'Segoe UI',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardColor: sidebarBackground,
      dividerColor: divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: titleBarBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 13,
          fontFamily: 'Segoe UI',
          fontWeight: FontWeight.w400,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(const Color(0xFF5A5A5A)),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        radius: const Radius.circular(0),
        thickness: WidgetStateProperty.all(10),
      ),
      iconTheme: const IconThemeData(
        color: iconInactive,
        size: 16,
      ),
    );
  }

  static Color getRhymeColor(int index) {
    return rhymeColors[index % rhymeColors.length];
  }

  static BoxDecoration getRhymeDecoration(int rhymeIndex) {
    final color = getRhymeColor(rhymeIndex);
    return BoxDecoration(
      border: Border(
        left: BorderSide(
          color: color.withValues(alpha: 0.8),
          width: 3,
        ),
      ),
      color: color.withValues(alpha: 0.08),
    );
  }

  
  static BoxDecoration get gutterDecoration {
    return const BoxDecoration(
      color: editorBackground,
      border: Border(
        right: BorderSide(
          color: border,
          width: 1,
        ),
      ),
    );
  }

  
  static ButtonStyle get activityBarButtonStyle {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        if (states.contains(WidgetState.hovered)) {
          return hoverBackground;
        }
        return Colors.transparent;
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
      padding: WidgetStateProperty.all(const EdgeInsets.all(12)),
    );
  }
}
