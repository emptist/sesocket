### 券商接口
基本功能:
  提取資料:回報賬戶等資料
  發出指令:發出操作指令

說明:
  邏輯上,券商接口跟賬戶是綁定的.故此處賬戶跟接口並用.
  但是賬戶主要功能應獨立於接口,故賬戶另外設module.以便可以對接所有接口
  通過該本券商接口登錄之後,在開市期間,對賬戶進行實時監控.連接交易機器人(含止盈止損機器人)
  應對行情和賬戶變動,進行實時交易.

SocketServer要求如下:
  json: 發回來的資料須符合: {name:'資料名',value:資料內容},其中,資料名等同client所發申請
config文件
  要求放在外部
###

util = require 'util'
{Socket} = require 'net'
{端口,主機,account} = require '../config'
資產賬戶 = require account

本券商接口 = new Socket()
#止盈止損者 = require '../sys.trading/stopMonitor'

本券商接口.賬戶 = 本賬戶 = new 資產賬戶

# 盡量簡化了
本券商接口.提取資料 = (指令)->
  本券商接口.發出指令(指令, ->)

本券商接口.發出指令 = (指令, 回執)->
  ### 在Mac上
    沒換行不行,在Python一側看,用\n則需要處理去掉他,\r則產生 ''空string
  ###
  換行 = '\r'
  本券商接口.write 指令+換行
  util.log 指令 # 觀察一下速度
  回執?() #沒啥用?


本券商接口.on 'data', (data)->
  obj = JSON.parse data
  if obj.hasOwnProperty 'name'
    本賬戶[obj.name] obj.value, (指令)->
      if 指令 then 本券商接口.發出指令(指令)


本券商接口.on 'close', -> util.log 'socket closed'

本券商接口.就緒 = (回執) ->
  本券商接口.connect 端口, 主機, (err, data)->
    回執(err, data)

module.exports = 本券商接口
