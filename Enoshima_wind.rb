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
arduino.analog_write 3,value * 6 #速度
#arduino.analog_write 3,255

#現在時刻に応じてLEDの光量を変化させる
diff = 14 - time.hour#14時を最大の照度とする
arduino.analog_write 11,(255-diff.abs*15) if diff >= 0
arduino.analog_write 11, (255-diff.abs*30) if diff < 0

#風向きに応じてPhidgets-servoの向きを変化させる
servo = Phidgets::AdvancedServo.new

servo.on_attach do |device, obj|
puts "#{device.device_class} attached"
device.advanced_servos[0].engaged = true
device.advanced_servos[0].type = Phidgets::FFI::ServoType[:default]
end

servo.on_position_change do |device, motor, position|
puts "servo[#{motor.index}] => #{position}"
end



sleep 5

if servo.attached?

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
max = servo.advanced_servos[0].position_max
  1.times do
#servo.advanced_servos[0].position = rand(180)
  servo.advanced_servos[0].position = setDirection
  sleep 3.5
  ii = 30
  servo.advanced_servos[0].position = ii
  sleep 1.5
  end
  else
  puts 'device not found'
  end


