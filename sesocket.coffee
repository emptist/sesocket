util = require 'util'
path = require 'path'
{Socket} = require 'net'

### 券商接口
基本功能:
  提取資料:回報賬戶等資料
  發出指令:發出操作指令

說明:
  邏輯上,券商接口跟賬戶是綁定的.故此處賬戶跟接口並用.
  但是賬戶主要功能應獨立於接口,故賬戶另外設module.以便可以對接所有接口

  通過該券商接口登錄之後,在開市期間,
    1 對賬戶進行實時監控
    2 連接可為多用戶服務的策略交易機器人(含止盈止損機器人)
  判斷時機和賬戶變動,進行實時交易.

SocketServer要求如下:
  json: 發回來的資料須符合: {name:'資料名',value:資料內容},其中,資料名等同client所發申請
config文件
  要求放在外部

###

### TODO: 改成class
  class 券商接口 extends Socket
    constructor:(@賬戶,@端口,@主機)->

  券商 = new 券商接口()
###
{端口,主機} = require path.join __dirname,'config'

券商接口 = new Socket()


券商接口.on 'close',()->
  util.log 'socket連接已結束'

券商接口.交易時間 = ->
  d = new Date()
  return (d.getDay() < 6) and (15 > d.getHours() > 8)
###

  券商接口收到任何資料,都交給所屬賬戶來處理,
  因為服務於多用戶的策略機器人不需要這些資料

  將來新版本各種券商接口也都這樣處理

###
券商接口.on 'data', (data)->
  try
    obj = JSON.parse data

    # 若 obj 無'name' 或 賬戶 無 obj.name 都會回復 undefined:
    券商接口.賬戶[obj.name]? obj.value, (指令)->
      if 指令
        try
          if  券商接口.交易時間()
            券商接口.發出指令(指令)
          else
            券商接口.發出指令("test#{指令}")
        catch error
          console.error 'sesocket.coffee(可忽略): ', error

  catch error
    console.error 'sesocket.coffee(可忽略): ', error


# 盡量簡化了
券商接口.提取資料 = (指令, 回執)->
  券商接口.發出指令(指令, 回執)

券商接口.發出指令 = (指令, 回執)->
  ### 在Mac上
    沒換行不行,在Python一側看,用\n則需要處理去掉他,\r則產生 ''空string
  ###
  換行 = '\r'
  券商接口.write 指令+換行
  #util.log 指令 # 觀察一下速度
  回執?() #沒啥用?

券商接口.連接成功 = (回執)->
  券商接口.connect 端口, 主機, (err, data)->
    回執(err, data)

module.exports = 券商接口
