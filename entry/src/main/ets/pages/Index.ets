import { pasteboard, BusinessError } from '@kit.BasicServicesKit';
import { http, socket } from '@kit.NetworkKit';
import { promptAction } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { abilityAccessCtrl, common, ConfigurationConstant } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { DashboardView } from '../view/DashboardView';
import { HistoryView } from '../view/HistoryView';
import { HistoryItem, HistoryManager } from '../model/History';
import { DiscoveredDevice } from '../model/Device';

import { LengthMetrics } from '@kit.ArkUI';
import { HdsNavigation, ScrollEffectType, TextStyleMode } from '@kit.UIDesignKit';
import { CommonConstants } from '../constants/CommonConstants';



interface DiscoverMsg {
  ip: string;
  hostname?: string;
}

@Entry
@ComponentV2
struct Index {
  @Local currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  @Local serverIp: string = '';
  @Local isPushing: boolean = false;
  @Local isPulling: boolean = false;
  @Local isScanning: boolean = false;
  @Local statusMsg: string = '准备就绪';
  @Local clipboardContent: string = '';
  @Local historyList: HistoryItem[] = [];
  @Local discoveredDevices: DiscoveredDevice[] = [];
  @Local topRectHeight: number = 0;
  @Local bottomRectHeight: number = 0;
  UIcontext: UIContext = this.getUIContext();
  @Local isAutoPushEnabled: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;
  private pref: preferences.Preferences | null = null;
  private pushHttpRequest: http.HttpRequest | null = null;
  private pullHttpRequest: http.HttpRequest | null = null;
  private udpSocket: socket.UDPSocket | null = null;
  private targetId: string = 'bindMenu'

  async aboutToAppear() {
    // 手动获取 AppStorage 的值
    this.currentMode = AppStorage.get(CommonConstants.CURRENT_COLOR_MODE) || ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    this.topRectHeight = AppStorage.get(CommonConstants.AVOID_RECT_HEIGHT_TOP) || 0;
    this.bottomRectHeight = AppStorage.get(CommonConstants.AVOID_RECT_HEIGHT_BOTTOM) || 0;

    // 将AppStorage中的安全区高度进行单位转化
    if (this.topRectHeight > 0) {
      let topRectHeight = this.UIcontext.px2vp(this.topRectHeight)
      // 注意：这里更新 AppStorage 不会自动触发 V2 组件的重绘，但我们更新了 this.topRectHeight
      AppStorage.setOrCreate(CommonConstants.AVOID_RECT_HEIGHT_TOP, topRectHeight);
      this.topRectHeight = topRectHeight
    }
    if (this.bottomRectHeight > 0) {
      let bottomRectHeight = this.UIcontext.px2vp(this.bottomRectHeight);
      AppStorage.setOrCreate(CommonConstants.AVOID_RECT_HEIGHT_BOTTOM, bottomRectHeight);
      this.bottomRectHeight = bottomRectHeight
    }

    pasteboard.getSystemPasteboard().getData((err, pasteData) => {
      if (!err) {
        console.log("内容:", pasteData.getPrimaryText());
      }
    });
    const atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(getContext(this), ["ohos.permission.READ_PASTEBOARD"])
      .then((data) => {
        if (data.authResults[0] === 0) {
          // 授权成功，读取剪贴板
          pasteboard.getSystemPasteboard().getData((err, pasteData) => {
            if (!err) {
              console.log("内容:", pasteData.getPrimaryText());
            }
          });
        }
      })
      .catch((err: BusinessError) => {
        console.error("授权失败:", err.message);
      });
    // 初始化首选项
    try {
      this.pref = await preferences.getPreferences(this.context, 'codeflash_store');
      this.serverIp = await this.pref.get('server_ip', '') as string;
      this.isAutoPushEnabled = await this.pref.get('auto_push', false) as boolean;
      
      // 加载历史记录
      this.historyList = await HistoryManager.getAll();
    } catch (e) {
      console.error('Failed to load preferences');
    }

    // 检测上次连接
    if (this.serverIp) {
      this.checkConnection(this.serverIp).then((isConnected) => {
        if (isConnected) {
          this.statusMsg = `已连接到: ${this.serverIp}`;
          // 自动推送
          if (this.isAutoPushEnabled) {
            pasteboard.getSystemPasteboard().getData((err, pasteData) => {
              if (!err && pasteData) {
                const text = pasteData.getPrimaryText();
                if (text) {
                  this.pushToComputer(text);
                }
              }
            });
          }
        } else {
          // 连接失败，清除连接状态并开始扫描
          this.saveIp('');
          this.scanComputer();
        }
      });
    } else {
      // 无上次连接，直接扫描
      this.scanComputer();
    }
  }

