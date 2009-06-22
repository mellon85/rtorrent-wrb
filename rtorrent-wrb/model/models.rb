# Here goes your database connection and options:

class Torrent
    attr_accessor :name, :size, :downloaded, :uploaded, :up
    attr_accessor :down, :ratio, :active, :priority, :torrent_id

    def initialize(name, size, downloaded, uploaded, up, down, ratio,
                   active, priority, torrent_id)
        @name = name
        @size = size
        @downloaded = downloaded
        @uploaded = uploaded
        @up = up
        @down = down
        @ratio = ratio
        @active = active
        @priority = priority
        @torrent_id = torrent_id
    end
end

class TorrentFile
    attr_accessor :name, :size, :downloaded, :priority

    def initialize(name,size,downloaded,priority)
        @name = name
        @size = size
        @downloaded = downloaded
        @priority = priority
    end
end

class Tracker
    attr_accessor :url

    def initialize(url)
        @url = url
    end
end
