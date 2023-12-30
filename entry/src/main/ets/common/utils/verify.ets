/**
 * 校验
 */

export const verifyPhone = (str?: string) => {
  if (str == null) {
    return false
  }

  if (str.trim() == '') {
    return false
  }

  var reg = /^1[3456789]\d{9}$/;

  return reg.test(str)
}
