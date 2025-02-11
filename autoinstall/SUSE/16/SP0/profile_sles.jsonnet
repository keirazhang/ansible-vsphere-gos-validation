// This is a Jsonnet file referring to
// https://github.com/agama-project/agama/blob/master/rust/agama-lib/share/examples/profile.jsonnet.
// Please, check https://jsonnet.org/ for more information about the language.
// For the schema, see
// https://github.com/openSUSE/agama/blob/master/rust/agama-lib/share/profile.schema.json

// The "hw.libsonnet" file contains hardware information from the "lshw" tool.
// Agama generates this file at runtime by running (with root privileges):
//
//   lshw -json
//
// There are included also helpers to search this hardware tree. To see helpers check
// "/usr/share/agama-cli/agama.libsonnet"
local agama = import 'hw.libsonnet';

// Find the biggest disk which is suitable for installing the system.
local findBiggestDisk(disks) =
  local sizedDisks = std.filter(function(d) std.objectHas(d, 'size'), disks);
  local sorted = std.sort(sizedDisks, function(x) -x.size);
  sorted[0].logicalname;


// Find the network interface name
local nicName = agama.findByID(agama.lshw, 'network').logicalname;

{
  product: {
    id: "SLES"
  },
  software: {
    patterns: [
    ]
  },
{% if new_user is defined and new_user %}
  user: {
    fullName: "{{ new_user }}",
    password: "{{ vm_password }}",
    userName: "{{ new_user }}",
    autologin: true
  },
{% endif %}
  root: {
    password: "{{ vm_password }}",
    sshPublicKey: "{{ ssh_public_key }}"
  },
  localization: {
    language: "en_US",
    keyboard: "us",
    timezone: "America/New_York"
  },
  storage: {
    guided: {
      target: {
        disk: findBiggestDisk(agama.selectByClass(agama.lshw, 'disk'))
      },
      boot: {
        configure: true
      },
      space: {
        policy: "delete"
      }
   }
  },
  network: {
    connections: [
      {
        id: "Wired connection 1",
        interface: nicName,
        method4: "auto",
        method6: "auto",
        ignoreAutoDns: false,
        status: "up",
        autoconnect: true
      }
    ]
  },
  scripts: {
    pre: [
      {
        name: "pre_install_script",
        body: |||
          #!/bin/bash
          echo "Execute pre-install script" >/dev/ttyS0
          echo "{{ autoinstall_start_msg }}" >/dev/ttyS0

          echo "Installer environment variables:" >/dev/ttyS0
          env | sort >/dev/ttyS0

          echo "Installer filesystems:" >/dev/ttyS0
          mount >/dev/ttyS0

          ip_addr=$(ip -br -f inet addr show | grep -v 127.0.0.1 | awk '{print $3}')
          echo "{{ autoinstall_ipv4_msg }}$ip_addr" >/dev/ttyS0

          echo "Boot command:"
          cat /proc/cmdline
        |||
      }
    ],
     post: [
      {
        name: 'post_install_script',
        body: |||
          #!/bin/bash
          echo "Execute post-install script" >/dev/ttyS0
          echo "Config SSHd to permit root login" >/dev/ttyS0
          echo "PermitRootLogin yes" >/etc/ssh/sshd_config.d/10_root_login.conf
          echo "{{ autoinstall_complete_msg }}" >/dev/ttyS0
        |||
      }
    ]
  }
}
