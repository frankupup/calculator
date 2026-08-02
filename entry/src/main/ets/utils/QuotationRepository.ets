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
    let allRecords: QuotationRecord[] = (this.dataMap[tabType] || []).slice()

    if (keyword.length === 0) {
      return allRecords
    }
    let upperKeyword: string = keyword.toUpperCase()
    let results: QuotationRecord[] = []
    for (let i = 0; i < allRecords.length; i++) {
      if (allRecords[i].product.toUpperCase().indexOf(upperKeyword) >= 0) {
        results.push(allRecords[i])
      }
    }
    return results
  }

  // 根据产品名称获取包装列表（去重）
  getPackagesByProduct(tabType: string, product: string): QuotationRecord[] {
    let allRecords: QuotationRecord[] = this.dataMap[tabType] || []
    let upperProduct: string = product.toUpperCase()
    let results: QuotationRecord[] = []
    let packageSet: Set<string> = new Set()
    
    for (let i = 0; i < allRecords.length; i++) {
      if (allRecords[i].product.toUpperCase() === upperProduct) {
        // 去重：同一个包装只保留一条记录
        if (!packageSet.has(allRecords[i].packageType)) {
          packageSet.add(allRecords[i].packageType)
          results.push(allRecords[i])
        }
      }
    }
    
    // 按包装升序排序
    results.sort((a: QuotationRecord, b: QuotationRecord) => {
      return a.packageType.localeCompare(b.packageType)
    })
    
    return results
  }

  // 根据产品和包装获取匹配的第一条记录
  getFirstByProductAndPackage(tabType: string, product: string, packageType: string): QuotationRecord | null {
    let allRecords: QuotationRecord[] = this.dataMap[tabType] || []
    let upperProduct: string = product.toUpperCase()
    let upperPackage: string = packageType.toUpperCase()
    
    for (let i = 0; i < allRecords.length; i++) {
      if (allRecords[i].product.toUpperCase() === upperProduct &&
          allRecords[i].packageType.toUpperCase() === upperPackage) {
        return allRecords[i]
      }
    }
    
    return null
  }

  // 根据产品、工厂、包装获取柜型列表（去重）
  getContainersByProductAndFactoryAndPackage(tabType: string, product: string, factory: string, packageType: string): QuotationRecord[] {
    let allRecords: QuotationRecord[] = this.dataMap[tabType] || []
    let upperProduct: string = product.toUpperCase()
    let upperFactory: string = factory.toUpperCase()
    let upperPackage: string = packageType.toUpperCase()
    let results: QuotationRecord[] = []
    let containerSet: Set<string> = new Set()

    for (let i = 0; i < allRecords.length; i++) {
      if (allRecords[i].product.toUpperCase() === upperProduct &&
          allRecords[i].factory.toUpperCase() === upperFactory &&
          allRecords[i].packageType.toUpperCase() === upperPackage) {
        if (!containerSet.has(allRecords[i].containerType)) {
          containerSet.add(allRecords[i].containerType)
          results.push(allRecords[i])
        }
      }
    }

    results.sort((a: QuotationRecord, b: QuotationRecord) => {
      return a.containerType.localeCompare(b.containerType)
    })

    return results
  }

  // 根据产品、工厂、包装、柜型获取匹配的第一条记录
  getFirstByProductAndFactoryAndPackageAndContainer(tabType: string, product: string, factory: string, packageType: string, containerType: string): QuotationRecord | null {
    let allRecords: QuotationRecord[] = this.dataMap[tabType] || []
    let upperProduct: string = product.toUpperCase()
    let upperFactory: string = factory.toUpperCase()
    let upperPackage: string = packageType.toUpperCase()
    let upperContainer: string = containerType.toUpperCase()

    for (let i = 0; i < allRecords.length; i++) {
      if (allRecords[i].product.toUpperCase() === upperProduct &&
          allRecords[i].factory.toUpperCase() === upperFactory &&
          allRecords[i].packageType.toUpperCase() === upperPackage &&
          allRecords[i].containerType.toUpperCase() === upperContainer) {
        return allRecords[i]
      }
    }

    return null
  }
}
