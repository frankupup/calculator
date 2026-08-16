import { preferences } from '@kit.ArkData'
import { Context } from '@kit.AbilityKit'
import { HistoryRecord } from '../model/QuotationData'
import { RateInfo } from './ExchangeRateFetcher'
import { emitHistoryChanged } from '../constants/Events'

const STORE_NAME: string = 'quotation_history'

export class DataStore {
  private static instance: DataStore | null = null
  private prefs: preferences.Preferences | null = null

  static getInstance(): DataStore {
    if (DataStore.instance === null) {
      DataStore.instance = new DataStore()
    }
    return DataStore.instance
  }

  async init(context: Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, STORE_NAME)
    } catch (error) {
      console.error('DataStore init failed:', error)
    }
  }

  async getHistory(): Promise<HistoryRecord[]> {
    if (this.prefs === null) {
      return []
    }
    try {
      let jsonStr: string = await this.prefs.get('history', '[]') as string
      let arr: Object[] = JSON.parse(jsonStr) as Object[]
      let records: HistoryRecord[] = []
      for (let i = 0; i < arr.length; i++) {
        let obj: Record<string, string> = arr[i] as Record<string, string>
        let record: HistoryRecord = {
          id: obj['id'] || '',
          tabType: obj['tabType'] || '',
          label: obj['label'] || '',
          date: obj['date'] || '',
          rateDate: obj['rateDate'] || '',
          rate: obj['rate'] || '',
          executeRate: obj['executeRate'] || '',
          currency: obj['currency'] || '',
          product: obj['product'] || '',
          price: obj['price'] || '',
          factory: obj['factory'] || '',
          packageType: obj['packageType'] || '',
          containerType: obj['containerType'] || '',
          quantity: obj['quantity'] || '',
          surcharge: obj['surcharge'] || '',
          freight: obj['freight'] || '',
          profitRate: obj['profitRate'] || '',
          fobPrice: obj['fobPrice'] || '',
          cfrPrice: obj['cfrPrice'] || '',
          cifPrice: obj['cifPrice'] || '',
          profit: obj['profit'] || ''
        }
        records.push(record)
      }
      return records
    } catch (error) {
      console.error('DataStore getHistory failed:', error)
      return []
    }
  }

  async saveHistory(record: HistoryRecord): Promise<void> {
    if (this.prefs === null) {
      return
    }
    let records: HistoryRecord[] = await this.getHistory()
    records.unshift(record)
    if (records.length > 200) {
      records = records.slice(0, 200)
    }
    let jsonStr: string = JSON.stringify(records)
    try {
      await this.prefs.put('history', jsonStr)
      await this.prefs.flush()
      // 发布历史记录变化事件
      emitHistoryChanged({ action: 'save', recordId: record.id })
    } catch (error) {
      console.error('DataStore saveHistory failed:', error)
    }
  }

  async deleteHistory(id: string): Promise<void> {
    if (this.prefs === null) {
      return
    }
    let records: HistoryRecord[] = await this.getHistory()
    let filtered: HistoryRecord[] = []
    for (let i = 0; i < records.length; i++) {
      if (records[i].id !== id) {
        filtered.push(records[i])
      }
    }
    let jsonStr: string = JSON.stringify(filtered)
    try {
      await this.prefs.put('history', jsonStr)
      await this.prefs.flush()
      // 发布历史记录变化事件
      emitHistoryChanged({ action: 'delete', recordId: id })
    } catch (error) {
      console.error('DataStore deleteHistory failed:', error)
    }
  }

  // 读取某币种上次成功获取的汇率缓存
  async getCachedRate(currency: string): Promise<RateInfo | null> {
    if (this.prefs === null) {
      return null
    }
    try {
      let jsonStr: string = await this.prefs.get('last_rate_' + currency, '') as string
      if (jsonStr.length === 0) {
        return null
      }
      let obj: Record<string, string> = JSON.parse(jsonStr) as Record<string, string>
      let info: RateInfo = new RateInfo()
      info.date = obj['date'] || ''
      info.rate = parseFloat(obj['rate'] || '0')
      return info
    } catch (error) {
      console.error('DataStore getCachedRate failed:', error)
      return null
    }
  }

  // 保存某币种的成功汇率（供下次失败时兜底）
  async saveCachedRate(currency: string, info: RateInfo): Promise<void> {
    if (this.prefs === null || info.date.length === 0) {
      return
    }
    try {
      await this.prefs.put('last_rate_' + currency, JSON.stringify({ date: info.date, rate: info.rate.toString() }))
      await this.prefs.flush()
    } catch (error) {
      console.error('DataStore saveCachedRate failed:', error)
    }
  }
}
