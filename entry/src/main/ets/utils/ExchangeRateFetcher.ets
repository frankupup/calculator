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
