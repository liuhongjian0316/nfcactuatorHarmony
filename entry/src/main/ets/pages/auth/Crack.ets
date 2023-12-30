/**
 * 验证激活
 *
 */
import mediaquery from '@ohos.mediaquery'
import { logger } from '../../common/utils/Print';
import { getUniqueId } from '../../common/utils/Unique';
import {
  ConfigStatusAndLevel,
  Device,
  DeviceRepository,
  DeviceResponse
} from '../../common/repository/DeviceRepository';
import Request from '@system.request';
import { BaseResponse, request } from '../../common/request/request';
import http from '@ohos.net.http';
import { DEVICE_DISABLED, DEVICE_TIME_OUT, LOGIN_VALIDATION, PLEASE_NETWORK } from '../../common/constant/Constant';
import { Config, ConfigRepository, ConfigResponse } from '../../common/repository/ConfigRepository';
import router from '@ohos.router';
import { getRandomColor } from '../../common/utils/Random';

let portraitFunc = null;
let deviceRepository = new DeviceRepository()
let configRepository = new ConfigRepository()

@Entry
@Component
struct Crack {
  @State isLand: boolean = false
  listener = mediaquery.matchMediaSync('(orientation: landscape)');

  onPortrait(mediaQueryResult) {
    if (mediaQueryResult.matches) { // 若设备为横屏状态，更改相应的页面布局
      this.isLand = true
    } else {
      this.isLand = false
    }
  }

  checkCracked() {
    let list = deviceRepository.selAll()
    let appId = null
    let oaid = null
    let phone = null
    if (list && list.length && list.length > 0) {
      appId = list[0].appId ? list[0].appId : null
      oaid = getUniqueId(globalThis.mainAbilityContext)
      phone = list[0].tel ? list[0].tel : null
    }
    request({
      method: http.RequestMethod.GET,
      url: `nfc/checkPhoneActivated?appId=${appId}&oaid=${oaid}&phone=${phone}`,
      extraData: {},
      successCallBack: (response: BaseResponse) => {
        if (list.length > 0) {
          logger(DEVICE_DISABLED)
        }
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
      failCallBack: ({code, data, message}) => {
        try {
          if (code === 500) {
            const {activation, config}: {
              activation: DeviceResponse,
              config: ConfigResponse[]
            } = data
            // 更新本地信息
            deviceRepository.clearTable()
            deviceRepository.insert({
              appId: activation.appId,
              tel: "",
              code: "",
              beginTime: "",
              expireTime: "",
              exitTime: "",
              status: "2"
            })
            this.syncConfig(config)
            logger(DEVICE_DISABLED)
          }

          if (code === 600) {
            const {activation, config}: {
              activation: DeviceResponse,
              config: ConfigResponse[]
            } = data
            // 更新本地信息
            deviceRepository.clearTable()
            deviceRepository.insert({
              appId: activation.appId,
              tel: "",
              code: "",
              beginTime: "",
              expireTime: "",
              exitTime: "",
              status: "2"
            })
            this.syncConfig(config)
            logger(DEVICE_TIME_OUT)
          }

          if (code === 500500) {
            logger(LOGIN_VALIDATION)
            this.startToLogin()
          }
        } catch (e) {
          logger(e)
          logger("弹出错误错误信息")
        }
      },
      errorCallBack: (error: string) => {
        try {
          // 本地激活
          if (list.length == 0) {
            logger(LOGIN_VALIDATION)
            this.startToLogin()
          }
          if (list.length > 1) {
            logger(LOGIN_VALIDATION)
            this.startToLogin()
          }
          if (list.length === 1) {
            let device = list[0]
            if (device.appId != null && device.appId != "") {
              if (device.status === "1") {
                if (device.expireTime == null) {
                  logger(PLEASE_NETWORK)
                } else {
                  // 非法检测
                  const now = new Date()
                  if (new Date(device.expireTime).getTime() > now.getTime()) {
                    logger(PLEASE_NETWORK)
                  } else {
                    deviceRepository.insert(
                      {
                        appId: appId,
                        tel: "",
                        code: "",
                        beginTime: "",
                        expireTime: "",
                        exitTime: new Date().getTime().toString(),
                        status: ""
                      }
                    )
                  }
                }
              }

            }
          }
        } catch (e) {
          logger("弹出错误错误信息")
        }
      },
    })
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
    // 先不执行 等逻辑写完再执行
    return
    router.replaceUrl({
      url: "pages/auto_recognition/Index"
    })
  }
  // 跳转到登录页面
  startToLogin() {
    router.replaceUrl({
      url: "pages/auth/Login"
    })
  }

  aboutToAppear() {
    deviceRepository.init()
    portraitFunc = this.onPortrait.bind(this);
    this.listener.on('change', portraitFunc)
    this.checkCracked()
    // setTimeout(() => {
    //   router.replaceUrl({
    //     url: 'pages/auth/Crack',
    //   });
    // }, 1000)
  }

  build() {
    Column() {
      if (!this.isLand) {
        Row() {
          Image($r("app.media.logo_text")).width("80%")
        }.width('100%').layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }

      Row() {
        Image($r("app.media.logo_center")).height('500px')
      }.width('100%').layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      if (!this.isLand) {
        Row() {
          Image($r("app.media.logo_bottom_text")).width("80%")
        }.width('100%').layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}