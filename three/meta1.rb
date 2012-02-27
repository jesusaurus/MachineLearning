#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD

$reps = 10

$test = Array.new
$train = Array.new

(1..$reps).each do |rep|
    puts
    puts "### Iteration #{rep} ###"
    puts

    output = `./part1.rb`
    print output

    File.open('spam.trainacc').readlines.each do |t|
        $train << t.to_f
    end

    File.open('spam.testacc').readlines.each do |t|
        $test << t.to_f
    end
end

sum = 0
$test.map {|t| sum += t}
avgTest = sum / $test.size

sum = 0
$train.map {|t| sum += t}
avgTrain = sum / $train.size

puts
puts "### Summary ###"
puts
puts "Average Training Accuracy: #{avgTrain.to_s}"
puts
puts "Average Testing Accuracy: #{avgTest.to_s}"
puts
