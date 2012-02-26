#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD

$data = Hash.new
$features = 57
$fold = 0.1

#each line of the file contains 57 csv inputs, the 58th integer is the class
File.open('spambase.data').readlines.each do |line|
    tmp = line.chomp.split(',').map(&:to_i)
    if $data[tmp.last].nil?
        $data[tmp.last] = []
    end
    $data[tmp.last] << tmp[0,$features]
end

puts "#{$data[0].size}"
puts "#{$data[1].size}"

$total = 0
$data.each do |k, v|
    $total += v.size
end

$weights = Array.new($total, 1.0 / $total)

$training = Array.new
$validation = Array.new

$data.each do |c, datum|
    skip = 0
    (1..(datum.size/$total*$fold)).each do |x|
        tmp = rand * 8 + 1
        (skip..skip+tmp-1).each do |i|
            $training << datum[i]
        end
        skip += tmp
        $validation << datum[skip]
    end
end

File.open('spam.train', 'w') do |file|
    $training.each do |t|
        file.write(t)
        puts t.inspect
    end
end
File.open('spam.val', 'w') do |file|
    $validation.each do |v|
        file.write(v)
    end
end

output = `c4.5 ` 
