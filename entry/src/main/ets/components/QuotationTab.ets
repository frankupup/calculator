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
  @State isSelecting: boolean = false
  private isFillingData: boolean = false
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
  @State calcTimestamp: number = 0
  @State showPackageDropdown: boolean = false
  @State isSelectingPackage: boolean = false
  @State packageResults: QuotationRecord[] = []
  private packageInputController: TextInputController = new TextInputController()
  private searchInputController: TextInputController = new TextInputController()

  build() {
    Column() {
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
          Text(parseFloat(this.rate).toFixed(2))
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
            .type(InputType.Normal)
            .fontSize(14)
            .width(80)
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
          TextInput({ text: this.searchKeyword, placeholder: '搜索产品', controller: this.searchInputController })
            .fontSize(14)
            .height(40)
            .padding({ left: 12, right: 12 })
            .border({ width: 1, color: '#CCCCCC', radius: 8 })
            .onChange((value: string) => {
              this.searchKeyword = value
              this.product = value
              if (this.isFillingData) {
                this.isFillingData = false
                return
              }
              if (this.searchKeyword.length === 0) {
                this.showAllProducts()
              } else {
                this.doSearch()
              }
            })
            .onFocus(() => {
              if (this.searchKeyword.length > 0) {
                this.doSearch()
              } else {
                this.showAllProducts()
              }
            })
            .onBlur(() => {
              if (!this.isSelecting) {
                this.showDropdown = false
              }
            })
            .width('100%')

          if (this.showDropdown && this.searchResults.length > 0) {
            List({ space: 0 }) {
              ForEach(this.searchResults, (item: QuotationRecord, index: number) => {
                ListItem() {
                  Row() {
                    Text(item.product)
                      .fontSize(14)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)
                    Text(' ' + item.factory + ' | ' + item.packageType + ' | ' + item.containerType + ' | ' + item.quantity + ' | ' + item.surcharge)
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                  .padding({ left: 12, right: 12, top: 10, bottom: 10 })
                  .onTouch((event: TouchEvent) => {
                    if (event.type === TouchType.Down) {
                      this.isSelecting = true
                    } else if (event.type === TouchType.Up) {
                      this.product = item.product
                      this.factory = item.factory
                      this.packageType = item.packageType
                      this.containerType = item.containerType
                      this.quantity = item.quantity
                      this.surcharge = item.surcharge
                      if (!this.surcharge) {
                        this.surcharge = '0'
                      }
                      this.isFillingData = true
                      this.searchKeyword = item.product
                      this.showDropdown = false
                      this.searchResults = []
                      this.searchInputController.stopEditing()
                    }
                  })
                }
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
              .type(InputType.NUMBER_DECIMAL)
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
          Stack({ alignContent: Alignment.TopStart }) {
            Column() {
              Text('包装')
                .fontSize(12)
                .fontColor('#999999')
              TextInput({ text: this.packageType, placeholder: '包装', controller: this.packageInputController })
                .fontSize(14)
                .height(40)
                .padding({ left: 4, right: 4 })
                .border({ width: 1, color: '#CCCCCC', radius: 4 })
                .onChange((value: string) => {
                  this.packageType = value
                })
                .onFocus(() => {
                  // 如果正在选择列表项，则不显示下拉框
                  if (!this.isSelectingPackage) {
                    // 如果包装不为空且产品不为空，显示包装列表
                    if (this.packageType.length > 0 && this.product.length > 0) {
                      this.packageResults = QuotationRepository.getInstance().getPackagesByProduct(this.tabType, this.product)
                      this.showPackageDropdown = this.packageResults.length > 0
                    }
                  }
                })
                .onBlur(() => {
                  // 延迟隐藏下拉框，让点击事件有机会触发
                  setTimeout(() => {
                    this.showPackageDropdown = false
                    this.isSelectingPackage = false
                  }, 150)
                })
            }
            .width('100%')

            // 包装下拉列表（悬浮显示）
            if (this.showPackageDropdown && this.packageResults.length > 0) {
              Column() {
                ForEach(this.packageResults, (item: QuotationRecord, index: number) => {
                  Row() {
                    Text(item.packageType)
                      .fontSize(14)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .height(40)
                  .padding({ left: 8, right: 8 })
                  .backgroundColor(Color.White)
                  .onClick(() => {
                    this.isSelectingPackage = true
                    this.packageType = item.packageType
                    // 根据产品和包装填充柜型、数量、杂费
                    let record: QuotationRecord | null = QuotationRepository.getInstance().getFirstByProductAndPackage(this.tabType, this.product, item.packageType)
                    if (record !== null) {
                      this.containerType = record.containerType
                      this.quantity = record.quantity
                      this.surcharge = record.surcharge
                      if (!this.surcharge) {
                        this.surcharge = '0'
                      }
                    }
                    // 关闭下拉框
                    this.showPackageDropdown = false
                    // 让输入框失去焦点
                    this.packageInputController.stopEditing()
                    // 延迟重置选择状态
                    setTimeout(() => {
                      this.isSelectingPackage = false
                    }, 200)
                  })
                }, (item: QuotationRecord, index: number) => index.toString())
              }
              .width('100%')
              .constraintSize({ maxHeight: 200 })
              .backgroundColor(Color.White)
              .border({ width: { left: 1, right: 1, bottom: 1 }, color: '#E0E0E0', radius: { bottomLeft: 4, bottomRight: 4 } })
              .shadow({ radius: 4, color: '#1F000000', offsetY: 2 })
              .position({ x: 0, y: 56 })
              .zIndex(999)
            }
          }
          .layoutWeight(1)
          .height(56)

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
        .zIndex(10)
        .width('100%')
        .padding({ left: 16, right: 16 })

        Row({ space: 8 }) {
          Column() {
            Text('数量')
              .fontSize(12)
              .fontColor('#999999')
            TextInput({ text: this.quantity, placeholder: '数量' })
              .type(InputType.NUMBER_DECIMAL)
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
              .type(InputType.NUMBER_DECIMAL)
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
            TextInput({ text: this.freight, placeholder: this.currency === CurrencyType.USD ? 'USD' : 'EURO' })
              .type(InputType.NUMBER_DECIMAL)
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
            TextInput({ text: this.profitRate, placeholder: '%' })
              .type(InputType.NUMBER_DECIMAL)
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
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)

      if (this.results.length > 0) {
        Column({ space: 8 }) {
          ForEach(this.results, (item: CalcResult, index: number) => {
            Row({ space: 4 }) {
              Text(item.profitRate.toString() + '个点:')
                .fontSize(14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
              Text('FOB ' + item.fobPrice.toString())
                .fontSize(14)
                .fontColor('#666666')
              Text(', CFR ' + item.cfrPrice.toString())
                .fontSize(14)
                .fontColor('#666666')
              Text(', CIF ' + item.cifPrice.toString())
                .fontSize(14)
                .fontColor('#666666')
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }, (item: CalcResult, index: number) => `${item.profitRate}_${this.calcTimestamp}`)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      }
    }
    .width('100%')
    .height('100%')
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
    let profitRateVal: number = parseFloat(this.profitRate)

    if (isNaN(priceVal) || isNaN(quantityVal) || isNaN(freightVal) || isNaN(execRate) || isNaN(profitRateVal)) {
      return
    }
    if (isNaN(surchargeVal)) {
      surchargeVal = 0
    }

    let calcResults: CalcResult[] = []
    let profitRates: number[] = [profitRateVal - 1, profitRateVal, profitRateVal + 1]
    // FOB = 价格/1.13/汇率 + 杂费/汇率/数量
    let baseCost: number = priceVal / 1.13 / execRate + surchargeVal / execRate / quantityVal

    for (let i = 0; i < profitRates.length; i++) {
      let pr: number = profitRates[i]
      // FOB = baseCost * (1 + 利润率/100), 向上取整
      let fob: number = Math.ceil(baseCost * (1 + pr / 100))
      // CFR = FOB + 运费/数量, 向上取整
      let cfr: number = Math.ceil(fob + freightVal / quantityVal)
      // CIF = CFR + CFR*1.1*0.0005/数量, 向上取整
      let cif: number = Math.ceil(cfr + cfr * 1.1 * 0.0005 / quantityVal)
      let result: CalcResult = new CalcResult()
      result.fobPrice = fob
      result.cfrPrice = cfr
      result.cifPrice = cif
      result.profit = fob - Math.ceil(baseCost)
      result.profitRate = pr
      calcResults.push(result)
    }

    this.results = calcResults
    this.calcTimestamp = Date.now()
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
      profitRate: this.profitRate,
      fobPrice: mainResult.fobPrice.toString(),
      cfrPrice: mainResult.cfrPrice.toString(),
      cifPrice: mainResult.cifPrice.toString(),
      profit: mainResult.profit.toString()
    }
    await store.saveHistory(record)
  }
}
