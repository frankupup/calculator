import { emitter } from '@kit.BasicServicesKit'

// 事件ID
export const EVENT_HISTORY_CHANGED = 1001

// 事件数据
export interface HistoryChangedData {
  action: 'save' | 'delete'
  recordId?: string
}

// 发布历史记录变化事件
export function emitHistoryChanged(data: HistoryChangedData): void {
  let innerEvent: emitter.InnerEvent = {
    eventId: EVENT_HISTORY_CHANGED
  }
  let eventData: emitter.EventData = {
    data: data
  }
  emitter.emit(innerEvent, eventData)
}

// 订阅历史记录变化事件
export function onHistoryChanged(callback: (data: HistoryChangedData) => void): void {
  let innerEvent: emitter.InnerEvent = {
    eventId: EVENT_HISTORY_CHANGED
  }
  emitter.on(innerEvent, (eventData: emitter.EventData) => {
    callback(eventData.data as HistoryChangedData)
  })
}

// 取消订阅
export function offHistoryChanged(): void {
  emitter.off(EVENT_HISTORY_CHANGED)
}
