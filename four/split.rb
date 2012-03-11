#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD

# Purpose: split the data into testing and training

data = Hash.new

File.open('wine.data').readlines.each do |line|
    l = line.chomp.split(',').map(&:to_f)
    if data[l.first].nil?
        data[l.first] = Array.new
    end
    data[l.first] << l
end

File.open("wine.test",'w') do |file|
    data.each do |datum|
        (1..datum.last.size/2).each do |d|
            file.write(datum.last[d].join(','))
            file.write("\n")
        end
    end
end

File.open("wine.train",'w') do |file|
    data.each do |datum|
        (datum.last.size/2+1..datum.last.size-1).each do |d|
            file.write(datum.last[d].join(','))
            file.write("\n")
        end
    end
end
