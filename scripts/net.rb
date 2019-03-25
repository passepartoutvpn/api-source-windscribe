require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

countries = File.foreach("../template/countries.txt")

ca = File.read("../certs/ca.crt")
tlsStrategy = "auth"
tlsKeyLines = File.foreach("../certs/ta.key")
tlsDirection = 1

tlsKey = ""
tlsKeyLines.with_index { |line, n|
    next if n < 1 or n >= 17
    tlsKey << line.strip
}
tlsKey = [[tlsKey].pack("H*")].pack("m0")

###

pools = []
countries.with_index { |line, n|
    country = line.strip.downcase
    hostname = "#{country}.windscribe.com"

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
        :id => country,
        :name => "",
        :country => country,
        :hostname => hostname,
        :addrs => addresses
    }
    pools << pool
}

strong = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: {
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
        ca: ca,
        wrap: {
            strategy: tlsStrategy,
            key: {
                data: tlsKey,
                dir: tlsDirection,
            }
        },
        frame: 1,
        compression: 1,
        eku: true
    }
}
presets = [strong]

defaults = {
    :username => "abc1efg2-hijk345",
    :pool => "us-central",
    :preset => "default"
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
