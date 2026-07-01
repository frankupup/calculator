import { QuotationRecord } from '../model/QuotationData'
import { QuotationRepository } from '../utils/QuotationRepository'
import { CalcResult, PriceCalculator } from '../utils/PriceCalculator'
import { HistoryRecord } from '../model/QuotationData'
import { DataStore } from '../utils/DataStore'
import { CurrencyType } from '../constants/Constants'

@Component
export struct QuotationTab {
  @Prop tabType: string = 'normal'
  @Link currency: string
  @Prop rateDate: string = ''
  @Prop rate: string = '0'
  @Link executeRate: string
  @State searchKeyword: string = ''
  @State searchResults: QuotationRecord[] = []
  @State showDropdown: boolean = false
  @State product: string = ''
  @State price: string = ''
  @State factory: string = ''
  @State packageType: string = ''
  @State containerType: string = ''
  @State quantity: string = ''
  @State surcharge: string = ''
  @State freight: string = ''
  @State profitRate: string = ''
  @State results: CalcResult[] = []

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Text(this.currency + ' Price ▼')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })
        .onClick(() => {
          this.toggleCurrency()
        })

        Row({ space: 8 }) {
          Text(this.rateDate)
            .fontSize(14)
            .fontColor('#666666')
          Text(this.rate)
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
          Text(this.currency)
            .fontSize(14)
            .fontColor('#666666')
          Text('执行汇率')
            .fontSize(13)
            .fontColor('#999999')
            .margin({ left: 8 })
          TextInput({ text: this.executeRate, placeholder: '汇率' })
            .type(InputType.Number)
            .fontSize(14)
            .width(70)
            .height(32)
            .padding({ left: 4, right: 4 })
            .border({ width: 1, color: '#CCCCCC', radius: 4 })
            .onChange((value: string) => {
              this.executeRate = value
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        Column() {
          TextInput({ text: this.searchKeyword, placeholder: '搜索产品' })
            .fontSize(14)
            .height(40)
            .padding({ left: 12, right: 12 })
            .border({ width: 1, color: '#CCCCCC', radius: 8 })
            .onChange((value: string) => {
              this.searchKeyword = value
              this.product = value
              this.doSearch()
            })
            .onFocus(() => {
              this.showAllProducts()
            })
            .onBlur(() => {
              setTimeout(() => {
                this.showDropdown = false
              }, 200)
            })
            .width('100%')

          if (this.showDropdown && this.searchResults.length > 0) {
            List({ space: 0 }) {
              ForEach(this.searchResults, (item: QuotationRecord, index: number) => {
                ListItem() {
                  Column() {
                    Text(item.product)
                      .fontSize(14)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)
                    Text(item.factory + ' | ' + item.containerType + ' | ' + item.packageType + ' | ' + item.quantity + '吨')
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ top: 2 })
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                  .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                  .onClick(() => {
                    this.product = item.product
                    this.factory = item.factory
                    this.packageType = item.packageType
                    this.containerType = item.containerType
                    this.quantity = item.quantity
                    this.surcharge = item.surcharge
                    this.searchKeyword = item.product
                    this.showDropdown = false
                  })
                }
                .border({ width: { bottom: 0.5 }, color: '#EEEEEE' })
              }, (item: QuotationRecord, index: number) => item.product + '_' + index.toString())
            }
            .width('100%')
            .constraintSize({ maxHeight: 280 })
            .backgroundColor(Color.White)
            .border({ width: 1, color: '#DDDDDD', radius: 4 })
            .borderRadius({ bottomLeft: 8, bottomRight: 8 })
            .shadow({ radius: 4, color: '#22000000', offsetY: 2 })
            .margin({ top: 2 })
            .scrollBar(BarState.Auto)
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        Row({ space: 8 }) {
          Column() {
            Text('价格')
              .fontSize(12)
              .fontColor('#999999')
            TextInput({ text: this.price, placeholder: '价格' })
              .type(InputType.Number)
              .fontSize(14)
              .height(40)
              .padding({ left: 4, right: 4 })
              .border({ width: 1, color: '#CCCCCC', radius: 4 })
              .onChange((value: string) => {
                this.price = value
              })
          }
          .layoutWeight(1)

          Column() {
            Text('工厂')
              .fontSize(12)
              .fontColor('#999999')
            TextInput({ text: this.factory, placeholder: '工厂' })
              .fontSize(14)
              .height(40)
              .padding({ left: 4, right: 4 })
              .border({ width: 1, color: '#CCCCCC', radius: 4 })
              .onChange((value: string) => {
                this.factory = value
              })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        Row({ space: 8 }) {
          Column() {
            Text('包装')
              .fontSize(12)
              .fontColor('#999999')
            TextInput({ text: this.packageType, placeholder: '包装' })
              .fontSize(14)
              .height(40)
              .padding({ left: 4, right: 4 })
              .border({ width: 1, color: '#CCCCCC', radius: 4 })
              .onChange((value: string) => {
                this.packageType = value
              })
          }
          .layoutWeight(1)

          Column() {
            Text('柜型')
              .fontSize(12)
              .fontColor('#999999')
            TextInput({ text: this.containerType, placeholder: '柜型' })
              .fontSize(14)
              .height(40)
              .padding({ left: 4, right: 4 })
              .border({ width: 1, color: '#CCCCCC', radius: 4 })
              .onChange((value: string) => {
                this.containerType = value
              })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        Row({ space: 8 }) {
          Column() {
            Text('数量')
              .fontSize(12)
              .fontColor('#999999')
            TextInput({ text: this.quantity, placeholder: '数量' })
              .type(InputType.Number)
              .fontSize(14)
              .height(40)
              .padding({ left: 4, right: 4 })
              .border({ width: 1, color: '#CCCCCC', radius: 4 })
              .onChange((value: string) => {
                this.quantity = value
              })
          }
          .layoutWeight(1)

          Column() {
            Text('杂费')
              .fontSize(12)
              .fontColor('#999999')
            TextInput({ text: this.surcharge, placeholder: '杂费' })
              .type(InputType.Number)
              .fontSize(14)
              .height(40)
              .padding({ left: 4, right: 4 })
              .border({ width: 1, color: '#CCCCCC', radius: 4 })
              .onChange((value: string) => {
                this.surcharge = value
              })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        Row({ space: 8 }) {
          Column() {
            Text('运费')
              .fontSize(12)
              .fontColor('#999999')
            TextInput({ text: this.freight, placeholder: '运费(USD)' })
              .type(InputType.Number)
              .fontSize(14)
              .height(40)
              .padding({ left: 4, right: 4 })
              .border({ width: 1, color: '#CCCCCC', radius: 4 })
              .onChange((value: string) => {
                this.freight = value
              })
          }
          .layoutWeight(1)

          Column() {
            Text('利润率')
              .fontSize(12)
              .fontColor('#999999')
            TextInput({ text: this.profitRate, placeholder: '利润率%' })
              .type(InputType.Number)
              .fontSize(14)
              .height(40)
              .padding({ left: 4, right: 4 })
              .border({ width: 1, color: '#CCCCCC', radius: 4 })
              .onChange((value: string) => {
                this.profitRate = value
              })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        Divider()
          .color('#EEEEEE')
          .margin({ top: 8, bottom: 8 })

        Button('计算')
          .width('90%')
          .height(44)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#007DFF')
          .borderRadius(8)
          .onClick(() => {
            this.calculate()
          })

        if (this.results.length > 0) {
          Column({ space: 8 }) {
            ForEach(this.results, (item: CalcResult, index: number) => {
              Row({ space: 4 }) {
                Text((3 + index).toString() + '个点:')
                  .fontSize(14)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
                Text('FOB ' + item.fobPrice.toString())
                  .fontSize(14)
                  .fontColor('#666666')
                Text(', CIF ' + item.cifPrice.toString())
                  .fontSize(14)
                  .fontColor('#666666')
                Text(', 利润 ' + item.profit.toString())
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
            }, (item: CalcResult, index: number) => index.toString())
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
        }
      }
      .width('100%')
    }
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
  }

  private toggleCurrency() {
    this.currency = this.currency === CurrencyType.USD ? CurrencyType.EUR : CurrencyType.USD
  }

  private showAllProducts() {
    let repo: QuotationRepository = QuotationRepository.getInstance()
    this.searchResults = repo.search(this.tabType, '')
    this.showDropdown = this.searchResults.length > 0
  }

  private doSearch() {
    let repo: QuotationRepository = QuotationRepository.getInstance()
    this.searchResults = repo.search(this.tabType, this.searchKeyword)
    this.showDropdown = this.searchKeyword.length > 0
  }

  private calculate() {
    let priceVal: number = parseFloat(this.price)
    let quantityVal: number = parseFloat(this.quantity)
    let surchargeVal: number = parseFloat(this.surcharge)
    let freightVal: number = parseFloat(this.freight)
    let execRate: number = parseFloat(this.executeRate)

    if (isNaN(priceVal) || isNaN(quantityVal) || isNaN(freightVal) || isNaN(execRate)) {
      return
    }
    if (isNaN(surchargeVal)) {
      surchargeVal = 0
    }

    let calcResults: CalcResult[] = []
    let profitRates: number[] = [4, 5, 6]
    let rebateRate: number = this.getRebateRate()

    for (let i = 0; i < profitRates.length; i++) {
      let pr: number = profitRates[i]
      let result: CalcResult
      if (this.tabType === 'usd') {
        result = PriceCalculator.calcUsd(priceVal, surchargeVal, quantityVal, freightVal, pr, execRate)
      } else {
        result = PriceCalculator.calcNormal(priceVal, rebateRate, surchargeVal, quantityVal, freightVal, pr, execRate)
      }
      calcResults.push(result)
    }

    this.results = calcResults
    this.saveToHistory(calcResults)
  }

  private getRebateRate(): number {
    if (this.tabType === 'zeroRebate') {
      return 0
    }
    return 0.13
  }

  private async saveToHistory(calcResults: CalcResult[]) {
    let store: DataStore = DataStore.getInstance()
    let mainResult: CalcResult = calcResults.length > 1 ? calcResults[1] : calcResults[0]
    let record: HistoryRecord = {
      id: Date.now().toString(),
      tabType: this.tabType,
      date: this.rateDate,
      rate: this.rate,
      executeRate: this.executeRate,
      currency: this.currency,
      product: this.product,
      price: this.price,
      factory: this.factory,
      packageType: this.packageType,
      containerType: this.containerType,
      quantity: this.quantity,
      surcharge: this.surcharge,
      freight: this.freight,
      profitRate: '5',
      fobPrice: mainResult.fobPrice.toString(),
      cfrPrice: mainResult.cfrPrice.toString(),
      cifPrice: mainResult.cifPrice.toString(),
      profit: mainResult.profit.toString()
    }
    await store.saveHistory(record)
  }
}
