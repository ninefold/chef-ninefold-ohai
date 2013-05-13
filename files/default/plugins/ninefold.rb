#
# Provide Ninefold specific infrastructure information
#

require 'net/http'

def get_router_ipaddress
  catch :router_found do
    %w(
      /var/lib/dhclient/*
      /var/lib/dhcp3/*
      /var/lib/dhcp/*
    ).each do |dir|
      Dir.glob(dir).each do |file|
        router = `grep 'dhcp-server-identifier' #{file} | tail -1 | awk '{print $NF}' | tr -d '\;'`
        unless router.nil? or router.empty?
          Chef::Log.debug "Found router '#{router}' in #{file}"
          throw :router_found
        end
      end
    end
  end
  router
end

def get_metadata(router, type)
  begin
    Net::HTTP.get(router, "/latest/meta-data/#{type}")
  rescue SocketError
    Chef::Log.error "Error retrieving meta-data '#{type}' from '#{router}'"
    nil
  end
end

provides 'ninefold'
router = get_router_address
if router
  ninefold Mash.new
  %w(
    availability-zone
    instance-id
    local-hostname
    local-ipv4
    public-hostname
    public-ipv4
    service-offering
  ).each do |key|
    ninefold[key] = get_metadata(router, key)
  end
end
