/**
 * 程序入口
 */
import router from '@ohos.router'
import mediaquery from '@ohos.mediaquery'
import { request } from '../common/request/request';
import http from '@ohos.net.http';
import { showToast } from '../common/toast/toast';
import bundleManager from '@ohos.bundle.bundleManager';

let context = globalThis.mainAbilityContext
let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
let portraitFunc = null;

@Preview
@Entry
@Component
struct Index {
  @State isLand: boolean = false
  @State versionCode: number = 1
  @State newVersion?: {
    id: string | number
    name: string
    url: string
    type: string
    platform: string
    versionCode: number
    versionName: string
    versionDesc: string
  } = null
  listener = mediaquery.matchMediaSync('(orientation: landscape)');

  onPortrait(mediaQueryResult) {
    if (mediaQueryResult.matches) { // 若设备为横屏状态，更改相应的页面布局
      this.isLand = true
    } else {
      this.isLand = false
    }
  }

  getAppSelfInfo() {
    try {
      bundleManager.getBundleInfoForSelf(bundleFlags).then((data) => {
        this.versionCode = data.versionCode
      }).catch(err => {
      });
    } catch (err) {
    }
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: UpdateDialog({
      versionInfo: this.newVersion,
      cancel: this.exitApp,
      confirm: this.exitApp,
    }),
    cancel: () => {
    },
    autoCancel: false,
    alignment: DialogAlignment.Center,
    gridCount: 10,
    customStyle: false
  })

  // 检查更新
  checkUpdate() {
    request(
      {
        method: http.RequestMethod.GET,
        url: "v1/app/version/latest?type=1&platform=2",
        extraData: {},
        successCallBack: ({data}) => {
          this.newVersion = data
          if (this.newVersion != null
          && this.dialogController != undefined
          && this.versionCode < this.newVersion.versionCode
          ) {
            this.dialogController.open()
          }
        },
        failCallBack: (data) => {
          console.log("请求失败", data.message)
        },
        errorCallBack: (err) => {
          showToast("网络错误")
          console.log("未知错误", JSON.stringify(err))
        },
        finallyCallBack: () => {

        }
      }
    )
  }

  exitApp() {
    // 退出应用
    try {
      context.terminateSelf();
    } catch (e) {
    }
  }

  aboutToAppear() {

    this.getAppSelfInfo()
    this.checkUpdate()
    portraitFunc = this.onPortrait.bind(this);
    this.listener.on('change', portraitFunc)
    setTimeout(() => {
      router.replaceUrl({
        url: 'pages/auth/Crack',
      });
    }, 1000)
  }

  aboutToDisappear() {
    this.listener.off('change', portraitFunc)
    this.dialogController = undefined
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


/**
 * 提示新版本弹框
 */
@CustomDialog
struct UpdateDialog {
  @Link versionInfo: {
    id: string | number
    name: string
    url: string
    type: string
    platform: string
    versionCode: number
    versionName: string
    versionDesc: string
  }
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void

  build() {
    Column() {
      Text('提示').fontSize(20).margin({ top: 10, bottom: 10 })
      Text('已检测到新版本的更新').fontSize(18)
      Text('请到应用市场内更新安装').fontSize(18)

      Row() {
        Text(`${this.versionInfo?.versionDesc}`).fontSize(16)
      }.padding({ top: 10, bottom: 10 })

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            this.controller.close()
            this.cancel()
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button('确定')
          .onClick(() => {
            this.controller.close()
            this.confirm()
          }).backgroundColor(0xffffff).fontColor(0x3271ae)
      }.margin({ bottom: 10 })
    }
  }
}
