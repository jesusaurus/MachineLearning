class Perceptron

    def initialize()
        @training = Hash.new #training data
        @testing = Hash.new #testing data
        @features = 64
        @w = Array.new(@features) {|i| rand * 2 - 1} #weights: -1 <= w <= 1
        @eta = 0.2
        @epochs=0 #how many epochs have we trained on so far
        @sourceClass=3 #look at class 3 vs 7
        @targetClass=7 #look at class 3 vs 7
    end

    def readTest()
        #each line of the file contains 64 csv inputs, the 65th integer is the class
        File.open('optdigits/.tes').readlines.each do |line|
            tmp = line.split(',')
            @testing[tmp.last] << tmp[0,@features]
        end
    end

    def readTrain()
        #each line of the file contains 64 csv inputs, the 65th integer is the class
        File.open('optdigits/.tra').readlines.each do |line|
            tmp = line.split(',')
            @training[tmp.last] << tmp[0,@features]
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
                #our output should be > 0
                if percept(input) < 0
                    #change weight
                    @w[i] += @eta * 2 * input[i]
                    dirty = true
                end
            end
            if not dirty
                #we got this one right!
                numRight++
            end
        end

        #train on what we are not
        @training[@targetClass].shuffle!
        @training[@targetClass].each do |input|
            dirty = false
            input.each_index do |i|
                #our output should be < 0
                if percept(input) > 0
                    #change weight
                    @w[i] += @eta * -2 * input[i]
                    dirty = true
                end
            end
            if not dirty
                #we got this one right!
                numRight++
            end
        end

        @epochs++
        @accuracy = numRight / (@training[@sourceClass].size + @training[@targetClass].size)
        puts "Accuracy after epoch #{@epochs}: #{@accuracy}\n"
        
    end

    def percept(inputs)
        #calculate output from inputs
        out = w[0]
        @w[1,@w.size].each_index do |i|
            out += @w[i] * inputs[i]
        end
        return out <=> 0
    end

    def train()
        readTrain()
        #loop until accurate enough
        while @accuracy < 0.9
            epoch()
        end
    end

    def test()
        readTest()
        #test
    end

end

if __FILE__ == $0
    perc = Perceptron.new
    perc.train()
end
