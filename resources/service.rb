require 'json'

resource_name :fail2ban_service

default_action :create

property :name, name_attribute: true, required: true, kind_of: String
property :enabled, kind_of: String, default: 'true'
property :actions, kind_of: String
property :port, kind_of: String
property :filter, kind_of: String
property :findtime, kind_of: String
property :bantime, kind_of: String
property :banaction, kind_of: String
property :protocol, kind_of: String
property :backend, kind_of: String
property :ignorecommand, kind_of: String
property :logpath, kind_of: String
property :maxretry, kind_of: String

action :create do
  include_recipe 'fail2ban::default'

  template "/etc/fail2ban/jail.d/#{new_resource.name}.conf" do
    source 'service.conf.erb'
    cookbook 'fail2ban'
    variables(
      name: new_resource.name,
      enabled: new_resource.enabled,
      actions: new_resource.actions,
      params: {
        port: @port,
        filter: @filter,
        logpath: @logpath,
        findtime: @findtime,
        bantime: @bantime,
        maxretry: @maxretry,
        protocol: @protocol,
        banaction: @banaction,
        backend: @backend,
        ignorecommand: @ignorecommand
      }
    )
    notifies :restart, 'service[fail2ban]'
  end
end
