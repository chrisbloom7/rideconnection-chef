name "db_server"
description "Builds a database server using Postgresql"
run_list(
  "recipe[postgresql::server]",
  "recipe[postgresql::config_initdb]",
  "recipe[postgresql::contrib]",
  "recipe[postgis]",
  "recipe[rideconnection::db]",
)
