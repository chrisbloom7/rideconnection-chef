include_recipe "apache2"
include_recipe "logrotate"

package "ruby-dev"

# Setup the deployer account
user node[:deployment][:name] do
  comment "Capistrano deployment account"
  password node[:deployment][:password] #fidgetyflamingos
  shell "/bin/bash"
  ssh_keys [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAudJPsL+XVdzFozj9dOt93feOR1IWT5uvaIDEAvub5kcu/z1v5kimXgFC7/KEK/HoDPLsjrQ4fHRkocWEW7uyF4Q+etE3wQT83E6EpPUEpRe4x7JRs2WmT5SVVy1t2lR+dWBFJLWmZh3ZSAnXgJbXFrwTqFB08BucBTGh2d1Mjo/Xi7lcsy9EIQnlRedLMTbB1o8XuML0AtAGkrZX5Z1uJ96j96GOdaVJYqskgbCZVejQUhNvZNSwYoB6GSBVy9PvwE5+RxGb89E/8hzLFastZKrkSn5ZTPirMOHEvdGnxPlCUyxoboohcqKy1A4Mt0Zb2lVm2E6BkmtfsCcFBMBYUw== chrisbloom7@gmail.com"
  ]
  supports :manage_home => true
  home "/home/#{node[:deployment][:name]}"
  action [ :create, :lock ]
end

# Add deployer to the www-data group
group "www-data" do
  members node[:deployment][:name]
  append true
end

# Passenger app config in Apache
template "/etc/apache2/sites-available/rideconnection" do
  source "rideconnection.erb"
  mode "0644"
  owner "root"
  group "root"
end

apache_site "rideconnection" do
  enable true
end

template "/etc/apache2/sites-available/rideconnection-ssl" do
  source "rideconnection-ssl.erb"
  mode "0644"
  owner "root"
  group "root"
  variables({
    rails_env: node[:rails_env],
    apps: node[:apps]
  })
end

apache_site "rideconnection-ssl" do
  enable true
end

## Project index
[
  "index.html",
  ".htaccess",
  "robots.txt"
].each do |index_file|
  template "/var/www/#{index_file}" do
    source "#{index_file}.erb"
    mode "0644"
    owner "root"
    group "root"
  end
end

# Setup deployment folders
directory "/home/#{node[:deployment][:name]}/rails" do
  owner "deployer"
  group "deployer"
  mode "0755"
  action :create
end

## App folders
node[:apps].each do |app_name, app_attrs|
  ### Application folder
  directory "/home/#{node[:deployment][:name]}/rails/#{app_attrs[:app_path]}" do
    owner "deployer"
    group "deployer"
    mode "2755"
    action :create
  end
  
  ### Capistrano folders
  [
    "current",
    "current/public",
    "releases",
    "shared",
    "shared/config",
    "shared/log",
  ].each do |path_name|
    directory "/home/#{node[:deployment][:name]}/rails/#{app_attrs[:app_path]}/#{path_name}" do
      owner "deployer"
      group "deployer"
      mode "0755"
      action :create
    end
  end

  ### Rotate logs
  logrotate_app app_name do
    enable    true
    path      "/home/#{node[:deployment][:name]}/rails/#{app_attrs[:app_path]}/shared/log/*.log"
    frequency "daily"
    rotate    90
    options   ["missingok", "delaycompress", "notifempty"]
    sharedscripts true
    postrotate <<-EOF
      touch /home/#{node[:deployment][:name]}/rails/#{app_attrs[:app_path]}/current/tmp/restart.txt
    EOF
  end
  
  ### Database conf
  template "/home/#{node[:deployment][:name]}/rails/#{app_attrs[:app_path]}/shared/config/database.yml" do
    source app_attrs[:database][:template] ? "#{app_attrs[:database][:template]}.database.yml.erb" : "database.yml.erb"
    mode "0644"
    owner "deployer"
    group "deployer"
    variables({
      rails_env: node[:rails_env],
      adapter:   app_attrs[:database][:adapter],
      database:  "#{app_attrs[:database][:prefix]}_#{node[:rails_env]}",
      username:  app_attrs[:database][:username],
      password:  app_attrs[:database][:password],
    })
  end
  
  ### Symlink for project index
  link "/home/#{node[:deployment][:name]}/rails/#{app_name}/current/public" do
    to "/var/www/#{app_name}"
  end
