import { preferences } from '@kit.ArkData'
import { Context } from '@kit.AbilityKit'
import { HistoryRecord } from '../model/QuotationData'

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
    this.prefs = await preferences.getPreferences(context, STORE_NAME)
  }

  async getHistory(): Promise<HistoryRecord[]> {
    if (this.prefs === null) {
      return []
    }
    let jsonStr: string = await this.prefs.get('history', '[]') as string
    let arr: Object[] = JSON.parse(jsonStr) as Object[]
    let records: HistoryRecord[] = []
    for (let i = 0; i < arr.length; i++) {
      let obj: Record<string, string> = arr[i] as Record<string, string>
      let record: HistoryRecord = {
        id: obj['id'] || '',
        tabType: obj['tabType'] || '',
        date: obj['date'] || '',
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
    await this.prefs.put('history', jsonStr)
    await this.prefs.flush()
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
    await this.prefs.put('history', jsonStr)
    await this.prefs.flush()
  }
}
