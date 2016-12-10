require 'json'

resource_name :fail2ban_service

default_action :create

property :name, name_attribute: true, required: true, kind_of: String
property :enabled, kind_of: String, default: 'true'
property :actions, kind_of: String
property :port, kind_of: String
property :filter, kind_of: String
property :findtime, kind_of: Integer
property :bantime, kind_of: Integer
property :banaction, kind_of: String
property :protocol, kind_of: String
property :backend, kind_of: String
property :ignorecommand, kind_of: String
property :logpath, kind_of: String
property :maxretry, kind_of: Integer

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
        port: new_resource.port,
        filter: new_resource.filter,
        logpath: new_resource.logpath,
        findtime: new_resource.findtime,
        bantime: new_resource.bantime,
        maxretry: new_resource.maxretry,
        protocol: new_resource.protocol,
        banaction: new_resource.banaction,
        backend: new_resource.backend,
        ignorecommand: new_resource.ignorecommand
      }
    )
    notifies :restart, 'service[fail2ban]'
  end
end
