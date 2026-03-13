import { pasteboard, BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { DiscoveredDevice } from '../model/Device';
import { ConfigurationConstant } from '@kit.AbilityKit';

@Component
export struct DashboardView {
  @Link serverIp: string;
  @Link isScanning: boolean;
  @Link discoveredDevices: DiscoveredDevice[];
  
  @Link isAutoPushEnabled: boolean;
  @StorageProp('currentColorMode') currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  
  // 回调函数
  onScan: () => void = () => {};
  onPush: (text: string) => void = () => {};
  onPull: () => void = () => {};
  onSelectDevice: (ip: string) => void = () => {};
  onAutoPushChange: (isOn: boolean) => void = () => {};

  @State manualIp: string = '';

  aboutToAppear() {
    this.manualIp = '';
  }

  isDark() {
    return this.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  }

  build() {
    Column() {
      // Header removed as it is now in Navigation title

      Column() {
        // 1. 连接设置卡片
        Column() {
          Row() {
             Text('连接设置')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDark() ? '#FFFFFF' : '#191919')
             
             Blank()
             
             // 扫描动画/状态
             if (this.isScanning) {
               Row() {
                 LoadingProgress().width(16).height(16).color('#2FB04A').margin({ right: 4 })
                 Text('扫描中...')
                   .fontSize(12)
                   .fontColor('#2FB04A')
               }
             } else {
               Row() {
                 SymbolGlyph($r('sys.symbol.arrow_clockwise'))
                   .fontSize(14)
                   .fontColor(['#2FB04A'])
                   .margin({ right: 4 })
                 Text('刷新')
                   .fontSize(12)
                   .fontColor('#2FB04A')
               }
               .onClick(() => {
                 this.onScan();
               })
             }
          }
          .width('100%')
          .margin({ bottom: 16 })
          .alignItems(VerticalAlign.Center)

          // 局域网设备列表
          if (this.discoveredDevices.length > 0 || this.serverIp) {
            Column({ space: 8 }) {
              if (this.serverIp && !this.discoveredDevices.some(d => d.ip === this.serverIp)) {
                 Row() {
                  SymbolGlyph($r('sys.symbol.pc'))
                    .fontSize(24)
                    .fontColor(['#2FB04A'])
                    .margin({ right: 12 })
                  
                  Column() {
                    Text('已保存设备')
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.isDark() ? '#FFFFFF' : '#191919')
                    Text(this.serverIp)
                      .fontSize(12)
                      .fontColor(this.isDark() ? '#8E8E93' : '#999999')
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  SymbolGlyph($r('sys.symbol.checkmark_circle_fill'))
                      .fontSize(20)
                      .fontColor(['#34C759'])
                 }
                 .width('100%')
                 .padding(12)
                 .backgroundColor(this.isDark() ? '#2C2C2E' : '#F9F9F9')
                 .borderRadius(12)
              }

              ForEach(this.discoveredDevices, (device: DiscoveredDevice) => {
                Row() {
                  SymbolGlyph($r('sys.symbol.pc'))
                    .fontSize(24)
                    .fontColor(['#2FB04A'])
                    .margin({ right: 12 })
                  
                  Column() {
                    Text(device.hostname)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.isDark() ? '#FFFFFF' : '#191919')
                    Text(device.ip)
                      .fontSize(12)
                      .fontColor(this.isDark() ? '#8E8E93' : '#999999')
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  if (this.serverIp === device.ip) {
                    SymbolGlyph($r('sys.symbol.checkmark_circle_fill'))
                      .fontSize(20)
                      .fontColor(['#34C759'])
                  } else {
                    Button('连接')
                      .fontSize(12)
                      .height(28)
                      .backgroundColor(this.isDark() ? '#1C1C1E' : '#E6F0FF')
                      .fontColor('#2FB04A')
                      .onClick(() => {
                        this.onSelectDevice(device.ip);
                      })
                  }
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.isDark() ? '#2C2C2E' : '#F9F9F9')
                .borderRadius(12)
                .onClick(() => {
                   this.onSelectDevice(device.ip);
                })
                .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
              }, (device: DiscoveredDevice) => device.ip)
            }
            .margin({ bottom: 16 })
          } else if (!this.isScanning && this.discoveredDevices.length === 0 && !this.serverIp) {
             // 扫描结束且未发现设备
             Column() {
               Text('未发现设备，请确保在同一局域网')
                 .fontSize(12)
                 .fontColor(this.isDark() ? '#8E8E93' : '#999999')
                 .margin({ bottom: 8 })
             }
             .width('100%')
             .alignItems(HorizontalAlign.Center)
             .margin({ bottom: 12 })
          }

          // 手动输入 IP
          Row() {
            TextInput({ placeholder: '手动输入 IP 地址...', text: this.manualIp })
              .fontSize(14)
              .fontColor(this.isDark() ? '#FFFFFF' : '#191919')
              .placeholderColor(this.isDark() ? '#636366' : '#999999')
              .caretColor('#2FB04A')
              .backgroundColor(this.isDark() ? '#000000' : '#F5F7FA')
              .height(44)
              .borderRadius(12)
              .border({ width: 1, color: this.isDark() ? '#2C2C2E' : '#E5E5EA' }) // Consistent border
              .layoutWeight(1)
              .padding({ left: 12, right: 12 })
              .onChange((value) => {
                this.manualIp = value;
              })
            
            Button('连接')
              .height(44)
              .backgroundColor('#2FB04A')
              .borderRadius(12)
              .margin({ left: 12 })
              .onClick(() => {
                 this.onSelectDevice(this.manualIp);
              })
          }
          .width('100%')
          .margin({ bottom: 16 })

          // 自动推送开关
          Row() {
            Row() {
              SymbolGlyph($r('sys.symbol.paperplane'))
                .fontSize(20)
                .fontColor(['#2FB04A'])
                .margin({ right: 12 })
              
              Column() {
                Text('自动推送')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isDark() ? '#FFFFFF' : '#191919')
                Text('连接后自动推送剪贴板内容')
                  .fontSize(12)
                  .fontColor(this.isDark() ? '#8E8E93' : '#999999')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
            }

            Blank()

            Toggle({ type: ToggleType.Switch, isOn: this.isAutoPushEnabled })
              .selectedColor('#2FB04A')
              .switchPointColor('#FFFFFF')
              .onChange((isOn: boolean) => {
                this.isAutoPushEnabled = isOn;
                this.onAutoPushChange(isOn);
              })
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })

        }
        .padding(20)
        .backgroundColor(this.isDark() ? '#1C1C1E' : Color.White)
        .borderRadius(24)
        .shadow(ShadowStyle.OUTER_DEFAULT_SM)
        .margin({ bottom: 24 })
        .width('100%')

        // 2. 功能入口卡片
        Row() {
          // 从电脑获取
          Column() {
            Button({ type: ButtonType.Circle }) {
               SymbolGlyph($r('sys.symbol.arrow_down'))
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor([Color.White])
            }
            .width(64)
            .height(64)
            .backgroundColor('#2FB04A')
            .shadow({ radius: 8, color: 'rgba(47, 176, 74, 0.3)', offsetY: 4 })
            .margin({ bottom: 16 })
            .onClick(() => {
              this.onPull();
            })

            Text('从电脑获取')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDark() ? '#FFFFFF' : '#191919')
            
            Text('点击同步')
              .fontSize(12)
              .fontColor(this.isDark() ? '#8E8E93' : '#999999')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .height(160)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.isDark() ? '#1C1C1E' : Color.White)
          .borderRadius(24)
          .shadow(ShadowStyle.OUTER_DEFAULT_SM)
          .margin({ right: 12 })

          // 推送到电脑 (PasteButton)
          Column() {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.arrow_up'))
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor([Color.White])
            }
            .width(64)
            .height(64)
            .backgroundColor('#2FB04A')
            .shadow({ radius: 8, color: 'rgba(47, 176, 74, 0.3)', offsetY: 4 })
            .margin({ bottom: 16 })
            .onClick(() => {
              pasteboard.getSystemPasteboard().getData((err, pasteData) => {
                this.onPush(pasteData.getPrimaryText());

                if (!err) console.log("内容:", pasteData.getPrimaryText())
              });
            })

               
             Text('推送到电脑')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDark() ? '#FFFFFF' : '#191919')

            Text('点击发送')
              .fontSize(12)
              .fontColor(this.isDark() ? '#8E8E93' : '#999999')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .height(160)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.isDark() ? '#1C1C1E' : Color.White)
          .borderRadius(24)
          .shadow(ShadowStyle.OUTER_DEFAULT_SM)
          .margin({ left: 12 })
        }
        .width('100%')
        .margin({ bottom: 24 })
      }
      .padding({ left: 16, right: 16 })
      .width('100%')
    }
    .width('100%')
    .backgroundColor(this.isDark() ? '#000000' : '#F5F7FA')
  }
}
