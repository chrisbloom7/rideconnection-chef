require 'librarian/chef/integration/knife'

cookbook_path    [Librarian::Chef.install_path, "site-cookbooks"]
node_path        "nodes"
role_path        "roles"
environment_path "environments"
data_bag_path    "data_bags"
#encrypted_data_bag_secret "data_bag_key"
