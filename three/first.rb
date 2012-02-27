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

$total = 0
$data.each do |k, v|
    $total += v.size
end

$training = Array.new
$validation = Array.new

$data.each do |c, datum|
    (0..(datum.size-2)).step(2) do |d|
        $training << (datum[d] + [c])
        $validation << (datum[d+1] + [c])
    end
end

File.open('spam.data', 'w') do |file|
    $training.each do |t|
        file.write(t.join(','))
        file.write("\n")
    end
end
File.open('spam.test', 'w') do |file|
    $validation.each do |v|
        file.write(v.join(','))
        file.write("\n")
    end
end
