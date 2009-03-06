module Ramaze
    module Helper
        module SHA1
            require 'digest/sha1'
            def sha1(text)
                Digest::SHA1.hexdigest(text)
            end
        end
    end
end
