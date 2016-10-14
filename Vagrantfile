required_plugins = %w(vagrant-vbguest)

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # just in case, seems to cause some problems with latest virtualbox 
  config.vm.provider :virtualbox do |vb|
    #memory
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end
  config.vm.hostname = "fandango-devenv-host.dev"
  config.vm.box = "ubuntu/trusty64"
  
  # haproxy ports
  config.vm.network "forwarded_port", guest: 8080, host:8080  

  # node direct ports
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  
  # netty direct ports
  config.vm.network "forwarded_port", guest: 5000, host: 5000
  
  # etcd client port
  config.vm.network "forwarded_port", guest: 2379, host: 2379

  config.vm.provision "docker",
    images: ["anapsix/alpine-java", "quay.io/coreos/etcd", "gliderlabs/registrator", "mysql/mysql-server", "skynetservices/skydns:2.5.3a"]

  # startup devenv containers 
  config.vm.provision :shell, run: "always", path: "internal/devenv-startup.sh"
  
end