end

# SSL

## Ensure etc/apache2/certs exists
directory "etc/apache2/certs" do
  owner "apache"
  group "apache"
  mode "0755"
  action :create
end

file node[:ssl_cert] do
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "-----BEGIN CERTIFICATE-----
MIIFQDCCBCigAwIBAgIHK3gO9vWfMjANBgkqhkiG9w0BAQsFADCBtDELMAkGA1UE
BhMCVVMxEDAOBgNVBAgTB0FyaXpvbmExEzARBgNVBAcTClNjb3R0c2RhbGUxGjAY
BgNVBAoTEUdvRGFkZHkuY29tLCBJbmMuMS0wKwYDVQQLEyRodHRwOi8vY2VydHMu
Z29kYWRkeS5jb20vcmVwb3NpdG9yeS8xMzAxBgNVBAMTKkdvIERhZGR5IFNlY3Vy
ZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgLSBHMjAeFw0xMzA3MjUxNzQyMDNaFw0x
NjA3MjUxNzQyMDNaMEMxITAfBgNVBAsTGERvbWFpbiBDb250cm9sIFZhbGlkYXRl
ZDEeMBwGA1UEAxMVY2gucmlkZWNvbm5lY3Rpb24ub3JnMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAs0PRmKZM/P+dAXiSeUR0tn+S3jHNSzH+OMs0Fo25
5T8LyjEdDpaAoQZm2mZT6PUJtxuv1fyywNXv1q4U8NkQomYHUAlmqf3EDIeviOPp
rC6aF5C/0E9cHLNe7FzVTvuB2nH7gECNivHtK0rSkVrjxk/j8DVePtR0YR2c2qMd
ZI564tS684HtqSBjqC6zcaLkzbuQd2e+iVA1xgRU61nHd4LvzX9gZoGtAbTeQneR
3Yc8rr2uuOo0pdTgH/LCX83IjqBwOuRw+v48dZAwZfGtY//YzZTLAakd1DgbEtRl
O2jiCJA4Ore4CBfy+HWOeHQrQh+oPm4XKPLF2+8TY8hGlwIDAQABo4IBxTCCAcEw
DwYDVR0TAQH/BAUwAwEBADAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIw
DgYDVR0PAQH/BAQDAgWgMDUGA1UdHwQuMCwwKqAooCaGJGh0dHA6Ly9jcmwuZ29k
YWRkeS5jb20vZ2RpZzJzMS0xLmNybDBTBgNVHSAETDBKMEgGC2CGSAGG/W0BBxcB
MDkwNwYIKwYBBQUHAgEWK2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuZ29kYWRkeS5jb20v
cmVwb3NpdG9yeS8wdgYIKwYBBQUHAQEEajBoMCQGCCsGAQUFBzABhhhodHRwOi8v
b2NzcC5nb2RhZGR5LmNvbS8wQAYIKwYBBQUHMAKGNGh0dHA6Ly9jZXJ0aWZpY2F0
ZXMuZ29kYWRkeS5jb20vcmVwb3NpdG9yeS9nZGlnMi5jcnQwHwYDVR0jBBgwFoAU
QMK9J47MNIMwojPX+2yz8LQsgM4wOwYDVR0RBDQwMoIVY2gucmlkZWNvbm5lY3Rp
b24ub3Jnghl3d3cuY2gucmlkZWNvbm5lY3Rpb24ub3JnMB0GA1UdDgQWBBRKZNiV
up+DvsAL5DJC3zH/JV5jgDANBgkqhkiG9w0BAQsFAAOCAQEAWI8rqDqHJnDOSjfm
3viXXqtNvUap+9srKHA0pbvHq/FjtzntKyWuCO05aNczthT0E2X8h8bgcJ2kG6/h
tVgq2CJap0keMeQ0jpAWaNKd7CXh8AVmhKyo2kNbSdQkJKpa1VzR7PEOXZFEHuh9
PKPhyFLpl60rv245s2hC/ckkManwlgbaPd+WJbKQTen5RRtMCkKhPGP6qrMyuvV6
hMQ4h37vf6JpAdvHkvGZ2xdPOZOfov1eWoDkyCNbVBaG7jhhI5Oe5RbTAffwAAGd
faefZIQLT48fscjv2iSnZlzWs3FLMcWLNUz8pkZgI1KkDeMaI4lDu1ZmwlVAZir8
BMqtNg==
-----END CERTIFICATE-----"
end

