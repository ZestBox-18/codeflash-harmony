import { hdsMaterial, ScrollEffectType, TitleBarStyleOptions } from '@kit.UIDesignKit';
import { LengthMetrics } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';

interface TitleStyleConfig {
  hasMenu: boolean;
  hasSubIcon: boolean;
  api22BackgroundColor: ResourceColor;
  menuTextColor: ResourceColor;
}

interface MenuStyleConfig {
  backgroundColor: ResourceColor;
  textColor: ResourceColor;
  iconColor: ResourceColor;
}

interface BackIconStyleConfig {
  backgroundColor: ResourceColor;
  iconColor: ResourceColor;
}

interface SubIconStyleConfig {
  iconColor: ResourceColor;
}

interface TitleTextStyleConfig {
  mainTitleColor: ResourceColor;
  subTitleColor: ResourceColor;
}

interface TitleContentStyleConfig {
  titleStyle: TitleTextStyleConfig;
  backIconStyle: BackIconStyleConfig;
  menuStyle?: MenuStyleConfig;
  subIconStyle?: SubIconStyleConfig;
}

interface ScrollEffectOptionsConfig {
  enableScrollEffect: boolean;
  scrollEffectType: ScrollEffectType;
  blurEffectiveStartOffset: LengthMetrics;
  blurEffectiveEndOffset: LengthMetrics;
}

interface SystemMaterialEffectConfig {
  materialType: hdsMaterial.MaterialType;
  materialLevel: hdsMaterial.MaterialLevel;
}

interface TitleBarSectionStyleConfig {
  backgroundStyle: BackgroundStyleConfig;
  contentStyle: TitleContentStyleConfig;
}

interface TitleBarStyleConfigObject {
  scrollEffectOpts: ScrollEffectOptionsConfig;
  originalStyle: TitleBarSectionStyleConfig;
  scrollEffectStyle: TitleBarSectionStyleConfig;
  systemMaterialEffect?: SystemMaterialEffectConfig;
}

interface BackgroundStyleConfig {
  backgroundColor: ResourceColor;
}

interface TitleSectionStyleConfig {
  backgroundStyle: BackgroundStyleConfig;
  contentStyle: TitleContentStyleConfig;
}

/**
 * 标题栏样式兼容工具。
 * 将 HdsNavigation 相关的 API22 / API23 样式差异统一收敛到此处，
 * 页面层只使用结果，不再自行维护兼容分支。
 */
export class TitleBarStyleHelper {
  /**
   * 是否支持沉浸光感材质能力。
   * 当前仅 API23 及以上版本启用 systemMaterialEffect。
   */
  static isMaterialEffectSupported(): boolean {
    return deviceInfo.sdkApiVersion > 22;
  }


  /**
   * 获取目标页（FAQ / 使用说明 / 投喂作者）统一标题栏样式。
   */
  static getDestinationStyle(): TitleBarStyleOptions {
    const config: TitleStyleConfig = {
      hasMenu: false,
      hasSubIcon: false,
      api22BackgroundColor: $r('app.color.page_background'),
      menuTextColor: $r('app.color.text_secondary')
    };
    return TitleBarStyleHelper.createStyle(config);
  }

  /**
   * 获取设置页统一标题栏样式。
   */
  static getSettingsStyle(): TitleBarStyleOptions {
    const config: TitleStyleConfig = {
      hasMenu: true,
      hasSubIcon: true,
      api22BackgroundColor: $r('app.color.title_bar_bg'),
      menuTextColor: $r('app.color.text_secondary')
    };
    return TitleBarStyleHelper.createStyle(config);
  }

  /**
   * 获取主页统一标题栏样式。
   * menuTextColor 由页面层根据连接状态透传，不纳入兼容层内部判断。
   */
  static getMainStyle(menuTextColor: ResourceColor): TitleBarStyleOptions {
    const config: TitleStyleConfig = {
      hasMenu: true,
      hasSubIcon: false,
      api22BackgroundColor: $r('app.color.title_bar_bg'),
      menuTextColor: menuTextColor
    };
    return TitleBarStyleHelper.createStyle(config);
  }

  /**
   * 根据当前 SDK 版本选择 API22 或 API23 的标题栏样式。
   */
  private static createStyle(config: TitleStyleConfig): TitleBarStyleOptions {
    if (deviceInfo.sdkApiVersion > 22) {
      return TitleBarStyleHelper.createApi23Style(config);
    }
    return TitleBarStyleHelper.createApi22Style(config);
  }

