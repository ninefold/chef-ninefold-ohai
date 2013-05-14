#
# Cookbook Name:: ninefold_ohai
# Recipe:: default
#
# Copyright (C) 2013 Ninefold Pty Limited
# 
# All rights reserved - Do Not Redistribute
#

# inject the plugin into the node
node.set['ohai']['plugins']['ninefold_ohai'] = 'plugins'
include_recipe 'ohai'

# update the client.rb with plugin location
# make sure the chef_server_url doesn't get overwritten!
node.set['chef_client']['server_url'] = Chef::Config[:chef_server_url]
include_recipe 'chef-client::config'
