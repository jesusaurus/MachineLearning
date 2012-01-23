#!/usr/bin/ruby1.8

class Perceptron

    def initialize(source=3)
        @training    = Hash.new #training data
        @testing     = Hash.new #testing data
        @features    = 64
        @w           = Array.new(@features + 1) {|i| rand * 2 - 1} #weights: -1 <= w <= 1
        @eta         = 0.2
        @accuracy    = 0.0
        @epochs      = 0 #how many epochs have we trained on so far
        @epochGoal   = 0 #how many epochs to train for
        @sourceClass = source #the class we want to match
        @targetClass #the class we are testing against

        #read data from file
        readTrain()
        readTest()
    end

    def reset()
        @w          = Array.new(@features + 1) {|i| rand * 2 - 1}
        @accuracy   = 0.0
        @epochs     = 0
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
    end
    
    def start()
        #calculate the accuracy of the initial random weights
        numRight = 0

        @training[@sourceClass].each do |input|
            dirty = false
            input.each_index do |i|
                #process input
                output = percept(input)
                #our output should be > 0
                if output <= 0
                    dirty = true
                end
            end
            if not dirty
                #we got this one right!
                numRight += 1
            end
        end

        @training[@targetClass].each do |input|
            dirty = false
            input.each_index do |i|
                #process input
                output = percept(input)
                #our output should be < 0
                if output > 0
                    dirty = true
                end
            end
            if not dirty
                #we got this one right!
                numRight += 1
            end
        end

        @accuracy = numRight.to_f / (@training[@sourceClass].size + @training[@targetClass].size)
        puts "Initial accuracy of random weights: #{@accuracy}\n"
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
                if output <= 0
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

    def train(target)
        @targetClass = target
        puts "\n================\n"
        puts "Training Data\n"
        puts "================\n"
        start()
        while @epochs < @epochGoal
            epoch()
        end
    end

    def test(target)
        @targetClass = target
        puts "\n================\n"
        puts "Testing Data\n"
        puts "================\n"

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
        puts "Confusion Matrix for #{@sourceClass} versus #{@targetClass}\n"
        puts "\t\tTrue\t False\n"
        puts "Positive\t#{tPositives}\t #{fPositives}\n"
        puts "Negative\t#{tNegatives}\t #{fNegatives}\n"
    end

end

if __FILE__ == $0
    perc = Perceptron.new(0)
    (1..9).each do |i|
        puts "\n\n### 0 versus #{i} ###\n"
        perc.reset()
        perc.train(i)
        perc.test(i)
    end
end
