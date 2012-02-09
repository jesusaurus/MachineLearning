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

    values = Array.new

    count = 0
    File.open(arg, 'r') do |file|
        while (line = file.gets)
            a = count < pos ? 1 : -1
            values << Value.new(line.split.first.to_f, a)
            count = count + 1
        end
    end

    values.sort! {|a,b| a.score <=> b.score}

    min = values.first.score
    max = values.last.score
    step = (max - min) / 19.0
    if (step == 0)
        step = 1
    end

    puts "Threshold\tAccuracy\tPrecision\tRecall/TPR\tFPR"

    (min..max).step(step).each do |threshold|

        tp = 0 #true positive
        tn = 0 #true negative
        fp = 0 #false positive
        fn = 0 #false negative

        values.each do |value|
            if (value.score >= threshold && value.actual > 0)
                tp = tp + 1
            elsif (value.actual > 0)
                fn = fn + 1
            elsif (value.score >= threshold)
                fp = fp + 1
            else
                tn = tn + 1
            end
        end

        puts "#{threshold}\t#{(tp + tn).to_f / (tp + tn + fp + fn)}\t#{tp.to_f / (tp + fp)}\t#{tp.to_f / (tp + fn)}\t#{fp.to_f / (fp + tn)}"

    end

end

