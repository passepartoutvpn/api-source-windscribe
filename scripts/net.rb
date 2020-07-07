require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)
load "util.rb"

###

servers = File.foreach("../template/servers.csv")
ca = File.read("../static/ca.crt")
tls_wrap = read_tls_wrap("auth", 1, "../static/ta.key", 1, 17)

cfg = {
    ca: ca,
    wrap: tls_wrap,
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
    frame: 1,
    compression: 1,
    eku: true
}

external = {
    hostname: "${id}.windscribe.com"
}

recommended = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: cfg,
    external: external
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

    pool = {
        :id => id,
        :country => country
    }
    if !area.nil?
        if area == "WINDFLIX"
            pool[:category] = area.downcase
        else
            pool[:area] = area
        end
    end
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
