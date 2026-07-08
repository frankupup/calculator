export interface QuotationRecord {
  product: string
  factory: string
  packageType: string
  containerType: string
  quantity: string
  surcharge: string
}

export interface HistoryRecord {
  id: string
  tabType: string
  label: string
  date: string
  rate: string
  executeRate: string
  currency: string
  product: string
  price: string
  factory: string
  packageType: string
  containerType: string
  quantity: string
  surcharge: string
  freight: string
  profitRate: string
  fobPrice: string
  cfrPrice: string
  cifPrice: string
  profit: string
}

export class QuotationFormData {
  product: string = ''
  price: string = ''
  factory: string = ''
  packageType: string = ''
  containerType: string = ''
  quantity: string = ''
  surcharge: string = ''
  freight: string = ''
  profitRate: string = ''
}
