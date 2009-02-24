# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

$last_update = Time.at(0)

class Controller < Ramaze::Controller
  layout '/page'
  helper :xhtml
  engine :Ezamar

  def check_update
      if ($last_update + (60*5)) < Time.now then
          #@TODO update data to DB
          $last_update = Time.now
      end
  end
end

# Here go your requires for subclasses of Controller:
require 'controller/main'
require 'controller/torrent'