  async checkConnection(ip: string): Promise<boolean> {
    try {
      let httpRequest = http.createHttp();
      // 尝试访问一个轻量级接口或者只是 ping，这里用 pull 接口简单测试
      const response = await httpRequest.request(`http://${ip}:56669/get-from-computer`, {
        method: http.RequestMethod.GET,
        connectTimeout: 1000, // 1秒超时
        readTimeout: 1000
      });
      httpRequest.destroy();
      return response.responseCode === 200;
    } catch (e) {
      return false;
    }
  }

  async saveIp(ip: string) {
    this.UIcontext.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.serverIp = ip;
    })
    if (this.pref) {
      try {
        await this.pref.put('server_ip', ip);
        await this.pref.flush();

      } catch (error) {
      }
    }
  }

  async saveAutoPush(isOn: boolean) {
    this.isAutoPushEnabled = isOn;
    if (this.pref) {
      await this.pref.put('auto_push', isOn);
      await this.pref.flush();
    }
  }

  async deleteHistory(id: number) {
    const newList = await HistoryManager.delete(id);
    this.UIcontext.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.historyList = newList;
    })
  }

  async clearHistory() {
    const newList = await HistoryManager.clear();
    this.UIcontext.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.historyList = newList;
    })
  }

  // 扫描局域网电脑
  async scanComputer() {
    this.UIcontext.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.isScanning = true;
    })
    this.statusMsg = '正在扫描电脑...';
    this.discoveredDevices = [];

    if (this.udpSocket) {
      try {
        this.udpSocket.close();
      } catch (e) {
      }
      this.udpSocket = null;
    }

    this.udpSocket = socket.constructUDPSocketInstance();
    const udpSocket: socket.UDPSocket = this.udpSocket;

    try {
      // 1. 绑定本地端口
      let bindAddress: socket.NetAddress = {
        address: '0.0.0.0',
        port: 0,
        family: 1
      };
      if (udpSocket) {
        await udpSocket.bind(bindAddress);
      }

      // 2. 监听消息
      if (udpSocket) {
        udpSocket.on('message', (value: socket.SocketMessageInfo) => {
          let msg = util.TextDecoder.create('utf-8').decodeToString(new Uint8Array(value.message));
          console.info('UDP Received: ' + msg);

          try {
            let obj = JSON.parse(msg) as DiscoverMsg;
            let ip = obj.ip;
            if (ip) {
              // 避免重复添加
              const exists = this.discoveredDevices.some((d: DiscoveredDevice) => d.ip === ip);
              if (!exists) {
                const device = new DiscoveredDevice(ip, obj.hostname || ip);
                let newDevices = new Array<DiscoveredDevice>();
                this.discoveredDevices.forEach(d => newDevices.push(d));
                newDevices.push(device);

                this.UIcontext.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
                  this.discoveredDevices = newDevices;
                })

                // 自动连接第一个发现的设备
                if (!this.serverIp && newDevices.length === 1) {
                  this.selectDevice(ip);
                }
              }
            }
          } catch (e) {
            console.error('JSON Parse Error');
          }
        });
      }

      // 3. 配置广播
      if (udpSocket) {
        try {
          let extraOptions: socket.UDPExtraOptions = {
            broadcast: true,
            reuseAddress: true,
            receiveBufferSize: 65535,
            sendBufferSize: 65535
          };
          await udpSocket.setExtraOptions(extraOptions);
        } catch (e) {
          console.error('UDP SetExtraOptions Error: ' + JSON.stringify(e));
        }
      }

      // 4. 发送广播
      let options: socket.UDPSendOptions = {
        data: 'CODEFLASH_DISCOVER',
        address: {
          address: '255.255.255.255',
          port: 56670,
          family: 1
        } as socket.NetAddress
      };

      // 检查 socket 状态并发送
      if (udpSocket) {
        try {
          await udpSocket.send(options);
        } catch (err) {
          console.error('UDP Send Error: ' + JSON.stringify(err));
        }
      }

      // 5秒后超时
      setTimeout(() => {
        if (this.isScanning) {
          this.UIcontext.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
            this.isScanning = false;
          })
          this.statusMsg = '扫描结束';
          try {
            udpSocket.close();
          } catch (e) {
          }
        }
      }, 5000);

    } catch (err) {
      console.error('UDP Error: ' + JSON.stringify(err));
      this.UIcontext.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
        this.isScanning = false;
      })
      this.statusMsg = '扫描失败';
      try {
        udpSocket.close();
      } catch (e) {
      }
    }
  }

  // 手动选择设备
  async selectDevice(ip: string) {
    if (!ip) {
      return;
    }
    const isConnected = await this.checkConnection(ip);
    if (isConnected) {
      await this.saveIp(ip);
      try {
        promptAction.showToast({ message: `已连接: ${ip}` });
      } catch (error) {
      }
    } else {
      try {
        promptAction.showToast({ message: `连接失败: ${ip}` });
      } catch (error) {
      }
    }
  }

  // 推送
  async pushToComputer(text: string) {
    if (!this.serverIp) {
      try {
        promptAction.showToast({ message: '请先连接电脑' });
      } catch (error) {
      }
      return;
    }

    if (!text) {
      return;
    }
    this.clipboardContent = text; // 更新本地预览
    this.isPushing = true;

    try {
      this.pushHttpRequest = http.createHttp();
      const response = await this.pushHttpRequest.request(`http://${this.serverIp}:56669/send-to-computer`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'text/plain' },
        extraData: text,
        connectTimeout: 3000,
        readTimeout: 3000
      });

      if (response.responseCode === 200) {
        try {
          promptAction.showToast({ message: '已推送' });
        } catch (error) {
        }
        // 添加历史
        const newList = await HistoryManager.add('push', text, '我的电脑');
        this.UIcontext.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
          this.historyList = newList;
        })
      } else {
        try {
          promptAction.showToast({ message: '推送失败' });
        } catch (error) {
        }
      }
    } catch (e) {
      try {
        promptAction.showToast({ message: '网络错误' });
      } catch (error) {
      }
    } finally {
      this.isPushing = false;
      if (this.pushHttpRequest) {
        this.pushHttpRequest.destroy();
        this.pushHttpRequest = null;
      }
    }
  }

  // 拉取
  async pullFromComputer() {
    if (!this.serverIp) {
      try {
        promptAction.showToast({ message: '请先连接电脑' });
      } catch (error) {
      }
      return;
    }

    this.isPulling = true;

    try {
      this.pullHttpRequest = http.createHttp();
      const response = await this.pullHttpRequest.request(`http://${this.serverIp}:56669/get-from-computer`, {
        method: http.RequestMethod.GET,
        connectTimeout: 3000,
        readTimeout: 3000
      });

      if (response.responseCode === 200) {
        const text = response.result as string;

        // 写入系统剪贴板
        const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
        const systemPasteboard = pasteboard.getSystemPasteboard();
        await systemPasteboard.setData(pasteData);

        this.clipboardContent = text;
        try {
          promptAction.showToast({ message: '已复制到手机' });
        } catch (error) {
        }

        // 添加历史
        const newList = await HistoryManager.add('pull', text, '我的电脑');
        this.UIcontext.animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
          this.historyList = newList;
        })
      } else {
        try {
          promptAction.showToast({ message: '获取失败' });
        } catch (error) {
        }
      }
    } catch (e) {
      try {
        promptAction.showToast({ message: '连接错误' });
      } catch (error) {
      }
    } finally {
      this.isPulling = false;
      if (this.pullHttpRequest) {
        this.pullHttpRequest.destroy();
        this.pullHttpRequest = null;
      }
    }
  }

  isDark() {
    return this.currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  }

  build() {
    HdsNavigation() {
      Scroll() {
        Column() {
          // 1. 仪表盘 (Top Section)
          DashboardView({
            serverIp: this.serverIp,
            isScanning: this.isScanning,
            discoveredDevices: this.discoveredDevices,
            isAutoPushEnabled: this.isAutoPushEnabled,
            currentMode: this.currentMode,
            onScan: (): void => {
              this.scanComputer()
            },
            onPush: (text: string): void => {
              this.pushToComputer(text)
            },
            onPull: (): void => {
              this.pullFromComputer()
            },
            onSelectDevice: (ip: string): void => {
              this.selectDevice(ip)
            },
            onAutoPushChange: (isOn: boolean): void => {
              this.saveAutoPush(isOn)
            }
          })

          // 2. 历史记录 (Bottom Section)
          HistoryView({
            historyList: this.historyList,
            currentMode: this.currentMode,
            onDelete: (id: number): void => {
              this.deleteHistory(id)
            },
            onClear: (): void => {
              this.clearHistory()
            }
          })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.TopStart)
      .edgeEffect(EdgeEffect.Spring)
      .padding({
        top: CommonConstants.TITLE_BAR_HEIGHT_FREE + this.topRectHeight + 20,
      })
    }
    .titleBar({
      style: {
        // 设置导航组件标题栏样式
        // 标题栏动态模糊样式，包括是否使能滚动动态模糊，动态模糊类型，动态模糊生效的滚动距离等
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: ScrollEffectType.COMMON_BLUR,
          blurEffectiveStartOffset: LengthMetrics.vp(0),
          blurEffectiveEndOffset: LengthMetrics.vp(20)
        },
        originalStyle: {
          // 内容区滚动前初始样式设置
          backgroundStyle: {
            // 标题栏背板样式设置
            backgroundColor: this.isDark() ? '#1C1C1E' : $r('sys.color.ohos_id_color_background'),
          },
          contentStyle: {
            // 标题栏内容区样式设置，包括标题区域，菜单区域，返回按钮区域
            titleStyle: {
              mainTitleColor: this.isDark() ? '#FFFFFF' : $r('sys.color.font_primary'),
              subTitleColor: this.isDark() ? '#8E8E93' : $r('sys.color.font_secondary')
            },
            menuStyle: {
              backgroundColor: this.isDark() ? '#2C2C2E' : $r('sys.color.comp_background_tertiary'),
              textColor: this.serverIp ? '#2FB04A' : (this.isDark() ? '#8E8E93' : '#999999')
            },
            backIconStyle: {
              backgroundColor: this.isDark() ? '#2C2C2E' : $r('sys.color.comp_background_tertiary'),
              iconColor: this.isDark() ? '#FFFFFF' : $r('sys.color.icon_primary')
            }
          }
        },
        scrollEffectStyle: {
          // 内容区滚动超过blurEffectiveEndOffset后样式设置
          backgroundStyle: {
            backgroundColor: this.isDark() ? '#1C1C1E' : $r('sys.color.ohos_id_color_background_transparent'),
          },
          contentStyle: {
            titleStyle: {
              mainTitleColor: this.isDark() ? '#FFFFFF' : $r('sys.color.font_primary'),
              subTitleColor: this.isDark() ? '#8E8E93' : $r('sys.color.font_secondary'),
            },
            menuStyle: {
              backgroundColor: this.isDark() ? '#2C2C2E' : $r('sys.color.comp_background_tertiary'),
              textColor: this.serverIp ? '#2FB04A' : (this.isDark() ? '#8E8E93' : '#999999')
            },
            backIconStyle: {
              backgroundColor: this.isDark() ? '#2C2C2E' : $r('sys.color.comp_background_tertiary'),
              iconColor: this.isDark() ? '#FFFFFF' : $r('sys.color.icon_primary')
            }
          }
        }
      },
      content: {
        // 标题栏内容设置
        title: { mainTitle: 'CodeFlash', subTitle: '剪贴板同步工具' },
        menu: {
          value: [{
            content: {
              label: this.serverIp ? '已连接' : '未连接',
              type: TextStyleMode.NORMAL,
              isEnabled: true,
              componentId: this.targetId,
              action: () => {
              }
            }
          }]
        }
      },
      avoidLayoutSafeArea: true
    })
    .backgroundColor(this.isDark() ? '#000000' : '#F5F7FA')
    .hideBackButton(true)
  }
}

