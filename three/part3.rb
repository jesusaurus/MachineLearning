#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD

$training = Array.new

#each line of the file contains 57 csv inputs, the 58th integer is the class
File.open('spam.data').readlines.each do |line|
    tmp = line.chomp.split(',').map(&:to_i)
    $training << tmp
end

#run with only a fraction of the training data
[5, 10, 20].each do |count|
    $weights = Array.new($training.size - 1, 1/($training.size - 1).to_f)
    $predictions = Hash.new
    
    (1..count).each do |n|
        $predictions[n] = Array.new
        use = Array.new

        $training.each do ||
            #select samples based on weight
            sum, pos, r = 0, 0, rand
            while sum < r do
                sum += $weights[pos]
                pos += 1
            end
            if $training[pos].nil?
                puts "Bad position: " + pos.to_s
            else
                use << $training[pos]
            end
        end

        File.open("ada#{n}.data", 'w') do |file|
            use.each do |t|
                file.write(t.join(','))
                file.write("\n")
            end
        end

        puts `c4.5 -f ada#{n} -u | tail -n 23`

        File.open("ada#{n}.predictions").readlines.each do |pred|
            $predictions[n] << pred.chomp.split.map(&:to_i)
        end
        $predictions[n].shift.compact #ignore the first line

        wrong = 0
        $predictions[n].each do |pred|
            if pred[0] != pred[1]
                wrong += 1
            end
        end
        puts wrong.to_s + " misclassified"

        #update weights
        error = wrong.to_f / $training.size
        alpha = 0.5 * Math.log( (1 - error) / error )

        sum = 0
        $weights.each_index do |idx|
            if $predictions[n][idx][0] != $predictions[n][idx][1]
                $weights[idx] *= Math.exp(alpha)
            end
            sum += $weights[idx]
        end
        #normalize
        $weights.map! { |w| w / sum }

    end

    #ensemble
    $ensemble = Array.new($training.size) 
    $ensemble.each_index do |i|
        x = 0
        (1..count).each do |c|
            if $predictions[c][i][1] == 1
                x += 1
            end
        end
        if x >= count / 2
            $ensemble[i] = 1
        else
            $ensemble[i] = 0
        end
    end

    right = 0
    fp, fn = 0, 0
    $ensemble.each_index do |i|
        x = $predictions[1][i][0] <=> $ensemble[i]
        if x == 0
            right += 1
        elsif x < 0
            fp += 1
        else
            fn += 1
        end
    end

    puts "Accuracy (#{count}): #{right.to_f / $training.size} [#{fp}:#{fn}]"

end
