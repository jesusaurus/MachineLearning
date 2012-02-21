#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD

$data = Hash.new
$features = 57
$fold = .1

#each line of the file contains 57 csv inputs, the 58th integer is the class
File.open('../spambase/spambase.data').readlines.each do |line|
    tmp = line.chomp.split(',').map(&:to_i)
    if $data[tmp.last].nil?
        $data[tmp.last] = []
    end
    $data[tmp.last] << tmp[0,$features]
end

$total = 0
$data.each do |x|
    $total += x.size
end

$weights = Array.new($total, 1.0 / $total)

$training = Array.new
$validation = Array.new

$data.each do |d|
    skip = 0
    (1..(d.size/$total*$fold)).each do |x|
        tmp = rand * 8 + 1
        (skip..skip+tmp-1).each do |i|
            $training = d[i]
        end
        skip += tmp
        $validation << d[skip]
    end
end

puts "#{$total}: #{$training.size} + #{$validation.size}\n"
