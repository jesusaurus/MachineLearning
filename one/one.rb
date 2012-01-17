class Perceptron

    def initialize()
        data = Hash.new #training data
        test = Hash.new #testing data
        w = Array.new(64) {|i| rand * 2 - 1} #weights: -1 <= w <= 1
        epochs=0 #how many epochs have we trained on so far
        source=3 #look at class 3 vs 7
        target=7 #look at class 3 vs 7
    end

    def readTest()
        #each line of the file contains 64 csv inputs, the 65th integer is the class
        File.open('optdigits/.tes').readlines.each do |line|
            tmp = line.split(',')
            test[tmp.last] << tmp[0,64]
        end
    end

    def readTrain()
        #each line of the file contains 64 csv inputs, the 65th integer is the class
        File.open('optdigits/.tra').readlines.each do |line|
            tmp = line.split(',')
            data[tmp.last] << tmp[0,64]
        end
    end

    def epoch()
        #go through one epoch of training

        #train on what we are
        data[source].each do |values|
            values.each do |value|
                #do stuff
            end
        end

        #train on what we are not
        data[target].each do |values|
            values.each do |value|
                #do stuff
            end
        end
        
        epochs++
    end

    def percept(inputs)
        #calculate output from inputs
        out = w[0]
        w[1,w.size].each_index do |i|
            out += w[i] * inputs[i]
        end
        return out
    end

    def train()
        readTrain()
        #loop until accurate enough
        epoch()
    end

    def test()
        readTest()
        #
    end

end

if __FILE__ == $0
    perc = Perceptron.new
    perc.train()
end
