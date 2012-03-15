#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD

#number of clusters
K = 3

#stop training if all centers move less than the limit
Limit = 0.05

#read training data from file
data = Array.new
File.open("wine.train").readlines.each do |line|
    l = line.chomp.split(',').map(&:to_f)
    d = Array.new
    d << l.shift
    d << l
    #d is an array of [class, vector] where vector is an array of features
    data << d
end

#transpose the vectors to easily normalize them
data = data.transpose
trans = data[1].transpose

#normalize data
trans.each do |t|
    min = t.min
    max = t.max
    t.map! {|x| (x - min) / (max - min)}
end

#unwind our data
data[1] = trans.transpose
data = data.transpose

#initialize K random cluster centers
center = Array.new(K)
center.each_index do |i|
    min = trans[i].min
    max = trans[i].max
    center[i] = Array.new(data[i][1].size) { |x| rand * (max - min) + min }
end

#we will be doing this often
def distance(vector1, vector2)
    sum = 0
    vector1.zip(vector2).each do |v1, v2|
        component = (v1 - v2)**2
        sum += component
    end
    Math.sqrt(sum)
end

stable = false
#until stable
(1..10).each do |_| #10 is more than enough

    #somewhere to sort the data into
    cluster = Array.new(K) {|a| Array.new }

    #calculate distances, sorting each point into a cluster
    data.each do |point| #point[0] is the class, point[1] is the vector
        d = Array.new(K)
        center.each_index do |k|
            #the distance from the k-th center to the point's vector
            d[k] = (distance(point[1],center[k])).abs
        end
        #add the vector to the cluster of the closest center
        cluster[d.index(d.min)] << point[1]

    end

    #calculate the new centers
    newcenter = Marshal.load( Marshal.dump(center) ) #deep copy
    newcenter.each_index do |k|
        trans = cluster[k].transpose
        newcenter[k].each_index do |i|
            sum = 0
            trans[i].each { |t| sum += t }
            avg = sum.to_f / trans[i].size
            puts avg
            puts newcenter[k][i]
            newcenter[k][i] = avg
            puts newcenter[k][i]
            puts
        end
    end

    #determine how much we've changed
    stable = true
    newcenter.each_index do |i|
        d = distance(center[i], newcenter[i]).abs
        if d > Limit
            stable = false
        end
    end

    #update the cluster centers
    center = newcenter

end

#the actual classes of the points associated with center[x]
#are in the array classes[x][]
classes = Array.new(K) { Array.new }
data.each do |point|
    dis = Array.new(K)
    center.each_index do |i|
        #distance from this center to the point vector
        dis[i] = (distance(point[1], center[i])).abs
    end

    puts dis.inspect

    #minimum distance == closest center
    closest = dis.index(dis.min)
    
    #add the point's class to classes of the closest center
    classes[closest] << point[0]
end

puts classes.inspect

#center[x] defines class map[x]
map = Array.new(K)

#find the mode of classes
classes.each do |k|
    count = Array.new(K) {0}
    classes[k].each { |x| count[x] += 1 }
    map[k] = count.index(count.max)
end

#read in the test data
test = Array.new
File.open('wine.test').readlines.each do |line|
    l = line.chomp.split(',').map(&:to_f)
    t = Array.new
    t << l.shift
    t << l
    #t is an array of [class, vector] where vector is an array of features
    test << t
end


#somewhere to sort the data into
cluster = Array.new(K) {|a| Array.new }

#calculate distances, sorting each point into a cluster
test.each do |point| #point[0] is the class, point[1] is the vector
    d = Array.new(K)
    center.each_index do |k|
        #the distance from the k-th center to the point's vector
        d[k] = (distance(point[1],center[k])).abs
    end
    #add the class to the cluster of the closest center
    cluster[d.index(d.min)] << point[0]
end

puts cluster.inspect

#calculate the accuracy
right = 0
wrong = 0
cluster.each_index do |k|
    cluster[k].each do |c|
        if c == map[k]
            right += 1
        else
            wrong += 1
        end
    end
end

puts "Accuracy: #{right / (right + wrong).to_f}"
