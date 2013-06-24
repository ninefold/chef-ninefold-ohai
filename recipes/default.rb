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

# update the client.rb with plugin location so it just works

include_recipe 'chef-client::config'
