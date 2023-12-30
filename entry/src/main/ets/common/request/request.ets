import http from '@ohos.net.http';
import { baseUrl, getCommonHeader, showRequestLog } from '../config/ProjectConfig';
import { printRequestLog } from '../utils/Print';

let httpRequest = http.createHttp();

export interface BaseResponse {
  data?: any,
  code: number,
  message: string
}

// 通用请求封装
export function request(
    {
      method = http.RequestMethod.GET,
      url =  '',
      extraData= {},
      successCallBack = (response: BaseResponse) => {
      },
      failCallBack = (response: BaseResponse) => {
      },
      errorCallBack = (error: string) => {
      },
      finallyCallBack = () => {
      },
    }: {
      method?: http.RequestMethod,
      url?: string,
      extraData?: any,
      successCallBack: Function,
      failCallBack: Function,
      errorCallBack?: Function,
      finallyCallBack?: Function,
    },
) {
  const rq = {
    method: http.RequestMethod.GET,
    extraData: extraData || {},
    connectTimeout: 60000,
    readTimeout: 60000,
    header: getCommonHeader(),
  }
  rq.method = method
  let promise = httpRequest.request(`${baseUrl}/${url}`,
    rq
  )

  /**打印日志**/
  if (showRequestLog) {
    printRequestLog("---------------请求开始---------------------")
    printRequestLog(`请求数据：${JSON.stringify(extraData)}`)
    printRequestLog(`BODY数据：${JSON.stringify(extraData)}`)
    printRequestLog(`URL数据：${JSON.stringify(getQueryParams(url))}`)
  }
  /**打印日志**/

  promise.then((responseData) => {
    if (responseData.responseCode === http.ResponseCode.OK) {
      const {code, message, data} = JSON.parse(responseData.result.toString()) as BaseResponse
      if (code === 0) {
        successCallBack({ code, message, data })
      } else {
        failCallBack({ code, message, data })
      }
    }

    /**打印日志**/
    try {
      if (showRequestLog) {
        printRequestLog(`请求响应头：${JSON.stringify(responseData.header)}`)
        printRequestLog(`请求响应码：${responseData.responseCode}`)
        printRequestLog(`请求响应结果：${responseData.result}`)
        printRequestLog(`请求响应结果类型：${responseData.resultType}`)
        printRequestLog(JSON.stringify(responseData.responseCode.toString()))
      }
    } catch (e) {

    }
    /**打印日志**/


  }).catch((err) => {
    /**打印日志**/
    if (showRequestLog) {
      printRequestLog(err.toString())
    }
    /**打印日志**/

    if (errorCallBack != null) {
      errorCallBack(JSON.stringify(err))
    }
  }).finally(() => {

    if (finallyCallBack != null) {
      finallyCallBack()
    }

    /**打印日志**/
    if (showRequestLog) {
      printRequestLog("---------------请求结束---------------------")
    }
    /**打印日志**/
  })
}


// 从URL中截取数据
function getQueryParams(url:string) {
  const params = {};
  const urlParts = url.split('?');

  if (urlParts.length > 1) {
    const queryString = urlParts[1];
    const pairs = queryString.split('&');

    for (const pair of pairs) {
      const [key, value] = pair.split('=');
      params[decodeURIComponent(key)] = decodeURIComponent(value || '');
    }
  }

  return params;
}





