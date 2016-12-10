require 'json'

resource_name :fail2ban_filter

default_action :create

property :name, name_attribute: true, required: true, kind_of: String
property :fail_regex, kind_of: Array
property :ignore_regex, kind_of: Array

action :create do
  include_recipe 'fail2ban::default'

  template "/etc/fail2ban/filter.d/#{new_resource.name}.conf" do
    source 'filter.conf.erb'
    cookbook 'fail2ban'
    variables(
      fail_regex: [new_resource.fail_regex].flatten,
      ignore_regex: [new_resource.ignore_regex].flatten
    )
    notifies :restart, 'service[fail2ban]'
  end
end
