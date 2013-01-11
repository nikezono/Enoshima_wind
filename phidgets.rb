#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
require 'phidgets-ffi'

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

