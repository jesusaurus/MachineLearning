#!/usr/bin/ruby

Value = Struct.new(:score, :actual)

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

    puts
    puts
    puts " *** #{arg} *** "
    puts

    tp = 0 #true positive
    tn = 0 #true negative
    fp = 0 #false positive
    fn = 0 #false negative

    values = Array.new

    count = 0
    File.open(arg, 'r') do |file|
        while (line = file.gets)
            a = count < pos ? 1 : -1
            values << Value.new(line.split.first.to_f, a)
            count = count + 1
        end
    end

    values.each do |value|
        if (value.score >= 0 && value.actual > 0)
            tp = tp + 1
        elsif (value.actual > 0)
            fn = fn + 1
        elsif (value.score >= 0)
            fp = fp + 1
        else
            tn = tn + 1
        end
    end

    puts "TP: #{tp}"
    puts "FP: #{fp}"
    puts "TN: #{tn}"
    puts "FN: #{fn}"
    puts
    puts "Accuracy: #{(tp + tn).to_f / (tp + tn + fp + fn)}"
    puts "Precision: #{tp.to_f / (tp + fp)}"
    puts "Recall: #{tp.to_f / (tp + fn)}"
    puts "True Positive Rate: #{tp.to_f / (tp + fn)}"
    puts "False Positive Rate: #{fp.to_f / (fp + tn)}"
end

