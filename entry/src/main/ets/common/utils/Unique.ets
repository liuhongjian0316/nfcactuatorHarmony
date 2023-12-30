/**
 * 各种 唯一
 */

import fs from '@ohos.file.fs';
import util from '@ohos.util';
import deviceInfo from '@ohos.deviceInfo'

/**
 * 生成uuid
 * @returns
 */
function generateDeviceId(): string {
  return util.generateRandomUUID(true);
}


/**
 * 设备唯一码 解决方案
 * 方案一：生成唯一ID 写入文件 不可取 无法读取和写入外部存储
 * 方案二：根据设备信息 组合成唯一ID 尝试中
 * 方案三：暂时使用 deviceInfo.udid 待验证
 *
 */
export function getUniqueId(context: Context) {
  return deviceInfo.udid
}

