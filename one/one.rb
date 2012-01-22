#!/usr/bin/ruby1.8

class Perceptron

    def initialize()
        @training    = Hash.new #training data
        @testing     = Hash.new #testing data
        @features    = 64
        @w           = Array.new(@features + 1) {|i| rand * 2 - 1} #weights: -1 <= w <= 1
        @eta         = 0.2
        @accuracy    = 0.0
        @epochs      = 0 #how many epochs have we trained on so far
        @epochGoal   = 5 #how many epochs to train for
        @sourceClass = 3 #look at class 3 vs 7
        @targetClass = 7 #look at class 3 vs 7
    end

    def readTest()
        #each line of the file contains 64 csv inputs, the 65th integer is the class
        File.open('optdigits/optdigits.tes').readlines.each do |line|
            tmp = line.chomp.split(',').map(&:to_i)
            if @testing[tmp.last].nil?
                @testing[tmp.last] = []
            end
            @testing[tmp.last] << tmp[0,@features]
        end
    end

    def readTrain()
        #each line of the file contains 64 csv inputs, the 65th integer is the class
        File.open('optdigits/optdigits.tra').readlines.each do |line|
            tmp = line.chomp.split(',').map(&:to_i)
            if @training[tmp.last].nil?
                @training[tmp.last] = []
            end
            @training[tmp.last] << tmp[0,@features]
        end
        puts "Training data loaded.\n\n"
        @training.each_key do |k|
            puts "Class #{k} has #{@training[k].size} samples.\n"
        end
    end

    def epoch()
        #go through one epoch of training

        numRight = 0

        #train on what we are
        @training[@sourceClass].shuffle!
        @training[@sourceClass].each do |input|
            dirty = false
            input.each_index do |i|
                #process input
                output = percept(input)
                #our output should be > 0
                if output < 0
                    dirty = true
                end
                #change weight
                @w[i] += @eta * (1 - output) * input[i]
            end
            if not dirty
                #we got this one right!
                numRight += 1
            end
        end

        #train on what we are not
        @training[@targetClass].shuffle!
        @training[@targetClass].each do |input|
            dirty = false
            input.each_index do |i|
                #process input
                output = percept(input)
                #our output should be < 0
                if output > 0
                    dirty = true
                end
                #change weight
                @w[i] += @eta * (-1 - output) * input[i]
            end
            if not dirty
                #we got this one right!
                numRight += 1
            end
        end

        @epochs += 1
        @accuracy = numRight.to_f / (@training[@sourceClass].size + @training[@targetClass].size)
        puts "Accuracy after epoch #{@epochs}: #{@accuracy}\n"
        
    end

    def percept(inputs)
        #calculate output from inputs
        #the source class is > 0
        #the target class is < 0
        out = @w[0]
        @w[1,@w.size].each_index do |i|
            out += @w[i] * inputs[i]
        end
        return out 
    end

    def train()
        readTrain()
        while @epochs < @epochGoal
            epoch()
        end
    end

    def test()
        readTest()

        tPositives = 0
        fPositives = 0
        tNegatives = 0
        fNegatives = 0

        @testing[@sourceClass].each do |input|
            #Positives
            if percept(input) < 0
                #False
                fPositives += 1
            else
                #True
                tPositives += 1
            end
        end

        @testing[@targetClass].each do |input|
            #Negatives
            if percept(input) > 0
                #False
                fNegatives += 1
            else
                #True
                tNegatives += 1
            end
        end

        #output results
        puts "\n================\n"
        puts "Confusion Matrix for #{@sourceClass} versus #{@targetClass}\n"
        puts "\t\tTrue\t False\n"
        puts "Positive\t#{tPositives}\t #{fPositives}\n"
        puts "Negative\t#{tNegatives}\t #{fNegatives}\n"
        puts "================\n"
    end

end

if __FILE__ == $0
    perc = Perceptron.new
    perc.train()
    perc.test()
end
