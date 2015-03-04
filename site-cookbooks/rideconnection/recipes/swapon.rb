# Create a swap space for building passenger
swap_file '/var/swapfile' do 
  size `free -b | grep "Mem:" | awk '{print $2}'`.to_i * 2 / 1024 / 1024
end