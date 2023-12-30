/**
 * 项目配置
 */


/**项目请求地址**/
export const baseUrl = "http://192.168.198.102:9999/iot-app-serve/app_client"
// export const baseUrl = "http://192.168.2.29:9999/iot-app-serve/app_client"

/**项目请求头**/
export function getCommonHeader() {
  var token = "" // 自己获取吧
  return {
    'Content-Type': 'application/json',
    'X-Api-Key': "1702431570548-o-w76ewU5N45hGM49KhBEw",
    'X-Api-Key-Data': "PuDdfsgLsUzq6x+cqeJqxToOrxMwwm9O0iLpwjnVk0xFRoGN4aSkxxwHIKhDk4nDnmTfjjAgFrWIV5HlKX6ZZA5VY+lgAmjZT/HVKxhIqLBihdEXUHXxJCSY2NRQegBsF3py6/xW9VuovXPhqW5ojXFAreOfcimVBsewgIF+h/1eQ88o4S4WJyHFcDJF3ZChZcEJ7M0NQv19xxEIQliqfvXosEcKmCWHA7FA/LyPcxJQobgyNCFhnTPLe9bgLR9RdwXbjo+AoYKM+oWGMkhZ12FfkMAU/KaRRcSYEUg5qVE7HW6cqePVUBVcdMM0BLLELfFRhaaMXy/5YhjvBf+F2w==",
    'X-Api-Key-Source': "web",
    // 'Authorization': `Bearer ${token}`
  }
}

/**请求打印数据**/
export const showRequestLog = true