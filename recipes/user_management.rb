#
# Cookbook Name:: rabbitmq
# Recipe:: user_management
#
# Copyright 2013, Grégoire Seux
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "rabbitmq::default"
include_recipe "rabbitmq::virtualhost_management"

enabled_users = node['rabbitmq']['enabled_users']

Chef::Log.info( enabled_users.each)

enabled_users.each do |user|
  rabbitmq_user user['name'] do
    password user['password']
    action :add
    notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
  end
  rabbitmq_user user['name'] do
    user_tag user['tag']
    action :set_user_tags
    notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
  end
  user['rights'].each  do |r|
    rabbitmq_user user['name'] do
      vhost r['vhost']
      permissions "#{r['conf']} #{r['write']} #{r['read']}"
      action :set_permissions
    notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
    end
  end
end

disabled_users = node['rabbitmq']['disabled_users']

disabled_users.each do |user|
  rabbitmq_user user do
    action :delete
    notifies :restart, "service[#{node['rabbitmq']['service_name']}]"
  end
end
