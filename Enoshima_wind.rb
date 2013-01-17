# -*- encoding: utf-8 -*-
# 江ノ島の風 on Arduino
# 江ノ島をジオラマ風に再現して、風向きや風速、明るさなどを可能な限り再現できるモノ
# 
# crontabで5分おきに実行することを前提にする
# ※江ノ島の気象観測所のWebの更新が５分おきのため。

require 'net/http'
require 'nkf'
require 'rubygems'
require 'arduino_firmata'
require 'phidgets-ffi'

#Arduinoと接続
arduino = ArduinoFirmata.connect  #"/dev/tty.usbmodem411"
puts "Connect Arduino Version : #{arduino.version}"

puts arduino.digital_read 0
#initialize
value = 0
direction = 0
time = Time.now

#Http通信でWebから風速を持ってくる
#江ノ島の気象観測所のデータ(５分ごと更新)
#http://enoshima-yacht-harbor.jp/kishou.htm
Net::HTTP.start('enoshima-yacht-harbor.jp',80){|http|
  response = http.get("/kishou.htm")
    s = response.body.to_s
    s = NKF.nkf('-w',s)
    power = s.scan(/平均風速<\/TD>\n<\/TR>\n<TR><TD height="30" align="center"><B>(.+?)&/)
    value = power[0][0]
    value = value.to_i
    puts "江ノ島の平均風速:#{value}m/s"

    s = s.scan(/平均風向<\/TD>\n<\/TR>\n<TR><TD height="30" align="center"><B>(.+?)<\/B>/)
    direction = s[0][0]
    puts "江ノ島の風向き:#{direction}"
}
puts "現在時刻:#{time.hour}時"
# 実行部分

#最大風速を台風直撃レベル（40m/s）とする。
#最低風速を0m/s（無風）とする。
#analog_Writeのとりうる値の範囲（0~255)を40m/sで割ると、
#風速値 * 6 をモーターの回転スピードとする（とりあえず）
#リアルな風速と一致させるには、プロペラをモーターに接続して、その風速を計る必要がある。

arduino.digital_write 5,true
arduino.digital_write 4,false
arduino.analog_write 3,value * 10 if value >= 3#速度 
#arduino.analog_write 3,255
puts "Arduino：Analog_write 3(Motor),Value:#{value*6}"

#現在時刻に応じてLEDの光量を変化させる
diff = 14 - time.hour#14時を最大の照度とする
diff = 255 - diff.abs*15 if diff >= 0
diff = 255 - diff.abs*30 if diff <= 0
puts "Arduino: Analog_write 11(Light),Value:#{diff.abs}"
arduino.analog_write 11,diff.abs

#風向きに応じてservoの向きを変化させる

if direction == "東" then
setDirection = 93 
elsif direction == "西" then
setDirection = 63
elsif direction == "南" then
setDirection = 45
elsif direction == "北" then
setDirection = 80
elsif direction == "北東" then
setDirection = 89
elsif direction == "南東" then
setDirection = 103
elsif direction == "北西" then
setDirection = 72
elsif direction == "南西" then
setDirection = 58
elsif direction == "北北西" then
setDirection = 78
elsif direction == "北北東" then
setDirection = 84
elsif direction == "南南西" then
setDirection = 53
elsif direction == "南南東" then
setDirection = 113
elsif direction == "東北東" then
setDirection = 93
elsif direction == "東南東" then
setDirection = 109
elsif direction == "西北西" then
setDirection = 67
elsif direction == "西南西" then
setDirection = 58
end  

#30~105
#S120 NE90 N82 E98    
arduino.servo_write 9,setDirection
puts "Arduino: Digital_write 9(Servo),Value:#{setDirection}"

