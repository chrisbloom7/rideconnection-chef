name "base_server"
description "Prepares a Ubuntu server for use with RideConnection apps"
run_list( 
  "recipe[locale]",
  "recipe[apt]",
  "recipe[apt-upgrade-once]",
  "recipe[build-essential]",
  "recipe[openssl]",
  "recipe[apticron]",
  "recipe[rideconnection::base]"
)
