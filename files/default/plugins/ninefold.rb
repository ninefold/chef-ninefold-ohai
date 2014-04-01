#
# Provide Ninefold specific infrastructure information
#

provides 'ninefold'

require 'net/http'

router_list = get_router_list

if router_list.empty?
  Chef::Log.debug "Ninefold: meta-data not available - no virtual routers found"
else

  ninefold Mash.new

  # generate instance meta-data using other than the
  # NinefoldNet router i.e. not 172.x.y.z if possible

  preferred_router = router_list.detect{ |i| !ninefoldnet?(i) } || router_list.first

  %w(
    availability-zone
    instance-id
    local-hostname
    public-hostname
    service-offering
  ).each do |key|
    ninefold[key] = get_metadata(preferred_router, key)
  end

  # generate network specific meta-data, ignore empty items
  # which could be from old virtual router entries

  ninefold['networks'] = Mash.new
  router_list.each do |router|
    router_mash = Mash.new
    %w(
      local-ipv4
      public-ipv4
    ).each do |key|
      metadata = get_metadata(router, key)
      router_mash[key] = metadata if metadata
    end
    ninefold['networks'][router] = router_mash unless router_mash.empty?
  end
end

private

def get_router_list
  router_list = []
  %w(
    /var/lib/dhclient/*
    /var/lib/dhcp3/*
    /var/lib/dhcp/*
  ).each do |dir|
    Dir.glob(dir).each do |file|
      router = %x{grep 'dhcp-server-identifier' #{file} | tail -1 | awk '{print $NF}' | tr -d '\;'}.chomp
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
    response = Net::HTTP.get(router, "/latest/meta-data/#{type}")
    raise "router returned metadata not found" if response.downcase.include?('404 not found')
    response
  rescue => e
    Chef::Log.debug "Ninefold: error retrieving meta-data '#{type}' from '#{router}' -> '#{e.message}'"
    nil
  end
end

def ninefoldnet?(ipaddr)
  ipaddr.to_s.split('.').first == '172' rescue false
end

