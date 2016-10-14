# Experimental Docker Based Development Environment, Automatic Service Discovery

The idea of this devenv is to simulate the existence of an automatic service discovery functionality on a local environment. Is common that when working on a distributed platform different components needs to resolve its dependencies based on a specific environment. It's desirable that every component, being the expert on its own dependencies, resolves in a automated way where those dependencies exists and how can they be accessed. With the help of Vagrant, VirtualBox, SkyDNS, etcd and Registrator docker containers this devenv resolves the problem, attaching a listener to every container running in the virtual machine and registering as etcd nodes, with the added value of making them also discoverable by name using DNS queries. As a disclaimer, this devenv is based on an OS X machine. 

## Prerequisites
This is a virtualized environment, in order to make it easily replicable across development machines, so it depends on a Vagrant installation and a VirtualBox installation. For OS X machines quick scripts can be found on brew repositories, [this reference](http://sourabhbajaj.com/mac-setup/Vagrant/README.html) can be helpful too.

## Commands
Its recommendable to create an alias on the devenv script to simplify the interactions, this can be achieved running: 
```
	# get current directory
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	# add alias for the dev env
	alias devenv='sh $DIR/devenv.sh'
```
After the setup is completed we can startup the environment with a quick: 
```
pabs-machine:devenv-skydns-discovery p.rodriguez$ devenv up
starting up devenv
******************
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Checking if box 'ubuntu/trusty64' is up to date...
...
==> default: Starting containers ...
==> default: ***********************
==> default:  
==> default: cleaning up ...
==> default: ***************
==> default: e9b307321072
==> default:  
==> default: Starting etcd0 node ...
==> default: ***********************
==> default: 4ff62882bd9cbf58998e3ebef85507038182e5c8df891305e99d8cced4e6b251
==> default:  
==> default: configuring skydns on etcd ...
==> default: ******************************
==> default:  
==> default: Starting skydns service ...
==> default: ***************************
==> default: e513729aa5862547c108b45c9240fe2f1d1a2da1f890162c6c4b117baed8a763
==> default:  
==> default: Starting registrator ...
==> default: ***********************
==> default: 2e65747e4c0f7e584def4969338b327ae2db9680a8bbd367e26cb1bc944c5165
==> default:  
...
```
Note that the first time this command runs will take **several minutes** since it needs to download the host VM, provision docker in it and download the required images, on subsequent executions the startup script should take less than 30 seconds. In order to stop the underlying virtual machine and containers running `devenv down` command will teardown all resources. 

Next a quick reference for the available commands at this time: 
 - `devenv up` => starts up and download latest available dependencies 
 - `devenv down` => shutdown the environment
 - `devenv reload` => reloads all the containers in the environment, pretty useful while developing in the environment (quick changes on configurations or components) or to refresh container images
 - `devenv status` => lists all running containers, a `-a` parameter can be added to include stopped containers
 - `devenv logs <container-name|id>` => shows the logs available for the **main process** in the selected container (names and ids can be obtained using `devenv status -a`).
 - `devenv inspect <container-name|id>` => logs in on the container bash terminal, if it was included, helpful to troubleshoot and to review secondary logs, configurations, etc.

  

