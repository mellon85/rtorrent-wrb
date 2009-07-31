
class Node
    def initialize
        @childrens = {}
        @files = []
    end

    def addFile( str ) 
        @files << str
    end

    def addSubDir(str)
        if @childrens[str] == nil then
            @childrens[str] = Node.new
        end
        return @childrens[str]
    end
end

def directory_path(path,root) 
    if path.length == 1 then
        root.addFile(path[0])
    else
        i = root.addSubDir(path[0].chop)
        path.shift
        directory_path(path,i)
    end
end

def directorify(strings)
    root = Node.new
    strings.each do |x|
        str = []
        x.each("/") { |y| str << y }
        directory_path(str,root)
    end
    return root
end

#require 'pp'
#tree = directorify(["aa/bb/cc","aa/bb/dd","aa/ff"])
#pp tree
