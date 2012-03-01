#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD

$data = Hash.new
$features = 57

$training = Array.new
$testing = Array.new

#each line of the file contains 57 csv inputs, the 58th integer is the class
File.open('spam.data').readlines.each do |line|
    tmp = line.chomp.split(',').map(&:to_i)
    $training << tmp
end

File.open('spam.test').readlines.each do |line|
    tmp = line.chomp.split(',').map(&:to_i)
    $testing << tmp
end

$testAcc = Array.new
$trainAcc = Array.new

#run with only a fraction of the training data
[5, 10, 20].each do |count|
    $weights = Array.new($training.size - 1, 1/($training.size - 1).to_f)
    $predictions = Hash.new
    
    (1..count).each do |n|
        $predictions[n] = Array.new
        use = Array.new

        (0..$training.size).each do |i|
            #select samples based on weight
            pos = 0
            sum = 0
            r = rand
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

        File.open("ada#{n}.test", 'w') do |file|
            $testing.each do |v|
                file.write(v.join(','))
                file.write("\n")
            end
        end

        `c4.5 -f ada#{n} -u`

        File.open("ada#{n}.predictions").readlines.each do |pred|
            $predictions[n] << pred.chomp.split.map(&:to_i)
        end
        $predictions[n].shift #ignore the first line

        File.open("ada#{n}.trainacc").readlines.each do |acc|
            puts acc
            $trainAcc << acc.to_f
        end

        File.open("ada#{n}.testacc").readlines.each do |acc|
            puts acc
            $testAcc << acc.to_f
        end

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
        $weights.each { |w| w /= sum }

    end

end
