/**
 * 自定义数字键盘组件
 * 支持数字、小数点、删除键
 */
@Component
export struct CustomNumericKeyboard {
  @Link inputValue: string
  controller: TextInputController | null = null
  
  // 数字键盘布局
  private keyLayout: string[][] = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫']
  ]
  
  build() {
    Column() {
      // 收起键盘按钮（朝下的箭头）
      Row() {
        Text('▼')
          .fontSize(20)
          .fontColor('#666666')
          .padding(3)
      }
      .width('100%')
      .height(14)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F5F5F5')
      .onClick(() => {
        // 收起键盘
        if (this.controller) {
          this.controller.stopEditing()
        }
      })
      
      // 键盘主体
      Column() {
        ForEach(this.keyLayout, (row: string[], rowIndex: number) => {
          Row({ space: 8 }) {
            ForEach(row, (key: string, colIndex: number) => {
              if (key === '⌫') {
                // 删除键
                this.BackspaceKey()
              } else {
                // 数字键或小数点
                this.NumberKey(key)
              }
            })
          }
          .justifyContent(FlexAlign.SpaceAround)
          .width('100%')
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 12 })
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
  }
  
  // 数字键/小数点键
  @Builder
  NumberKey(value: string) {
    Button(value)
      .fontSize(24)
      .fontColor('#333333')
      .fontWeight(FontWeight.Medium)
      .width('30%')
      .height(48)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .shadow({
        radius: 2,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 1
      })
      .onClick(() => {
        // 小数点特殊处理：只允许输入一次
        if (value === '.') {
          if (this.inputValue.indexOf('.') === -1) {
            // 如果当前为空，补0
            if (this.inputValue.length === 0) {
              this.inputValue = '0.'
            } else {
              this.inputValue += '.'
            }
          }
        } else {
          this.inputValue += value
        }
      })
  }
  
  // 删除键
  @Builder
  BackspaceKey() {
    Button() {
      Text('⌫')
        .fontSize(24)
        .fontColor('#333333')
    }
    .width('30%')
    .height(48)
    .backgroundColor('#E0E0E0')
    .borderRadius(8)
    .shadow({
      radius: 2,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 1
    })
    .onClick(() => {
      if (this.inputValue.length > 0) {
        this.inputValue = this.inputValue.substring(0, this.inputValue.length - 1)
      }
    })
  }
}
