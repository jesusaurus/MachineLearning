#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD

$reps = 10

(1..$reps).each do |rep|
    puts
    puts "### Iteration #{rep} ###"
    puts

    output = `./part1.rb`
    print output
end

