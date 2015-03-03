# Temporary work around for upgrading RVM until
# https://github.com/fnichol/chef-rvm/issues/278 is fixed
bash "update RVM GPG keys" do
  user "root"
  cwd "/tmp"
  code "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
end
