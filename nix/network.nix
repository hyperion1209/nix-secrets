{lib, ...}: {
  networking = let
    replacedLastOctet = ip: newOctet: let
      parts = lib.splitString "." ip;
      start = lib.take 3 parts;
      final = lib.concatStringsSep "." (start ++ [newOctet]);
    in
      final;
    makeSubnet = ip: prefixLength: {
      wildcard = replacedLastOctet ip "*";
      inherit prefixLength;
      inherit ip;
      cidr = "${ip}/${builtins.toString prefixLength}";
      gateway = replacedLastOctet ip "1";
      ssh = 22;
      # The first three octets of the IP address
      triplet = lib.concatStringsSep "." (lib.take 3 (lib.splitString "." ip));
    };

    # Return a set of host attrs
    makeHost = name: ip: tsIP: mac: user: {
      ${name} = {
        inherit name ip tsIP mac user;
      };
    };
    defaultUser = "marius";
    emptyIP = "";
    emptyMac = "";
  in rec {
    #
    # ========== Subnets ==========
    #
    subnets = {
      home =
        (makeSubnet "192.168.1.0" 24)
        // {
          hosts = lib.mergeAttrsList [
            (makeHost "blackbird" emptyIP "100.89.107.66" "28:c6:3f:d2:6f:b8" defaultUser)
            (makeHost "oldfart" emptyIP "100.103.43.111" emptyMac defaultUser)
            (makeHost "wingman" "192.168.1.122" "100.99.255.32" "6c:4b:90:5d:24:2e" defaultUser)
            (makeHost "ironfist" "192.168.1.123" "100.94.45.97" "f8:75:a4:17:ec:eb" defaultUser)
            (makeHost "maverick" "192.168.1.124" "100.79.196.111" "98:fa:9b:43:03:21" defaultUser)
            (makeHost "claymore" "192.168.1.125" "100.87.99.49" "f8:75:a4:bf:ad:17" defaultUser)
          ];
        };
    };

    #
    # ========== Private DNS/host entries ==========
    #
    home.hosts = {};

    # Ports used for services
    ports = {
      tcp = {
        ssh = 22;
        grafana = 3030;
        adguard = 3000;
      };
      udp = {
      };
    };

    #
    # ========== ssh entries ==========
    #
    ssh = {
      yubikeyHostsWithDomain = []; # hostnames I want private, that use my domain
      yubikeyHosts = []; # hostnames outside of my domain
      forwardAgentUntrusted = []; # domainHosts entries that I don't trust to use agent forwarding
      matchBlocks = lib: {};
    };
  };
}
