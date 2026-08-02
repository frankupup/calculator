import { HistoryRecord } from '../model/QuotationData'
import { DataStore } from '../utils/DataStore'
import { onHistoryChanged, offHistoryChanged } from '../constants/Events'

@Component
export struct HistoryView {
  @State historyList: HistoryRecord[] = []
  @State isLoading: boolean = true
  @State groupedHistory: Map<string, HistoryRecord[]> = new Map()

  aboutToAppear() {
    this.loadHistory()
    // 订阅历史记录变化事件
    onHistoryChanged((data) => {
      this.loadHistory()
    })
  }

  aboutToDisappear() {
    // 取消订阅，避免内存泄漏
    offHistoryChanged()
  }

  build() {
    Column() {
      Text('History')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .padding({ left: 16, top: 12, bottom: 8 })

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#007DFF')
          .margin({ top: 40 })
      } else if (this.historyList.length === 0) {
        Text('暂无计算历史')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 40 })
      } else {
        List({ space: 0 }) {
          ForEach(this.getSortedDates(), (date: string, dateIndex: number) => {
            ListItem() {
              Column({ space: 0 }) {
                Text(date)
                  .fontSize(14)
                  .fontColor('#999999')
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                  .padding({ left: 16, top: 8 })

                ForEach(this.groupedHistory.get(date) || [], (item: HistoryRecord, index: number) => {
                  Column({ space: 4 }) {
                    Row() {
                      Text(item.label)
                        .fontSize(15)
                        .fontColor('#007DFF')
                        .fontWeight(FontWeight.Medium)
                        .layoutWeight(1)
                      
                      Text('×')
                        .fontSize(18)
                        .fontColor('#999999')
                        .width(24)
                        .height(24)
                        .textAlign(TextAlign.Center)
                        .onClick(() => {
                          this.deleteItem(item.id)
                        })
                    }
                      .width('100%')
                      .margin({ top: 4 })
                    Text() {
                      Span(item.currency + ' ' + item.rate + ' ')
                        .fontColor('#666666')
                      Span(item.executeRate + ' ')
                        .fontColor('#333333')
                      Span(item.product + ' ')
                        .fontColor('#333333')
                      Span(item.price + ' ')
                        .fontColor('#333333')
                      Span(item.factory)
                        .fontColor('#666666')
                    }
                      .fontSize(13)
                      .width('100%')

                    Text(item.packageType + '  ' + item.quantity + 'MT  杂费' + item.surcharge + 'RMB  运费' + item.freight + '' + (item.currency === '美元' ? 'USD' : 'EURO'))
                      .fontSize(13)
                      .fontColor('#666666')
                      .width('100%')

                    Text(item.profitRate + '个点: FOB ' + item.fobPrice + ', CFR ' + item.cfrPrice + ', CIF ' + item.cifPrice + '，' + item.profit + ', ' + (item.currency === '美元' ? 'USD/MT' : 'EURO/MT'))
                      .fontSize(13)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)
                      .width('100%')

                    if (index < (this.groupedHistory.get(date) || []).length - 1) {
                      Divider()
                        .strokeWidth(0.5)
                        .color('#EEEEEE')
                        .margin({ top: 2, bottom: 0 })
                    }
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 5, bottom: 5 })
                  .backgroundColor(Color.White)
                  .borderRadius(8)
                  .shadow({ radius: 2, color: '#15000000', offsetY: 1 })
                }, (item: HistoryRecord) => item.id)
              }
              .width('100%')
              .margin({ bottom: 8 })
            }
          }, (date: string) => date)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 0, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  deleteEnd(item: HistoryRecord) {
    Button('删除')
      .fontSize(14)
      .fontColor(Color.White)
      .backgroundColor('#FF3B30')
      .borderRadius(4)
      .width(60)
      .height('100%')
      .onClick(() => {
        this.deleteItem(item.id)
      })
  }

  private getSortedDates(): string[] {
    let dates: string[] = []
    this.groupedHistory.forEach((value: HistoryRecord[], key: string) => {
      dates.push(key)
    })
    return dates.sort((a: string, b: string) => b.localeCompare(a))
  }

  private groupByDate() {
    this.groupedHistory = new Map()
    for (let i = 0; i < this.historyList.length; i++) {
      let record: HistoryRecord = this.historyList[i]
      let date: string = record.date
      if (this.groupedHistory.has(date)) {
        this.groupedHistory.get(date)!.push(record)
      } else {
        this.groupedHistory.set(date, [record])
      }
    }
  }

  private async loadHistory() {
    let store: DataStore = DataStore.getInstance()
    this.historyList = await store.getHistory()
    this.groupByDate()
    this.isLoading = false
  }

  private async deleteItem(id: string) {
    let store: DataStore = DataStore.getInstance()
    await store.deleteHistory(id)
    await this.loadHistory()
  }
}
