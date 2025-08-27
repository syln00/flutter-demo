现在我需要把一个小程序项目迁移到这个flutter项目中，先从登录开始，
小程序的请求基本路径baseurl: const DEV_API_URL = 'https://www.shuguoren.com/tmh-dev/bapp-api'
登录接口路径为
/**
 * 使用账号密码登录
 */
export function userLogin(data) {
  return api.post('/system/auth/login', data, { login: false })
}

参数 formData = {
		   "username": userInfo.value.username,
		   "password": encrypt(userInfo.value.prepassword),
		 }
     其中加密方法如下


import { JSEncrypt } from 'jsencrypt'
const KEY  = `MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm1ZR35L4jZu9C7Gf9J9MS00XYvw5wp1TMTSqqTzU+NDMmfXy2kXJieruxXUeSKOvo/U0Se1iwwq1eeq7skyYMuP5SrMLgw89fqWBbJjQ6rCKMF6eS+oHPODLy1D7Z4mYs6hTsdnkk2wgAesCnGbVkyHN4nG3FzPxy2ML9NNQU630dIhG2ufh9lGwX4WMRNiAG6AXhHiC4P1+sQrJB6t65QNS+se3x3v+hf53xWf98QOtlPFDznElZWODfaGedIi8C+Xbd8qkTq/NNy3Buv/kK8d4vlG413GO3qCkZTSI+mGCHboA+mzumcuHaUHo6RBkdfYI7Zwi5mTEYCLUjbfoQQIDAQAB`;
export function encrypt(data) {
  try {
    const encryptor = new JSEncrypt()
    encryptor.setPublicKey(KEY) // 设置公钥
    return encryptor.encrypt(data) // 对数据进行加密
    // 统一公钥格式为数组 [xHex, yHex]
    // const pubKeyArr = Array.isArray(publicKey)
    //   ? publicKey
    //   : [publicKey.x.replace(/^0x/i, ''), publicKey.y.replace(/^0x/i, '')]; // 去除可能的0x前缀

    // 加密：明文转为UTF-8字节数组，加密后返回十六进制字符串
  } catch (error) {
    throw new Error('加密失败');
  }
}

返回参数包括一些用户基本信息和accessToken和refreshToken
现在把这个功能迁移过来
