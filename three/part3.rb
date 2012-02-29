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

$weights = Array.new($total, 1/$total.to_f)

$testAcc = Array.new
$trainAcc = Array.new

#run with only a fraction of the training data
[5, 10, 20].each do |count|
    (1..count) do |n|
        use = Array.new

        (0..($training.size * 0.3)).each do |i|
            #select samples based on weight
            pos = 0
            sum = 0
            r = rand
            while sum < r do
                sum += $weights[pos]
                pos += 1
            end
            use << $training[pos]
        end

        File.open('kfold.data', 'w') do |file|
            use.each do |t|
                file.write(t.join(','))
                file.write("\n")
            end
        end

        File.open('kfold.test', 'w') do |file|
            $validation.each do |v|
                file.write(v.join(','))
                file.write("\n")
            end
        end

        `c4.5 -f kfold -u`

        File.open('kfold.trainacc').readlines.each do |acc|
            puts acc
            $trainAcc << acc.to_f
        end

        File.open('kfold.testacc').readlines.each do |acc|
            puts acc
            $testAcc << acc.to_f
        end
        puts

    end

    sum = 0
    $testAcc.map {|t| sum += t}
    avgTest = sum / $testAcc.size

    sum = 0
    $trainAcc.map {|t| sum += t}
    avgTrain = sum / $trainAcc.size

    puts
    puts "### Summary ###"
    puts
    puts "Average Training Accuracy: #{avgTrain.to_s}"
    puts "Average Testing Accuracy: #{avgTest.to_s}"
    puts
end
