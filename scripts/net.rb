require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)
load "util.rb"

###

template = File.foreach("../template/servers.csv")
ca = File.read("../static/ca.crt")
tls_wrap = read_tls_wrap("auth", 1, "../static/ta.key", 1)

cfg = {
  ca: ca,
  tlsWrap: tls_wrap,
  cipher: "AES-256-GCM",
  digest: "SHA512",
  compressionFraming: 0,
  compressionAlgorithm: 0,
  checksEKU: true
}

recommended = {
  id: "default",
  name: "Default",
  comment: "256-bit encryption",
  ovpn: {
    cfg: cfg,
    endpoints: [
      "UDP:443",
      "UDP:80",
      "UDP:53",
      "UDP:1194",
      "UDP:54783",
      "TCP:443",
      "TCP:587",
      "TCP:21",
      "TCP:22",
      "TCP:80",
      "TCP:143",
      "TCP:3306",
      "TCP:8080",
      "TCP:54783",
      "TCP:1194"
    ]
  }
}
presets = [recommended]

defaults = {
  :username => "abc1efg2-hijk345",
  :country => "US"
}

###

servers = []
template.with_index { |line, n|
  id, country, area = line.strip.split(",")
  id = id.downcase
  hostname = "#{id}.windscribe.com"

  addresses = nil
  if ARGV.include? "noresolv"
    addresses = []
    #addresses = ["1.2.3.4"]
  else
    addresses = Resolv.getaddresses(hostname)
  end
  addresses.map! { |a|
    IPAddr.new(a).to_i
  }

  server = {
    :id => id,
    :country => country
  }
  if !area.nil?
    if area == "WINDFLIX"
      server[:category] = area.downcase
    else
      server[:area] = area
    end
  end
  server[:hostname] = hostname
  server[:addrs] = addresses
  servers << server
}

###

infra = {
  :servers => servers,
  :presets => presets,
  :defaults => defaults
}

puts infra.to_json
puts
