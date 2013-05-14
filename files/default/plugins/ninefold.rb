#
# Provide Ninefold specific infrastructure information
#

require 'net/http'

def get_router_list
  router_list = []
  %w(
    /var/lib/dhclient/*
    /var/lib/dhcp3/*
    /var/lib/dhcp/*
  ).each do |dir|
    Dir.glob(dir).each do |file|
      router = `grep 'dhcp-server-identifier' #{file} | tail -1 | awk '{print $NF}' | tr -d '\;'`
      unless router.nil? or router.empty?
        Chef::Log.debug "Ninefold: found virtual router '#{router}' in #{file}"
        router_list << router
      end
    end
  end
  router_list.uniq
end

def get_metadata(router, type)
  begin
    Net::HTTP.get(router, "/latest/meta-data/#{type}")
  rescue SocketError
    Chef::Log.error "Ninefold: error retrieving meta-data '#{type}' from '#{router}'"
    nil
  end
end


provides 'ninefold'

router_list = get_router_list
if router_list.empty?
  Chef::Log.debug "Ninefold: meta-data not available - no virtual routers found"
else

  ninefold Mash.new

  # generate instance meta-data
  %w(
    availability-zone
    instance-id
    local-hostname
    public-hostname
    service-offering
  ).each do |key|
    ninefold[key] = get_metadata(router_list[0], key)
  end

  # generate network specific meta-data
  ninefold['networks'] = Array.new
  router_list.each do |router|
    router_mash = Mash.new
    router_mash['router'] = router
    %w(
      local-ipv4
      public-ipv4
    ).each do |key|
      router_mash[key] = get_metadata(router, key)
    end
    ninefold['networks'] << router_mash
  end
end
