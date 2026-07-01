import { resourceManager } from '@kit.LocalizationKit'
import { util } from '@kit.ArkTS'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { QuotationRecord } from '../model/QuotationData'

export class QuotationRepository {
  private static instance: QuotationRepository | null = null
  private dataMap: Record<string, QuotationRecord[]> = {}

  static getInstance(): QuotationRepository {
    if (QuotationRepository.instance === null) {
      QuotationRepository.instance = new QuotationRepository()
    }
    return QuotationRepository.instance
  }

  async loadData(context: Context): Promise<void> {
    try {
      let resMgr: resourceManager.ResourceManager = context.resourceManager
      let fileData: Uint8Array = await resMgr.getRawFileContent('quotation_data.json')
      let textDecoder: util.TextDecoder = util.TextDecoder.create('utf-8')
      let jsonStr: string = textDecoder.decodeToString(fileData)
      let jsonObj: Record<string, Object> = JSON.parse(jsonStr) as Record<string, Object>
      let keys: string[] = Object.keys(jsonObj)
      for (let i = 0; i < keys.length; i++) {
        let key: string = keys[i]
        let arr: Object[] = jsonObj[key] as Object[]
        let records: QuotationRecord[] = []
        for (let j = 0; j < arr.length; j++) {
          let item: Record<string, string> = arr[j] as Record<string, string>
          let record: QuotationRecord = {
            product: item['product'] || '',
            factory: item['factory'] || '',
            packageType: item['package'] || '',
            containerType: item['containerType'] || '',
            quantity: item['quantity'] || '',
            surcharge: item['surcharge'] || ''
          }
          records.push(record)
        }
        this.dataMap[key] = records
      }
    } catch (e) {
      hilog.error(0x0001, 'QuotationRepo', 'Failed to load data: ' + e.toString())
    }
  }

  search(tabType: string, keyword: string): QuotationRecord[] {
    let allRecords: QuotationRecord[] = this.dataMap[tabType] || []
    if (keyword.length === 0) {
      return allRecords.slice(0, 20)
    }
    let upperKeyword: string = keyword.toUpperCase()
    let results: QuotationRecord[] = []
    for (let i = 0; i < allRecords.length; i++) {
      if (allRecords[i].product.toUpperCase().indexOf(upperKeyword) >= 0) {
        results.push(allRecords[i])
        if (results.length >= 20) {
          break
        }
      }
    }
    return results
  }
}