  /**
   * 生成 API22 兼容标题栏样式。
   */
  private static createApi22Style(config: TitleStyleConfig): TitleBarStyleOptions {
    const scrollEffectOpts: ScrollEffectOptionsConfig = TitleBarStyleHelper.createScrollEffectOptions(false);
    const originalStyle: TitleBarSectionStyleConfig = TitleBarStyleHelper.createSectionStyle(
      config.api22BackgroundColor,
      TitleBarStyleHelper.createContentStyle(config)
    );
    const scrollEffectStyle: TitleBarSectionStyleConfig = TitleBarStyleHelper.createSectionStyle(
      $r('app.color.title_bar_bg'),
      TitleBarStyleHelper.createContentStyle(config)
    );
    const style: TitleBarStyleConfigObject = {
      scrollEffectOpts: scrollEffectOpts,
      originalStyle: originalStyle,
      scrollEffectStyle: scrollEffectStyle
    };
    return style;
  }

  /**
   * 生成 API23 兼容标题栏样式，包括沉浸式渐变模糊和沉浸光感材质。
   */
  private static createApi23Style(config: TitleStyleConfig): TitleBarStyleOptions {
    const scrollEffectOpts: ScrollEffectOptionsConfig = TitleBarStyleHelper.createScrollEffectOptions(true);
    const systemMaterialEffect: SystemMaterialEffectConfig = {
      materialType: hdsMaterial.MaterialType.ADAPTIVE,
      materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
    };
    const originalStyle: TitleBarSectionStyleConfig = TitleBarStyleHelper.createSectionStyle(
      $r('app.color.title_bar_bg'),
      TitleBarStyleHelper.createContentStyle(config)
    );
    const scrollEffectStyle: TitleBarSectionStyleConfig = TitleBarStyleHelper.createSectionStyle(
      $r('app.color.title_bar_bg'),
      TitleBarStyleHelper.createContentStyle(config)
    );
    const style: TitleBarStyleConfigObject = {
      scrollEffectOpts: scrollEffectOpts,
      systemMaterialEffect: systemMaterialEffect,
      originalStyle: originalStyle,
      scrollEffectStyle: scrollEffectStyle
    };
    return style;
  }

  /**
   * 根据 API 版本生成滚动动态样式配置。
   * API22 使用通用模糊，API23 使用沉浸式渐变模糊。
   */
  private static createScrollEffectOptions(isApi23: boolean): ScrollEffectOptionsConfig {
    const scrollEffectOptions: ScrollEffectOptionsConfig = {
      enableScrollEffect: true,
      scrollEffectType: isApi23 ? ScrollEffectType.IMMERSIVE_GRADIENT_BLUR : ScrollEffectType.COMMON_BLUR,
      blurEffectiveStartOffset: LengthMetrics.vp(0),
      blurEffectiveEndOffset: LengthMetrics.vp(20)
    };
    return scrollEffectOptions;
  }

  /**
   * 构建标题栏背板与内容区组合结构。
   */
  private static createSectionStyle(
    backgroundColor: ResourceColor,
    contentStyle: TitleContentStyleConfig
  ): TitleBarSectionStyleConfig {
    const sectionStyle: TitleBarSectionStyleConfig = {
      backgroundStyle: {
        backgroundColor: backgroundColor
      },
      contentStyle: contentStyle
    };
    return sectionStyle;
  }

  /**
   * 构建标题栏内容区样式。
   * 仅按页面差异选择性补齐 menuStyle / subIconStyle。
   */
  private static createContentStyle(config: TitleStyleConfig): TitleContentStyleConfig {
    const contentStyle: TitleContentStyleConfig = {
      titleStyle: {
        mainTitleColor: $r('app.color.text_primary'),
        subTitleColor: $r('app.color.text_secondary')
      },
      backIconStyle: {
        backgroundColor: $r('app.color.action_bg'),
        iconColor: $r('app.color.text_primary')
      }
    };
    if (config.hasMenu) {
      contentStyle.menuStyle = {
        backgroundColor: $r('app.color.action_bg'),
        textColor: config.menuTextColor,
        iconColor: $r('app.color.text_primary')
      };
    }
    if (config.hasSubIcon) {
      contentStyle.subIconStyle = {
        iconColor: $r('app.color.text_primary')
      };
    }
    return contentStyle;
  }
}
