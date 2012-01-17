class Perceptron

    def initialize()
        data = Hash.new #training data
        w = Array.new(64) {|i| rand * 2 - 1} #weights: -1 <= w <= 1
        epochs=0 #how many epochs have we trained on so far
        source=3 #look at class 3 vs 7
        target=7 #look at class 3 vs 7
    end

    def train()
        #each line of the file contains 64 csv inputs, the 65th integer is the class
        File.open('optdigits/.tra').readlines.each do |line|
            tmp = line.split(',')
            data[tmp.last] << tmp[0,64]
        end

        data[target].each do |values|
            values.each do |value|
                #do stuff
            end
            epochs++
        end
    end

    def percept()
        #calculate output from inputs
    end

    def test()
    end
end

if __FILE__ == $0
    perc = Perceptron.new
    perc.train()
end
