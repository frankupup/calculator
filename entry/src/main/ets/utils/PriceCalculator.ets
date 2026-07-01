export class PriceCalculator {
  static calcNormal(
    factoryPrice: number,
    rebateRate: number,
    surcharge: number,
    quantity: number,
    freight: number,
    profitRate: number,
    executeRate: number
  ): CalcResult {
    let unitSurcharge: number = surcharge / quantity
    let unitFreight: number = freight * executeRate / quantity
    let rebate: number = factoryPrice * rebateRate / (1 + rebateRate)
    let basePrice: number = factoryPrice - rebate + unitSurcharge
    let fob: number = basePrice * (1 + profitRate / 100)
    let cfr: number = fob + unitFreight
    let cif: number = cfr * 1.0011
    let profit: number = fob - basePrice
    let result: CalcResult = new CalcResult()
    result.fobPrice = Math.round(fob * 100) / 100
    result.cfrPrice = Math.round(cfr * 100) / 100
    result.cifPrice = Math.round(cif * 100) / 100
    result.profit = Math.round(profit * 100) / 100
    return result
  }

  static calcUsd(
    factoryPrice: number,
    surcharge: number,
    quantity: number,
    freight: number,
    profitRate: number,
    executeRate: number
  ): CalcResult {
    let unitSurchargeUsd: number = surcharge / executeRate / quantity
    let unitFreightUsd: number = freight / quantity
    let basePrice: number = factoryPrice + unitSurchargeUsd
    let fob: number = basePrice * (1 + profitRate / 100)
    let cfr: number = fob + unitFreightUsd
    let cif: number = cfr * 1.0011
    let profit: number = fob - basePrice
    let result: CalcResult = new CalcResult()
    result.fobPrice = Math.round(fob * 100) / 100
    result.cfrPrice = Math.round(cfr * 100) / 100
    result.cifPrice = Math.round(cif * 100) / 100
    result.profit = Math.round(profit * 100) / 100
    return result
  }

  static calcRmb(
    factoryPrice: number,
    rebateRate: number,
    surcharge: number,
    quantity: number,
    freight: number,
    profitRate: number,
    executeRate: number
  ): CalcResult {
    let unitSurcharge: number = surcharge / quantity
    let unitFreight: number = freight * executeRate / quantity
    let rebate: number = factoryPrice * rebateRate / (1 + rebateRate)
    let basePrice: number = factoryPrice - rebate + unitSurcharge
    let fob: number = basePrice * (1 + profitRate / 100)
    let cfr: number = fob + unitFreight
    let cif: number = cfr * 1.0011
    let profit: number = fob - basePrice
    let result: CalcResult = new CalcResult()
    result.fobPrice = Math.round(fob * 100) / 100
    result.cfrPrice = Math.round(cfr * 100) / 100
    result.cifPrice = Math.round(cif * 100) / 100
    result.profit = Math.round(profit * 100) / 100
    return result
  }
}

export class CalcResult {
  fobPrice: number = 0
  cfrPrice: number = 0
  cifPrice: number = 0
  profit: number = 0
}
