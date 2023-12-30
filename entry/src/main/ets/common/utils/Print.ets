import hilog from "@ohos.hilog"


/**
 * 调试输入信息
 */


/**
 * 打印信息
 * @param str
 */
export function logger(str: any) {
  console.log("调试信息", str)
}

/**
 * 打印请求相关信息
 * @param string
 */
export function printRequestLog(log: string) {
  hilog.info(0x0000, '请求信息', '%{public}s', log);
}