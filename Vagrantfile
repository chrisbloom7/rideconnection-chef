# This is a simple 64-bit Ubuntu 14.02 LTS box that has Chef pre-installed. Use
# for testing your recipes. Do not use for production deployments.

Vagrant::Config.run do |config|
  config.vm.define "rideconnection-production-web" do |node_config|
    node_config.vm.box = 'ubuntu/trusty64'
    node_config.vm.network :hostonly, "33.33.33.10"
  end
  
  config.vm.define "rideconnection-production-db" do |node_config|
    node_config.vm.box = 'ubuntu/trusty64'
    node_config.vm.network :hostonly, "33.33.33.11"
  end
  
  config.vm.define "rideconnection-staging-app" do |node_config|
    node_config.vm.box = 'ubuntu/trusty64'
    node_config.vm.network :hostonly, "33.33.33.12"
  end
end
