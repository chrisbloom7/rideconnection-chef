# Remove swap space after passenger is built
swap_file '/var/swapfile' do
  action :remove
end