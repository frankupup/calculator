export class TabType {
  static readonly NORMAL: string = 'normal'
  static readonly ZERO_REBATE: string = 'zeroRebate'
  static readonly USD: string = 'usd'
  static readonly RMB: string = 'rmb'
}

export class CurrencyType {
  static readonly USD: string = '美元'
  static readonly EUR: string = '欧元'
}

export class ContainerOptions {
  static readonly ITEMS: string[] = ['20GP', '40GP', '40HQ', 'TANK']
}

export class RateUrls {
  static readonly USD_URL: string = 'https://biz.finance.sina.com.cn/forex/forex.php?qq-pf-to=pcqq.c2c'
  static readonly EUR_URL: string = 'https://biz.finance.sina.com.cn/forex/forex.php?startdate=2012-01-01&money_code=EUR&type=0'
}
