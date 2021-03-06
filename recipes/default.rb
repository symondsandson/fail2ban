#
# Cookbook Name:: fail2ban
# Recipe:: default
#
# Copyright 2009-2016, Chef Software, Inc.
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

# epel repository is needed for the fail2ban package on rhel
include_recipe 'yum-epel' if platform_family?('rhel')

package 'fail2ban' do
  action :install
end

service 'fail2ban' do
  supports [status: true, restart: true]
  action [:start, :enable]

  if platform?('ubuntu') && node['platform_version'].to_f >= 15.10
    provider Chef::Provider::Service::Systemd
  end

  if (platform?('ubuntu') && node['platform_version'].to_f < 12.04) ||
     (platform?('debian') && node['platform_version'].to_f < 7)
    # status command returns non-0 value only since fail2ban 0.8.6-3 (Debian)
    status_command "/etc/init.d/fail2ban status | grep -q 'is running'"
  end
end

node['fail2ban']['filters'].each do |name, options|
  fail2ban_filter name do
    fail_regex options['failregex']
    ignore_regex options['ignoreregex']
  end
end

node['fail2ban']['services'].each do |name, options|
  fail2ban_service name do
    enabled options['enabled']
    port options['port']
    filter options['filter']
    findtime options['findtime']
    bantime options['bantime']
    banaction options['banaction']
    protocol options['protocol']
    backend options['backend']
    ignorecommand options['ignorecommand']
    actions options['actions']
    logpath options['logpath']
    maxretry options['maxretry']
  end
end

file "/etc/fail2ban/jail.d/defaults-debian.conf" do
  action :delete
end

template '/etc/fail2ban/fail2ban.conf' do
  source 'fail2ban.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[fail2ban]'
end

template '/etc/fail2ban/jail.local' do
  source 'jail.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[fail2ban]'
end
