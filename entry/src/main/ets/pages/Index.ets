import { TabType, CurrencyType } from '../constants/Constants'
import { QuotationTab } from '../components/QuotationTab'
import { HistoryView } from '../components/HistoryView'
import { ExchangeRateFetcher, RateInfo } from '../utils/ExchangeRateFetcher'
import { QuotationRepository } from '../utils/QuotationRepository'
import { DataStore } from '../utils/DataStore'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State @Watch('onCurrencyChange') currency: string = CurrencyType.USD
  @State rateDate: string = ''
  @State rate: string = '0'
  // 为每个tab维护独立的汇率状态
  @State executeRateNormal: string = '0'
  @State executeRateZeroRebate: string = '0'
  @State executeRateUsd: string = '0'
  @State executeRateRmb: string = '0'
  @State rateLoaded: boolean = false

  async aboutToAppear() {
    let context = this.getUIContext().getHostContext() as Context
    await DataStore.getInstance().init(context)
    await QuotationRepository.getInstance().loadData(context)
    this.fetchRate()
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          QuotationTab({
            tabType: TabType.NORMAL,
            currency: $currency,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRateNormal
          })
        }
        .tabBar('正常报价')

        TabContent() {
          QuotationTab({
            tabType: TabType.ZERO_REBATE,
            currency: $currency,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRateZeroRebate
          })
        }
        .tabBar('0退税')

        TabContent() {
          QuotationTab({
            tabType: TabType.USD,
            currency: $currency,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRateUsd
          })
        }
        .tabBar('美元报价')

        TabContent() {
          QuotationTab({
            tabType: TabType.RMB,
            currency: $currency,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRateRmb
          })
        }
        .tabBar('人民币报价')

        TabContent() {
          HistoryView()
        }
        .tabBar('历史')
      }
      .scrollable(true)
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.currentIndex = index
        if (index < 4) {
          this.fetchRate()
        }
      })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private async fetchRate() {
    this.rateLoaded = false
    
    // 获取当前tab的执行汇率
    let currentExecuteRate: string = this.getCurrentExecuteRate()
    
    // 如果当前tab的执行汇率已经有值，则保留不变，不再重新获取
    if (currentExecuteRate !== '0' && currentExecuteRate.length > 0) {
      this.rateLoaded = true
      return
    }
    
    let info: RateInfo = await ExchangeRateFetcher.fetchRate(this.currency)
    if (info.date.length > 0) {
      this.rateDate = info.date
      this.rate = info.rate.toFixed(2)
      // 更新当前tab的执行汇率
      this.setCurrentExecuteRate(info.rate.toFixed(2))
    }
    this.rateLoaded = true
  }
  
  // 获取当前tab的执行汇率
  private getCurrentExecuteRate(): string {
    switch (this.currentIndex) {
      case 0:
        return this.executeRateNormal
      case 1:
        return this.executeRateZeroRebate
      case 2:
        return this.executeRateUsd
      case 3:
        return this.executeRateRmb
      default:
        return '0'
    }
  }
  
  // 设置当前tab的执行汇率
  private setCurrentExecuteRate(value: string) {
    switch (this.currentIndex) {
      case 0:
        this.executeRateNormal = value
        break
      case 1:
        this.executeRateZeroRebate = value
        break
      case 2:
        this.executeRateUsd = value
        break
      case 3:
        this.executeRateRmb = value
        break
    }
  }

  private onCurrencyChange() {
    this.fetchRate()
  }
}
