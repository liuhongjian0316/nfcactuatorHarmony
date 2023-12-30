import router from '@ohos.router'

/**
 * 标题栏集合
 */
@Component
export struct CommonTitleBar {
  // 这玩意设计的 不支持 Resource 使用@Link 也不行
  @Prop title: string

  backToPre() {
    router.back()
  }

  build() {
    Stack() {
      Row() {
        Text(this.title).fontSize(22).fontColor("#333333").maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .backgroundColor("#FFFFFF")
      .width("100%")
      .height(60)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Row() {
        Image($r('app.media.left'))
          .width(60)
          .height(60)
          .padding(16)
          .objectFit(
            ImageFit.Contain)
          .onClick(this.backToPre)
      }
      .width("100%")
      .height(60)
      .alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start)
    }.width("100%")
    .height(60)
  }
}
