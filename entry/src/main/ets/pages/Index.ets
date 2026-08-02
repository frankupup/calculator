import { TabType, CurrencyType } from '../constants/Constants'
import { QuotationTab } from '../components/QuotationTab'
import { HistoryView } from '../components/HistoryView'
import { ExchangeRateFetcher, RateInfo } from '../utils/ExchangeRateFetcher'
import { QuotationRepository } from '../utils/QuotationRepository'
import { DataStore } from '../utils/DataStore'
import { hdsMaterial, HdsTabs, HdsTabsController } from '@kit.UIDesignKit'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State rateDate: string = ''
  @State rate: string = '0'
  // 为每个tab维护独立的币种状态
  @State @Watch('onCurrencyNormalChange') currencyNormal: string = CurrencyType.USD
  @State @Watch('onCurrencyZeroRebateChange') currencyZeroRebate: string = CurrencyType.USD
  @State @Watch('onCurrencyUsdChange') currencyUsd: string = CurrencyType.USD
  @State @Watch('onCurrencyRmbChange') currencyRmb: string = CurrencyType.USD
  // 为每个tab维护独立的汇率状态
  @State executeRateNormal: string = '0'
  @State executeRateZeroRebate: string = '0'
  @State executeRateUsd: string = '0'
  @State executeRateRmb: string = '0'
  @State rateLoaded: boolean = false

  @Builder
  customTabBarBuilder(index: number, name: string) {
    Text(name)
      .fontSize(16)
      .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
  }

  async aboutToAppear() {
    let context = this.getUIContext().getHostContext() as Context
    await DataStore.getInstance().init(context)
    await QuotationRepository.getInstance().loadData(context)
    this.fetchRate(this.currencyNormal)
  }

  build() {
    Column() {
      HdsTabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          QuotationTab({
            tabType: TabType.NORMAL,
            currency: $currencyNormal,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRateNormal
          })
        }
        .tabBar(this.customTabBarBuilder(0, '正常报价'))

        TabContent() {
          QuotationTab({
            tabType: TabType.ZERO_REBATE,
            currency: $currencyZeroRebate,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRateZeroRebate
          })
        }
        .tabBar(this.customTabBarBuilder(1, '0退税'))

        TabContent() {
          QuotationTab({
            tabType: TabType.USD,
            currency: $currencyUsd,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRateUsd
          })
        }
        .tabBar(this.customTabBarBuilder(2, '美元报价'))

        TabContent() {
          QuotationTab({
            tabType: TabType.RMB,
            currency: $currencyRmb,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRateRmb
          })
        }
        .tabBar(this.customTabBarBuilder(3, '人民币报价'))

        TabContent() {
          HistoryView()
        }
        .tabBar(this.customTabBarBuilder(4, '历史'))
      }
      .scrollable(true)
      .barMode(BarMode.Scrollable)
      .barOverlap(true)
      .barBackgroundBlurStyle(BlurStyle.Thin)
      .barFloatingStyle({
        barBottomMargin: 28,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      })
      .onChange((index: number) => {
        this.currentIndex = index
        if (index < 4) {
          let currency: string = this.getCurrentCurrency()
          this.fetchRate(currency)
        }
      })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private async fetchRate(currency: string, forceRefresh: boolean = false) {
    this.rateLoaded = false
    
    // 获取当前tab的执行汇率
    let currentExecuteRate: string = this.getCurrentExecuteRate()
    
    // 如果不是强制刷新，且当前tab的执行汇率已经有值，则保留不变，不再重新获取
    if (!forceRefresh && currentExecuteRate !== '0' && currentExecuteRate.length > 0) {
      this.rateLoaded = true
      return
    }
    
    let info: RateInfo = await ExchangeRateFetcher.fetchRate(currency)
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

  private getCurrentCurrency(): string {
    switch (this.currentIndex) {
      case 0:
        return this.currencyNormal
      case 1:
        return this.currencyZeroRebate
      case 2:
        return this.currencyUsd
      case 3:
        return this.currencyRmb
      default:
        return CurrencyType.USD
    }
  }

  private onCurrencyNormalChange() {
    // Normal tab货币切换时，强制重新获取汇率
    if (this.currentIndex === 0) {
      this.fetchRate(this.currencyNormal, true)
    }
  }

  private onCurrencyZeroRebateChange() {
    // ZeroRebate tab货币切换时，强制重新获取汇率
    if (this.currentIndex === 1) {
      this.fetchRate(this.currencyZeroRebate, true)
    }
  }

  private onCurrencyUsdChange() {
    // USD tab货币切换时，强制重新获取汇率
    if (this.currentIndex === 2) {
      this.fetchRate(this.currencyUsd, true)
    }
  }

  private onCurrencyRmbChange() {
    // RMB tab货币切换时，强制重新获取汇率
    if (this.currentIndex === 3) {
      this.fetchRate(this.currencyRmb, true)
    }
  }
}
