require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

def read_static_key(file, from, to)
    lines = File.foreach(file)
    key = ""
    lines.with_index { |line, n|
        next if n < from or n >= to
        key << line.strip
    }
    return [[key].pack("H*")].pack("m0")
end

###

servers = File.foreach("../template/servers.csv")
ca = File.read("../static/ca.crt")
tls_key = read_static_key("../static/ta.key", 1, 17)
tls_strategy = "auth"
tls_dir = 1

cfg = {
    ca: ca,
    ep: [
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
    ],
    cipher: "AES-256-GCM",
    auth: "SHA512",
    wrap: {
        strategy: tls_strategy,
        key: {
            data: tls_key,
            dir: tls_dir,
        }
    },
    frame: 1,
    compression: 1,
    eku: true
}

recommended = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: cfg
}
presets = [recommended]

defaults = {
    :username => "abc1efg2-hijk345",
    :pool => "us-central",
    :preset => "default"
}

###

pools = []
servers.with_index { |line, n|
    id, country, area = line.downcase.strip.split(",")
    hostname = "#{id}.windscribe.com"

    addresses = nil
    if ARGV.length > 0 && ARGV[0] == "noresolv"
        addresses = []
        #addresses = ["1.2.3.4"]
    else
        addresses = Resolv.getaddresses(hostname)
    end
    addresses.map! { |a|
        IPAddr.new(a).to_i
    }

    pool = {
        :id => id,
        :name => "",
        :country => country.downcase
    }
    pool[:area] = area if !area.nil?
    pool[:hostname] = hostname
    pool[:addrs] = addresses
    pools << pool
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
