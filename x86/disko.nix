{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            MBR = {
              type = "EF02"; # for grub MBR
              size = "1M";
              priority = 1; # Needs to be first partition
            };
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = [ "umask=0077" ]; # make it NOT world readable
                mountpoint = "/boot";
              };
            };
            # you may want to encrypt this as some keys will be stored here
            # root = {
            #   size = "100%";
            #   content = {
            #     type = "luks";
            #     # [...]
            #     settings = {
            #       keyFile = "/secrets/hdd.key";
            #       preOpenCommands = ''
            #         mkdir -m 0755 -p /key
            #         sleep 2 # To make sure the usb key has been loaded
            #         mount -n -t vfat -o ro / /key
            #       '';
            #     };
            #   };
            # saving it unencrypted for easier access, 
            # knowing it needs to be kept in a safe place.
            # encryption/decryption can fail...
            # this is no different than a printout of the keys
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  }

