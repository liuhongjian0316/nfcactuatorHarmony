/**
 * 选择产品页面
 */
import router from '@ohos.router'
import { CommonTitleBar } from '../../view/titlebar/Index'

@Entry
@Component
struct ChoiceProduct {
  @State products: {
    name: string,
    src: Resource,
    lock: Boolean,
    value: string,
  }[] = [
    {
      name: "U1单元物联网温度平衡阀",
      src: $r('app.media.u1_ns'),
      lock: true,
      value: "/pages/u1/Index",
    }, {
    name: "U2单元物联网温度平衡阀",
    src: $r('app.media.u2_ns'),
    lock: false,
    value: "/pages/u2/Index",
  }, {
    name: "R1户用物联网温度平衡阀",
    src: $r('app.media.r1_ns'),
    lock: false,
    value: "/pages/r1/Index",
  }, {
    name: "E1换热站物联网阀",
    src: $r('app.media.e1_ns'),
    lock: false,
    value: "/pages/e1/Index",
  }, {
    name: "直行程电动调节阀",
    src: $r('app.media.zxc_ns'),
    lock: false,
    value: "/pages/zxc/Index",
  }, {
    name: "电动球阀",
    src: $r('app.media.ball_ns'),
    lock: false,
    value: "/pages/ball/Index",
  }]

  handlerClickProduct(item: {
    name: string,
    src: Resource,
    lock: Boolean,
    value: string,
  }) {
    try {
      if(!item.lock) {
        router.pushUrl({
          url: item.value,
          params: {}
        })
      }
    } catch (e) {
      console.error("发生异常")
    }
  }

  build() {
    Column() {
      CommonTitleBar({
        title: "选择产品"
      })
      Scroll() {
        GridRow({
          columns: 4,
          gutter: { x: 12, y: 16 },
        }) {
          ForEach(this.products, (item) => {
            GridCol({ span: { xs: 2, sm: 2, md: 2, lg: 2 } }) {
              Stack({ alignContent: Alignment.TopEnd }) {
                Column() {
                  Image(item.src)
                    .objectFit(
                      ImageFit.Cover).width("100%")
                  Text(item.name)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .textAlign(TextAlign.Center)
                    .fontSize("52px")
                    .width('100%')
                    .height(40)
                    .lineHeight(20)
                    .backgroundColor("#ffa9a3a3")
                }.width("100%").clip(true).borderRadius({
                  topLeft: 10,
                  topRight: 10
                })

                if (item.lock) {
                  Image($r('app.media.lock')).width(24).width(24)
                    .margin({
                      top: 6, right: 6
                    })
                }
              }.onClick(() => {
                this.handlerClickProduct(item)
              })
            }
          })
        }.width("100%").padding({ left: 12, right: 12, top: 16, bottom: 16 })
      }.scrollable(ScrollDirection.Vertical)
      .width("100%")
      .layoutWeight(1)
      .backgroundColor("#f2f2f2")
    }
  }
}