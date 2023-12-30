/**
 * NFC操作工具类
 */
import tag from '@ohos.nfc.tag'

/**
 * 是否支持新芯片
 */
export const isSupportNewTag = (tagInfo:any): boolean =>  {
  return tag.getMifareUltralight(tagInfo) == null
}