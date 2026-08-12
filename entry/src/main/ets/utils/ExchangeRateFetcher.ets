import { http } from '@kit.NetworkKit'
import { CurrencyType, RateUrls } from '../constants/Constants'

export class RateInfo {
  date: string = ''
  rate: number = 0
}

export class ExchangeRateFetcher {
  // ===== 入口：新增结构化接口优先，失败退回原 HTML 解析 =====
  static async fetchRate(currency: string): Promise<RateInfo> {
    let info: RateInfo = await ExchangeRateFetcher.fetchStructured(currency)
    if (info.date.length > 0 && info.rate > 0) {
      return info
    }
    return ExchangeRateFetcher.fetchLegacy(currency)
  }

  // ===== 【新增】结构化接口 hq.sinajs.cn（中行外汇牌价）=====
  private static readonly FX_HOST: string = 'https://hq.sinajs.cn/list='

  static async fetchStructured(currency: string): Promise<RateInfo> {
    let code: string = currency === CurrencyType.EUR ? 'fx_seurcny' : 'fx_susdcny'
    let httpRequest = http.createHttp()
    try {
      let response = await httpRequest.request(ExchangeRateFetcher.FX_HOST + code, {
        method: http.RequestMethod.GET,
        header: { 'Referer': 'https://finance.sina.com.cn' },
        connectTimeout: 10000,
        readTimeout: 10000
      })
      let body: string = response.result as string
      return ExchangeRateFetcher.parseStructured(currency, body)
    } catch (e) {
      let info: RateInfo = new RateInfo()
      return info
    } finally {
      httpRequest.destroy()
    }
  }

  static parseStructured(currency: string, body: string): RateInfo {
    let info: RateInfo = new RateInfo()
    let match: RegExpExecArray | null = /"([^"]*)"/.exec(body)
    if (match === null) {
      return info
    }
    let fields: string[] = match[1].split(',')
    if (fields.length < 10) {
      return info
    }
    // 末位为日期 YYYY-MM-DD
    let date: string = fields[fields.length - 1].trim()
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      return info
    }
    // index 1 = 中行汇买价（元/单位），与旧 HTML 表首列（÷100 后）口径一致
    let rate: number = parseFloat(fields[1])
    if (isNaN(rate) || !ExchangeRateFetcher.isRateValid(currency, rate)) {
      return info
    }
    info.date = date
    info.rate = Math.round(rate * 100) / 100
    return info
  }

  // 区间校验：防止字段漂移/异常值污染结果
  private static isRateValid(currency: string, rate: number): boolean {
    let max: number = currency === CurrencyType.EUR ? 9.5 : 8.5
    return rate >= 5.5 && rate <= max
  }

  // ===== 【保留】原 HTML 页面正则解析 =====
  static async fetchLegacy(currency: string): Promise<RateInfo> {
    let url: string = currency === CurrencyType.EUR ? RateUrls.EUR_URL : RateUrls.USD_URL
    let httpRequest = http.createHttp()
    try {
      let response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'text/html' },
        connectTimeout: 15000,
        readTimeout: 15000
      })
      let body: string = response.result as string
      return ExchangeRateFetcher.parseRate(body)
    } catch (e) {
      let defaultInfo: RateInfo = new RateInfo()
      return defaultInfo
    } finally {
      httpRequest.destroy()
    }
  }

  static parseRate(html: string): RateInfo {
    let info: RateInfo = new RateInfo()
    let rowPattern: RegExp = new RegExp('<tr[^>]*>([\\s\\S]*?)</tr>', 'gi')
    let rowMatch: RegExpExecArray | null = rowPattern.exec(html)
    while (rowMatch !== null) {
      let rowContent: string = rowMatch[1]
      let dateMatch: RegExpExecArray | null = /(\d{4}-\d{2}-\d{2})/.exec(rowContent)
      if (dateMatch === null) {
        rowMatch = rowPattern.exec(html)
        continue
      }
      let numPattern: RegExp = new RegExp('\\b(\\d{3,4}\\.\\d{2,4})\\b', 'g')
      let numMatch: RegExpExecArray | null = numPattern.exec(rowContent)
      while (numMatch !== null) {
        let val: number = parseFloat(numMatch[1])
        if (val >= 600 && val <= 900) {
          info.date = dateMatch[1]
          info.rate = Math.round(val * 100) / 10000
          return info
        }
        numMatch = numPattern.exec(rowContent)
      }
      rowMatch = rowPattern.exec(html)
    }
    return info
  }
}
