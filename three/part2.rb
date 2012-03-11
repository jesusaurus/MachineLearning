#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD

$data = Hash.new
$features = 57
$fold = 0.1

#each line of the file contains 57 csv inputs, the 58th integer is the class
File.open('spam.data').readlines.each do |line|
    tmp = line.chomp.split(',').map(&:to_i)
    if $data[tmp.last].nil?
        $data[tmp.last] = Array.new
    end
    $data[tmp.last] << tmp
end

$total = 0
$data.each do |k, v|
    $total += v.size
end

$validation = Array.new
$training = $data.clone

#split the data into validation and training data
$training.each do |c, datum|
    skip = 0
    range = $fold * $training[c].size

    (1..range).each do |x|
        $validation << $training[c].delete_at(rand * $training[c].size)
    end
end

$testAcc = Array.new
$trainAcc = Array.new

#run with only a fraction of the training data
(0.1..1).step(0.1) do |n|
    (1..10).each do |i|
        use = Array.new

        $training.each do |k,v|
            (0..(v.size * n - 1)).each do |x|
                use << v[x]
            end
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
            $trainAcc << acc.to_f
        end

        File.open('kfold.testacc').readlines.each do |acc|
            $testAcc << acc.to_f
        end

    end

    sum = 0
    $testAcc.map {|t| sum += t}
    avgTest = sum / $testAcc.size

    sum = 0
    $trainAcc.map {|t| sum += t}
    avgTrain = sum / $trainAcc.size

    puts
    puts "### Summary ###"
    puts "N: #{n * 100}%"
    puts
    puts "Average Training Accuracy: #{avgTrain.to_s}"
    puts "Average Testing Accuracy: #{avgTest.to_s}"
    puts

end
