#!/usr/bin/ruby1.8

# Author:   K Jonathan Harker
# Date:     February 2012
# License:  New BSD

#number of clusters
K = 8

#stop training if all centers move less than the limit
Limit = 0.05

#read training data from file
data = Array.new
File.open("wine.test").readlines.each do |line|
    l = line.chomp.split(',').map(&:to_f)
    d = Array.new
    d << l.shift.to_i
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
until stable
#(1..10).each do |_| #10 is more than enough

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
        if cluster[k].size == 0
            next #skip empty clusters
        end
        trans = cluster[k].transpose
        newcenter[k].each_index do |i|
            sum = 0
            trans[i].each { |t| sum += t }
            avg = sum.to_f / trans[i].size
            newcenter[k][i] = avg
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
    center = Marshal.load( Marshal.dump(newcenter) )

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

    #minimum distance == closest center
    closest = dis.index(dis.min)
    
    #add the point's class to classes of the closest center
    classes[closest] << point[0]
end

#center[x] defines class map[x]
map = Array.new(K)

#find the mode of classes
classes.each_index do |k|
    count = Array.new(K) {0}
    classes[k].each { |c| count[c-1] += 1 }
    map[k] = count.index(count.max) + 1
end

#read in the test data
test = Array.new
File.open('wine.test').readlines.each do |line|
    l = line.chomp.split(',').map(&:to_f)
    t = Array.new
    t << l.shift.to_i
    t << l
    #t is an array of [class, vector] where vector is an array of features
    test << t
end

#prepare to normalize
test = test.transpose
trans = test[1].transpose

#normalize test
trans.each do |t|
    min = t.min
    max = t.max
    t.map! {|x| (x - min) / (max - min)}
end

#untransform our test data
test[1] = trans.transpose
test = test.transpose

#somewhere to sort the data into
cluster = Array.new(K) {|a| Array.new }

#calculate distances, sorting each point into a cluster
test.each do |point| #point[0] is the class, point[1] is the vector
    d = Array.new(K)
    center.each_index do |k|
        #the distance from the k-th center to the point's vector
        d[k] = (distance(point[1], center[k])).abs
    end
    #add the class to the cluster of the closest center
    nearest = d.index(d.min)
    cluster[nearest] << point
end

#calculate the accuracy
right = 0
wrong = 0
cluster.each_index do |k|
    cluster[k].each do |c|
        if c[0] == map[k]
            right += 1
        else
            wrong += 1
        end
    end
end

puts "Accuracy: #{right / (right + wrong).to_f}"

#calculate cohesion
cohesion = Array.new
cluster.each do |c|
    if c.transpose[1].nil?
        next 
    end
    arry = c.transpose[1].combination(2).map {|x| distance(x[0],x[1]) }
    sum = 0
    arry.each {|n| sum += n}
    cohesion << 1.0 / (sum / arry.size)
end
sum = 0
cohesion.each {|c| sum += c}
avg = sum / cohesion.size
puts "Average Cohesion: #{avg}"

#calculate separation
separation = Array.new
cluster.combination(2).each do |c|
    if c[0].transpose[1].nil?
        next
    elsif c[1].transpose[1].nil?
        next
    end
    #zip the 2 clusters together, and take the distance of each pair of features
    arry = c[0].transpose[1].product(c[1].transpose[1]).map {|n| distance(n[0], n[1]) }
    #take the average and we have a separation
    sum = 0
    arry.each {|n| sum += n}
    separation << sum.to_f / arry.size
end
sum = 0
separation.each {|s| sum += s }
avg = sum / separation.size
puts "Average Separation: #{avg}"
