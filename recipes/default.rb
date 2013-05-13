#
# Cookbook Name:: ninefold_ohai_plugins
# Recipe:: default
#
# Copyright (C) 2013 Ninefold Pty Limited
# 
# All rights reserved - Do Not Redistribute
#

node.set['ohai']['plugins']['ninefold_ohai_plugins'] = 'plugins'
include_recipe 'ohai'
