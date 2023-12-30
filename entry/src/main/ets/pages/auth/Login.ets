/**
 * 登录页面
 */
import http from '@ohos.net.http'
import bundleManager from '@ohos.bundle.bundleManager'
import { DeviceRepository, DeviceResponse } from '../../common/repository/DeviceRepository'
import { BaseResponse, request } from '../../common/request/request'
import { showToast } from '../../common/toast/toast'
import { getUniqueId } from '../../common/utils/Unique'
import { verifyPhone } from '../../common/utils/verify'
import deviceInfo from '@ohos.deviceInfo'
import { Config, ConfigRepository, ConfigResponse } from '../../common/repository/ConfigRepository'
import router from '@ohos.router'

let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
let configRepository = new ConfigRepository()
let deviceRepository = new DeviceRepository()

@Entry
@Component
struct Login {
  @State phone: string = ""
  @State code: string = ""
  phoneController: TextInputController = new TextInputController()
  codeController: TextInputController = new TextInputController()
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ChoiceAreaDialog(),
    cancel: () => {
    },
    autoCancel: false,
    alignment: DialogAlignment.Bottom,
    gridCount: 999999999,
    customStyle: true
  })
  loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingProgressDialog(),
    cancel: () => {
    },
    autoCancel: false,
    alignment: DialogAlignment.Center,
    gridCount: 3,
    customStyle: true
  })
  @State smgBtnText: string = "获取"
  @State isGetCodeFlag: boolean = true
  @State hasGetCode: boolean = false
  @State versionCode: number = 1
  @State versionCodeName: string = ""


  // 自动计算状态 这种方式不太好 因为更改一次就会渲染一次 等官方什么支持类似vue的计算属性
  smsCodeEnableComputed(): boolean {
    return (verifyPhone(this.phone) && this.isGetCodeFlag)
  }

  loginBtnEnableComputed(): boolean {
    return (verifyPhone(this.phone) && this.code.length === 6 && this.hasGetCode)
  }

  smsCodeInterval = null

  // 获取短信验证码
  getSmsCode() {
    if (this.loadingDialogController != undefined) {
      this.loadingDialogController.open()
    }

    request({
      method: http.RequestMethod.GET,
      url: `nfc/getActivationCode?&oaid=${getUniqueId(globalThis.mainAbilityContext)}&phone=${this.phone}`,
      extraData: {},
      successCallBack: (response: BaseResponse) => {
        showToast("已下发")
        this.hasGetCode = true
        this.isGetCodeFlag = false
        let count = 60
        this.smsCodeInterval = setInterval(() => {
          this.smgBtnText = `${count}S`
          if (count === 0) {
            this.smgBtnText = "获取"
            if (this.smsCodeInterval != null) {
              clearInterval(this.smsCodeInterval)
              this.smsCodeInterval = null
              this.isGetCodeFlag = true
            }
          }
          count--
        }, 1000)
      },
      failCallBack: ({code,message}) => {
        if (code === 404) {
          showToast("手机号未注册")
        } else if (message === "The phone has been bound with an activation code") {
          showToast("设备已被绑定")
        } else {
          showToast(message)
        }
      },
      errorCallBack: (error: string) => {
        showToast("网络错误")
      },
      finallyCallBack: () => {
        if (this.loadingDialogController != undefined) {
          this.loadingDialogController.close()
        }
      },
    })
  }


  // 激活设备
  login() {

    if (this.loadingDialogController != undefined) {
      this.loadingDialogController.open()
    }

    let oaid = getUniqueId(globalThis.mainAbilityContext)
    if (oaid == null) {
      showToast("设备ID错误，请重启应用重新激活")
    } else {
      let device: DeviceResponse = {
        phone: this.phone,
        appMaker: deviceInfo.manufacture,
        appModal: deviceInfo.brand,
        androidVersion: deviceInfo.sdkApiVersion.toString(),
        androidVersionName: deviceInfo.osFullName,
        appName: "NFC执行器(鸿蒙版)",
        appVersion: this.versionCodeName,
        appVersionCode: this.versionCode.toString(),
        imei: oaid,
        oaid: oaid,
        activationCode: this.code
      }
      request({
        method: http.RequestMethod.POST,
        url: `nfc/bindAppInfo?&oaid=${oaid}&phone=${this.phone}`,
        extraData: device,
        successCallBack: (response: BaseResponse) => {
          const {data} = response
          const {activation, config} = data as {
            activation: DeviceResponse,
            config: ConfigResponse[]
          }
          // 更新本地数据库
          deviceRepository.clearTable()
          deviceRepository.insert(
            {
              appId: activation.appId,
              tel: activation.phone,
              code: activation.activationCode,
              beginTime: activation.firstUseTime,
              expireTime: activation.expireTime,
              exitTime: "",
              status: "1"
            }
          )
          // 同步本地数据
          this.syncConfig(config)
          // 跳转新页面标记
          this.startNewPage()
        },
        failCallBack: ({message}) => {
          if (message == "The phone has been bound with an activation code") {
            showToast("手机已经绑定其他设备")
          } else {
            showToast(message)
          }
        },
        errorCallBack: (error: string) => {
          showToast("暂无网络")
        },
        finallyCallBack: () => {
          if (this.loadingDialogController != undefined) {
            this.loadingDialogController.close()
          }
        },
      })
    }


  }

  getPhoneInfo() {
    try {
      bundleManager.getBundleInfoForSelf(bundleFlags).then((data) => {
        this.versionCode = data.versionCode
        this.versionCodeName = data.versionName
      }).catch(err => {
      });
    } catch (err) {
    }
  }

  // 同步数据
  syncConfig(configs: ConfigResponse[]) {
    configRepository.clearTable()
    // 组装数据
    let batchInsertData: Config[] = []
    configs.forEach((el: ConfigResponse) => {
      batchInsertData.push({
        id: el.id,
        keyname: el.keyName,
        status: el.status,
        level: el.level,
      })
    })
    configRepository.batchInsert(batchInsertData)
    const configsQuery = configRepository.selAll()

    let result = {} as any

    for (let index = 0; index < configsQuery.length; index++) {
      const element = batchInsertData[index];
      for (let spIndex = 0; spIndex < globalThis.staticProduct; spIndex++) {
        const spElement = globalThis.staticProduct[spIndex];
        if (element.keyname == spElement) {
          result[spElement] = { status: element.status, level: element.level }
        }
      }
    }
    globalThis.globalConfig = result
  }

  // 跳转到自动识别页面
  startNewPage() {
    router.replaceUrl({
      url: "pages/auto_recognition/Index"
    })
  }

  aboutToAppear() {
    this.getPhoneInfo()
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Column() {

            Divider().strokeWidth(1).color('#F1F3F5')

            // 国家/地区
            Row() {
              Text("国家/地区：").fontSize(16).fontColor(Color.Black)
              Row() {
                Text("中国大陆").fontSize(16).fontColor(Color.Black)
                Image($r('app.media.left'))
                  .width(56)
                  .height(56)
                  .padding(16)
                  .objectFit(
                    ImageFit.Contain)
                  .rotate({
                    angle: 180, // 官方bug 预览可以 单模拟器不起作用 真机不知道
                  })
              }.layoutWeight(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                if (
                  this.dialogController != undefined
                ) {
                  this.dialogController.open()
                }
              })
            }.alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
            .width("100%")
            .padding({ left: 16, right: 16, top: 0, bottom: 0 })

            Divider().strokeWidth(1).color('#F1F3F5')

            // 手机号码
            Row() {
              Text("手机号：").fontSize(16).fontColor(Color.Black)
              TextInput({ text: this.phone, placeholder: '请输入手机号码',
                controller: this.phoneController })
                .enterKeyType(EnterKeyType.Done)
                .placeholderColor(Color.Grey)
                .placeholderFont({ size: 14, weight: 400 })
                .caretColor(Color.Red)
                .backgroundColor(Color.Transparent)
                .type(InputType.PhoneNumber)
                .maxLength(11)
                .height(52)
                .fontSize(16)
                .fontColor(Color.Black)
                .onChange((value: string) => {
                  this.phone = value
                })
                .layoutWeight(1)
            }.alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding({ left: 16, right: 16, top: 0, bottom: 0 })

            Divider().strokeWidth(1).color('#F1F3F5')


            // 短信号码
            Row() {
              Text("验证码：").fontSize(16).fontColor(Color.Black)
              TextInput({ text: this.code, placeholder: '验证码',
                controller: this.codeController })
                .enterKeyType(EnterKeyType.Done)
                .placeholderColor(Color.Grey)
                .placeholderFont({ size: 14, weight: 400 })
                .caretColor(Color.Red)
                .backgroundColor(Color.Transparent)
                .height(52)
                .fontSize(16)
                .fontColor(Color.Black)
                .type(InputType.Number)
                .maxLength(6)
                .onChange((value: string) => {
                  this.code = value
                })
                .layoutWeight(1)
              Button(this.smgBtnText).backgroundColor("#FF3b30").enabled(this.smsCodeEnableComputed()).onClick(() => {
                this.getSmsCode()
              })
            }.alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding({ left: 16, right: 16, top: 0, bottom: 0 })

            Divider().strokeWidth(1).color('#F1F3F5')

          }

          Button("登录").width("80%").backgroundColor("#FF3b30")
            .enabled(this.loginBtnEnableComputed()).onClick(() => {
            this.login()
          })
        }.width("100%").height("100%").alignItems(HorizontalAlign.Center)
        .justifyContent(
          FlexAlign.SpaceAround
        )
      }.width("100%").height("100%")
    }.width("100%").height("100%")
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}


@CustomDialog
struct ChoiceAreaDialog {
  controller: CustomDialogController

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Button('取消')
          .onClick(() => {
            this.controller.close()
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button('确定')
          .onClick(() => {
            this.controller.close()
          }).backgroundColor(0xffffff).fontColor(0x3271ae)
      }.width("100%").padding(10)

      TextPicker({ range: ["中国大陆"], selected: 0 })
        .onChange((value: string, index: number) => {
        })
        .width("100%").layoutWeight(1)
        .margin({ bottom: 10 })
    }
    .width("100%")
    .height("30%")
    .backgroundColor("#ffffff")
    .borderRadius({ topLeft: 16, topRight: 16 })
    .clip(true)
  }
}

@CustomDialog
export struct LoadingProgressDialog {
  controller: CustomDialogController

  build() {
    Column() {
      LoadingProgress()
        .color("#FF3b30").width("100%").height("100%")
    }
    .width(100)
    .height(100)
    .backgroundColor("#fFFFFF")
    .borderRadius(10)
    .clip(true)
  }
}

