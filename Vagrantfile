# This is a base 64-bit Ubuntu 14.02 LTS box. Use for testing your recipes.
# Do not use for production deployments. See the README for more info.

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network :private_network, type: "dhcp"
  config.vm.define "rideconnection-test-web"
  config.vm.define "rideconnection-test-db"
  config.vm.define "rideconnection-test-dual"
  config.trigger.after :up, :stdout => false, :stderr => false do
    get_ip_address = %Q(vagrant ssh #{@machine.name} -c 'ifconfig | grep -oP "inet addr:\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}" | grep -oP "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}" | tail -n 2 | head -n 1')
    @logger.debug "Running `#{get_ip_address}`"
    output = `#{get_ip_address}`
    @logger.debug "Output received:\n----\n#{output}\n----"
    puts "==> #{@machine.name}: Available on DHCP IP address #{output.strip}"
    @logger.debug "Finished running :after trigger"
  end  
end
