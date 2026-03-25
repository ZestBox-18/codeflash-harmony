/**
 * Copyright (C), 2026-03-13
 * @author ZestBox
 * @date 2026-03-13 
 * @version 1.0
 * @description:
 */

import { HdsNavDestination, ScrollEffectType } from "@kit.UIDesignKit";
import { LengthMetrics } from "@kit.ArkUI";
@ComponentV2
export struct Sponsorship {
  build() {
    HdsNavDestination() {
      Scroll() {
        Column() {
          Column() {
            Text('感谢你的投喂与支持')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            Text('每一份鼓励都是我持续更新的动力。你可以左右滑动选择支付宝或微信。')
              .fontSize(13)
              .lineHeight(18)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.block_background'))
          .borderRadius(16)
          .shadow(ShadowStyle.OUTER_DEFAULT_SM)

          Swiper() {
            this.PayItem('支付宝', $r('app.media.aipay'))
            this.PayItem('微信', $r('app.media.wechat'))
          }
          .indicator(true)
          .loop(true)
          .height(550)
          .margin({ top: 16 })

        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      }
      .padding({top:20})
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor($r('app.color.page_background'))
    }
    .titleBar({
      padding: {
        start: LengthMetrics.vp(20),
        end: LengthMetrics.vp(2)
      },
      style: {
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: ScrollEffectType.COMMON_BLUR,
          blurEffectiveStartOffset: LengthMetrics.vp(0),
          blurEffectiveEndOffset: LengthMetrics.vp(20)
        },
        originalStyle: {
          backgroundStyle: {
            backgroundColor: $r('app.color.page_background'),
          },
          contentStyle: {
            titleStyle: { mainTitleColor: $r('sys.color.font_primary'), subTitleColor: $r('sys.color.font_secondary') },
            menuStyle: {
              backgroundColor: $r('sys.color.comp_background_tertiary'),
              iconColor: $r('sys.color.icon_primary')
            },
            backIconStyle: {
              backgroundColor: $r('sys.color.comp_background_tertiary'),
              iconColor: $r('sys.color.icon_primary')
            }
          }
        },
        scrollEffectStyle: {
          backgroundStyle: {
            backgroundColor: $r('sys.color.ohos_id_color_background_transparent'),
          },
          contentStyle: {
            titleStyle: { mainTitleColor: $r('sys.color.font_primary'), subTitleColor: $r('sys.color.font_secondary') },
            menuStyle: {
              backgroundColor: $r('sys.color.comp_background_tertiary'),
              iconColor: $r('sys.color.icon_primary')
            },
            backIconStyle: {
              backgroundColor: $r('sys.color.comp_background_tertiary'),
              iconColor: $r('sys.color.icon_primary')
            }
          }
        }
      },
      content: {
        title: {
          mainTitle: "投喂作者",
        }
      }
    })
  }

  @Builder
  PayItem(title: string, imageRes: Resource) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      Image(imageRes)
        .width('100%')
        .height(450)
        .borderRadius(16)
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .padding(16)

  }
}
