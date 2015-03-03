name "web_server"
description "Builds a web server for Rails apps on Passenger"
run_list(
  "recipe[git]",
  "recipe[logrotate]",
  "recipe[rideconnection::rvm]",
  "recipe[rvm::system]",
  # "recipe[apache2]",
  # "recipe[apache2::logrotate]",
  # "recipe[apache2::mod_ssl]",
  # "recipe[apache2::mod_rewrite]",
  # "recipe[passenger_apache2::mod_rails]",
  # "recipe[postgresql::ruby]",
  # "recipe[postgresql::client]",
  # "recipe[imagemagick::rmagick]",
  # "recipe[rideconnection::web]",
)
