#
# Provide Ninefold specific infrastructure information
#

Ohai.plugin(:Ninefold) do
  provides 'ninefold'

  def extract_router_list
    router_list = []
    dhcp_lease_dirs.each do |dir|
      Dir.glob(dir).each do |file|
        router = extract_router_ip(file)
        unless router.nil? || router.empty? || unreachable?(router)
          Chef::Log.debug "Ninefold: found virtual router '#{router}' in #{file}"
          router_list << router
        end
      end
    end
    router_list.uniq
  end

  def extract_router_ip(file)
    %x(grep 'dhcp-server-identifier' #{file} | tail -1 | awk '{print $NF}' | tr -d '\;').chomp
  end

  def unreachable?(router)
    !get_response(router, base_url)
  rescue
    true
  end

  def base_url
    '/latest/meta-data/'
  end

  def dhcp_lease_dirs
    %w(
    /var/lib/dhclient/*
    /var/lib/dhcp3/*
    /var/lib/dhcp/*
    )
  end

  def instance_meta_data
    %w(
    availability-zone
    cloud-identifier
    instance-id
    local-hostname
    public-hostname
    public-keys
    service-offering
    )
  end

  def network_meta_data
    %w(
    local-ipv4
    public-ipv4
    )
  end

  def get_response(host, path)
    # the caller takes responsibility for error handling
    http = Net::HTTP.new(host)
    http.open_timeout = 10
    http.read_timeout = 10
    http.get(path).body
  end

  def get_metadata(router, type)
    response = get_response(router, "#{base_url}#{type}")
    fail "#{type} not found" if response.downcase.include?('404 not found')
    response
  rescue => e
    Chef::Log.warn "Ninefold: '#{type}' from '#{router}' -> '#{e.message}'"
    nil
  end

  def ninefoldnet?(ipaddr)
    ipaddr.to_s.split('.').first == '172'
  rescue
    false
  end

  collect_data(:default) do
    require 'net/http'
    router_list = extract_router_list

    if router_list.empty?
      Chef::Log.debug 'Ninefold: no virtual routers found'
    else
      ninefold Mash.new

      # generate instance meta-data using other than the
      # NinefoldNet router i.e. not 172.x.y.z if possible

      preferred_router = router_list.find { |i| !ninefoldnet?(i) }
      preferred_router ||= router_list.first

      instance_meta_data.each do |key|
        ninefold[key] = get_metadata(preferred_router, key)
      end

      # generate network specific meta-data, ignore empty items

      ninefold['networks'] = Mash.new
      router_list.each do |router|
        router_mash = Mash.new
        network_meta_data.each do |key|
          metadata = get_metadata(router, key)
          router_mash[key] = metadata if metadata
        end
        unless router_mash.nil? || router_mash.empty?
          ninefold['networks'][router] = router_mash
        end
      end
    end
  end
end