file node[:ssl_cert_key] do
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAs0PRmKZM/P+dAXiSeUR0tn+S3jHNSzH+OMs0Fo255T8LyjEd
DpaAoQZm2mZT6PUJtxuv1fyywNXv1q4U8NkQomYHUAlmqf3EDIeviOPprC6aF5C/
0E9cHLNe7FzVTvuB2nH7gECNivHtK0rSkVrjxk/j8DVePtR0YR2c2qMdZI564tS6
84HtqSBjqC6zcaLkzbuQd2e+iVA1xgRU61nHd4LvzX9gZoGtAbTeQneR3Yc8rr2u
uOo0pdTgH/LCX83IjqBwOuRw+v48dZAwZfGtY//YzZTLAakd1DgbEtRlO2jiCJA4
Ore4CBfy+HWOeHQrQh+oPm4XKPLF2+8TY8hGlwIDAQABAoIBAAn04ldQJUaIC/hg
8gG6Q6E/RLECoxxiEnSlFKeMB58r+UOppquAwHQxHtVSiaaOtZNt/j4sYuFDAKcz
1AXsiHf8ortXSlR2u8TWZHF99ySREg3tBDpVrhAKBmOqZE6WuYegfQ+KhlIJTdrx
tPBN1AjXtxlIXYuv0SbzthqOpLtI9s2n/Ifp2+fukco3tc+VQZhatLrxPY0JaC3a
FE7P5MsO6C87pmZX86OdVbZxTutAe4gEhvXVT5T/IaZRWTf2j6MT0yZ+pmpzgllF
ydRhDQrMuI/TVRbS5Ra9oUz1x86m/lf0+CGlsLTzj/2E+1uCy9dKtLxO0jLkyliM
PeMrTkECgYEA2XFx2D2Ek/2sCB+LGpU7FGy/qwWJ2KxQcGSHnEG5NU5D7hEV0L2E
9IJZDZz9TPFeTf1r1Xj7ofvBhgqaSJ8UObcGroBgfbjnjNo+Cvl2kZdsfuJtchrA
ND+XesapauKb372kRuI/o/jV8haI6eBJhJe4xw1zbVokLPATRJOzGb0CgYEA0w1S
alBD+VUyaGtGwou7kGf+6hx9Fu8TqL0Jypq0AnshhYYhJb57vL9uSekQHcehbCAn
uQNt6SXyQGGnRwXx2Y7G5HLvEZAo6ljrhyuTM7jCYFm4KX0ilsIChavhf/FcIU/A
nQwag9axnuhTiz22Ow4XQ7jjIzeHVieY9s0vhOMCgYEAggwTZp0EWe5xoTocW/28
o+6Wg5aAZxJH2bCGWrIELxlsD0ownfN7PTFoSXgHFqmVGVfj0nzVIoALsjtNIvnh
gtMwL9Wf4BFiix9L1Ax3GYRS42BQzNmq8pTF6CxAzyhQyXQGeE6AeXUtn+hSYm4+
Cgsj/AjTbCdpU2cSXwVnLJECgYB0J5/VPSm7/uTITUpbZhYrquDELju2NIxoUOoj
pLMvrl7Lov95S3XEcsMbUHb7PNSdsrDKBZYnPCgwwM4Uq7PoncjfEFZ9Hw81swyl
jxjr3WK1LovJ4cH4oPxMX0Wzab3f44nJpVCugKmvIIRiXOt/Ywjwz7/KsRP+Gbr5
EgJ2KwKBgA+/cc/gLyspHqkywYWCvFAxSG6emMdLt2hXsh9QIJa5x6gR7EDaKwPT
3KiIX3zCe+HblN3LLx443mFigZPUIIhgQZP9771OYWkdiLbmsoXPWTUaTypyvGif
BJC95IdhD+/CnyqeoAFmPA5S7TLdS/07GslnaoyKzhXyo5qET/yb
-----END RSA PRIVATE KEY-----"
end
