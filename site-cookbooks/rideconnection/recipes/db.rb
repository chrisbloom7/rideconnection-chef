include_recipe "database::postgresql"

# Setup each application database and user:
postgresql_connection_info = {
  :host => "127.0.0.1",
  :port => 5432,
  :username => "postgres",
  :password => node["postgresql"]["password"]["postgres"]
}

## Ridepilot
postgresql_database "ridepilot_#{node[:rails_env]}" do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user "ridepilot" do
  connection postgresql_connection_info
  password "ridepilot"
  action :create
end

postgresql_database_user "ridepilot" do
  connection postgresql_connection_info
  password "ridepilot"
  action :create
end

postgresql_database_user "ridepilot" do
  connection    postgresql_connection_info
  password      "ridepilot"
  database_name "ridepilot_#{node[:rails_env]}"
  host          "%"
  privileges    [:all]
  action        :grant
end

## Wiseguide
postgresql_database "wiseguide_#{node[:rails_env]}" do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user "wiseguide" do
  connection postgresql_connection_info
  password "wiseguide"
  action :create
end

postgresql_database_user "wiseguide" do
  connection    postgresql_connection_info
  password      "wiseguide"
  database_name "wiseguide_#{node[:rails_env]}"
  host          "%"
  privileges    [:all]
  action        :grant
end

## Lowdown
postgresql_database "lowdown_#{node[:rails_env]}" do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user "lowdown" do
  connection postgresql_connection_info
  password "lowdown"
  action :create
end

postgresql_database_user "lowdown" do
  connection    postgresql_connection_info
  password      "lowdown"
  database_name "lowdown_#{node[:rails_env]}"
  host          "%"
  privileges    [:all]
  action        :grant
end
