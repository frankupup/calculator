import { http } from '@kit.NetworkKit'
import { CurrencyType, RateUrls } from '../constants/Constants'

export class RateInfo {
  date: string = ''
  rate: number = 0
}

export class ExchangeRateFetcher {
  static async fetchRate(currency: string): Promise<RateInfo> {
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
    let cleaned: string = html.replace(/<script[\s\S]*?<\/script>/gi, '')
      .replace(/<style[\s\S]*?<\/style>/gi, '')
    let dateMatch: RegExpExecArray | null = /(\d{4}-\d{2}-\d{2})/.exec(cleaned)
    if (dateMatch === null) {
      return info
    }
    info.date = dateMatch[1]
    let afterDate: string = cleaned.substring(dateMatch.index + dateMatch[0].length)
    let numPattern: RegExp = new RegExp('\\b(\\d{3,4}\\.\\d{2,4})\\b', 'g')
    let numMatch: RegExpExecArray | null = numPattern.exec(afterDate)
    while (numMatch !== null) {
      let val: number = parseFloat(numMatch[1])
      if (val >= 600 && val <= 900) {
        info.rate = Math.round(val) / 100
        break
      }
      numMatch = numPattern.exec(afterDate)
    }
    return info
  }
}
