#initializers/carrierwave.rb

CarrierWave.configure do |config|

  config.storage = :grid_fs

  config.grid_fs_connection = Mongoid.database    # this sets config.grid_fs_database
  config.grid_fs_access_url = "/file"             # pre-pends to the filename path, must match your routes and grid_fs controller
  #config.grid_fs_host = 'localhost'              # this is redundant because it is a carrierwave default
  #config.grid_fs_port = "27017"                  # this is redundant because it is a carrierwave default
end
