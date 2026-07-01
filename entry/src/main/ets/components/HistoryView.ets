import { HistoryRecord } from '../model/QuotationData'
import { DataStore } from '../utils/DataStore'

@Component
export struct HistoryView {
  @State historyList: HistoryRecord[] = []
  @State isLoading: boolean = true

  aboutToAppear() {
    this.loadHistory()
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
        List({ space: 8 }) {
          ForEach(this.historyList, (item: HistoryRecord) => {
            ListItem() {
              Column({ space: 4 }) {
                Text(item.date)
                  .fontSize(12)
                  .fontColor('#999999')

                Text(item.currency + ' ' + item.rate + ' ' + item.executeRate)
                  .fontSize(13)
                  .fontColor('#666666')

                Row({ space: 8 }) {
                  Text(item.price)
                    .fontSize(14)
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium)
                  Text(item.factory)
                    .fontSize(13)
                    .fontColor('#666666')
                  Text(item.packageType)
                    .fontSize(13)
                    .fontColor('#666666')
                }

                Row({ space: 8 }) {
                  Text(item.quantity)
                    .fontSize(13)
                    .fontColor('#666666')
                  Text('¥' + item.surcharge)
                    .fontSize(13)
                    .fontColor('#666666')
                  Text('$' + item.freight)
                    .fontSize(13)
                    .fontColor('#666666')
                }

                Text('5个点: FOB ' + item.fobPrice + ', CIF ' + item.cifPrice + ', 利润 ' + item.profit)
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .shadow({ radius: 2, color: '#15000000', offsetY: 1 })
            }
            .swipeAction({ end: this.deleteEnd(item) })
          }, (item: HistoryRecord) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
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

  private async loadHistory() {
    let store: DataStore = DataStore.getInstance()
    this.historyList = await store.getHistory()
    this.isLoading = false
  }

  private async deleteItem(id: string) {
    let store: DataStore = DataStore.getInstance()
    await store.deleteHistory(id)
    await this.loadHistory()
  }
}
