# This is a base 64-bit Ubuntu 14.02 LTS box. Use for testing your recipes.
# Do not use for production deployments. See the README for more info.

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network :private_network, type: "dhcp"
  config.vm.define "rideconnection-test-web"
  config.vm.define "rideconnection-test-db"
  config.vm.define "rideconnection-test-dual"
end
