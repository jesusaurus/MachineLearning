#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD


data = Hash.new
File.open("wine.train").readlines.each do |line|
    l = line.chomp.split(',').map(&:to_f)
    if data[l.first].nil?
        data[l.first] = Array.new
    end
    data[l.first] << l
end
