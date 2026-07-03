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
  @State executeRate: string = '0'
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
            executeRate: $executeRate
          })
        }
        .tabBar('正常报价')

        TabContent() {
          QuotationTab({
            tabType: TabType.ZERO_REBATE,
            currency: $currency,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRate
          })
        }
        .tabBar('0退税')

        TabContent() {
          QuotationTab({
            tabType: TabType.USD,
            currency: $currency,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRate
          })
        }
        .tabBar('美元报价')

        TabContent() {
          QuotationTab({
            tabType: TabType.RMB,
            currency: $currency,
            rateDate: this.rateDate,
            rate: this.rate,
            executeRate: $executeRate
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
    let info: RateInfo = await ExchangeRateFetcher.fetchRate(this.currency)
    if (info.date.length > 0) {
      this.rateDate = info.date
      this.rate = info.rate.toFixed(2)
      this.executeRate = info.rate.toFixed(2)
    }
    this.rateLoaded = true
  }

  private onCurrencyChange() {
    this.fetchRate()
  }
}
