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
    l.shift
    data << l
end
trans = data.transpose

#normalize data
trans.each do |t|
    min = t.min
    max = t.max
    t.map! {|x| (x - min) / (max - min)}
end
data = trans.transpose


#initialize K random cluster centers
center = Array.new(K)
center.each_index do |i|
    min = trans[i].min
    max = trans[i].max
    center[i] = Array.new(data[i].size) { |x| rand * (max - min) + min }
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

    #somewhere to sort the data into
    cluster = Array.new(K) {|a| Array.new }

    #calculate distances, sorting each point into a cluster
    data.each do |datum|
        d = Array.new(K)
        center.each_index do |i|
            d[i] = (distance(datum,center[i])).abs
        end
        cluster[d.index(d.min)] << datum
    end

    #calculate the new centers
    newcenter = Marshal.load( Marshal.dump(center) ) #deep copy
    newcenter.each_index do |n|
        newcenter[n].each_index do |i|
            sum = 0
            cluster[n].each {|x| sum += x[i]}
            avg = sum / newcenter[n].size
            newcenter[n][i] = avg
        end
    end

    #determine how much we've changed
    stable = true
    newcenter.each_index do |i|
        d = distance(center[i], newcenter[i]).abs
        puts d
        if d > Limit
            stable = false
        end
    end

    #update the cluster centers
    center = Marshal.load( Marshal.dump(newcenter) )

end
