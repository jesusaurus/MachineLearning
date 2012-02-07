#!/usr/bin/ruby

pos = 0
neg = 0

File.open("spam.test", 'r') do |file|
    while (line = file.gets)
	if (line.split.first.to_i > 0)
	  pos = pos + 1
	else
	  neg = neg + 1
	end
    end
end

ARGV.each do |arg|

    tp = 0 #true positive
    tn = 0 #true negative
    fp = 0 #false positive
    fn = 0 #false negative
    count = 0

    File.open(arg, 'r') do |file|
	while (line = file.gets)
	    tmp = line.split.first.to_i
	    if (tmp >= 0 && count < pos)
		tp = tp + 1
	    elsif (tmp >= 0)
		fp = fp + 1
	    elsif (count < pos)
		fn = fn + 1
	    else
		tn = tn + 1
	    end
	    count = count + 1
	end
    end

    puts "TP: " + "#{tp}"
    puts "FP: " + "#{fp}"
    puts "TN: " + "#{tn}"
    puts "FN: " + "#{fn}"
end

