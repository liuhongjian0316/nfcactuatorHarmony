/**
 * 自动页面
 */
import router from '@ohos.router'
import { getRandomColor } from '../../common/utils/Random'
import nfcController from '@ohos.nfc.controller'
import tag from '@ohos.nfc.tag'
import { isSupportNewTag } from '../../common/utils/Nfc'
import Request from '@system.request'
import { request } from '../../common/request/request'
import http from '@ohos.net.http'
import promptAction from '@ohos.promptAction'
import { showToast } from '../../common/toast/toast'

@Entry
@Component
struct AutoPage {

  // 进入手动选择产品
  goToChoiceProduct() {
    router.pushUrl({
      url: 'pages/choice_product/Index',
      params: {}
    })
  }

  // 检查NFC
  checkNfc() {
    let isSupportNfc = canIUse("SystemCapability.Communication.NFC.Core")
    if (isSupportNfc) {
      let state = nfcController.isNfcOpen()
      if (!state) {
        AlertDialog.show(
          {
            title: '提示',
            message: '本应用需要打开NFC功能，是否打开NFC功能？',
            autoCancel: false,
            alignment: DialogAlignment.Center,
            gridCount: 10,
            primaryButton: {
              value: '取消',
              action: () => {

              }
            },
            secondaryButton: {
              value: '确定',
              action: () => {
                this.openNFC()
              }
            },
            cancel: () => {

            }
          }
        )
      }
    } else {
      AlertDialog.show(
        {
          title: '提示',
          message: '你的设备不支持NFC功能，不支持使用该应用的所有功能',
          autoCancel: false,
          alignment: DialogAlignment.Center,
          gridCount: 10,
          confirm: {
            value: "确定",
            action: () => {

            }
          },
          cancel: () => {

          }
        }
      )
    }
  }
  // 打开NFC
  openNFC() {
    try {
      let res = nfcController.enableNfc()
    } catch (e) {
      AlertDialog.show(
        {
          title: '提示',
          message: `打开NFC异常(${e.message})`,
          autoCancel: false,
          alignment: DialogAlignment.Center,
          gridCount: 10,
          confirm: {
            value: "确定",
            action: () => {
            }
          },
          cancel: () => {
          }
        }
      )
      console.error("打开NFC异常", e.message)
    }
  }
  // 自动识别逻辑
  auto() {
    if (isSupportNewTag(null)) {
      // 新芯片
    } else {
      // 老芯片
    }
  }

  aboutToAppear() {
    // checkNfc
    this.checkNfc()
    // auto
    // this.auto()


  }

  build() {
    Column() {
      Image($r('app.media.nfc_auto'))
        .width("100%")
        .height("80%")
      Column() {
        LoadingText()
        Text($r('app.string.manually_select_products')).onClick(() => {
          this.goToChoiceProduct()
        }).fontColor("#ff3981c8").fontSize("56px").margin({
          top: 30
        })
      }.width("100%").layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

let interval = null;

@Component
struct LoadingText {
  @State textColor: string = getRandomColor()

  aboutToAppear() {
    interval = setInterval(() => {
      this.textColor = getRandomColor()
    }, 1500)
  }

  aboutToDisappear() {
    if (interval != null) {
      clearInterval(interval)
      interval = null
    }
  }

  build() {
    Row() {
      Text($r('app.string.auto_recognition_text_ing')).fontSize("48px")
        .fontColor(this.textColor)
        .animation({
          duration: 3000,
          curve: Curve.EaseOut,
          iterations: -1,
          playMode: PlayMode.Alternate,
        })
    }
  }
}