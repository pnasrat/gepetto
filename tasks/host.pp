Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin" }

# install qemu

package { qemu: 
  ensure => "0.9.1+svn20090104-1"
}

case $operatingsystem {
  debian: {
    notice("qemu from experimental is required for the moment")

    file { "/etc/apt/sources.list.d/debian-experimental.list":
      content => "deb http://ftp.debian.org/debian/ experimental main"
    }

    exec { "apt-get update":
      require => File["/etc/apt/sources.list.d/debian-experimental.list"]
    }

    exec { "apt-get install -t experimental -y --force-yes qemu":
      require => Exec["apt-get update"],
      before => Package[qemu]
    }
  }
}

# compile kqemu module 

package { kqemu-source:
  ensure => "1.4.0~pre1-1",
  require => Package[qemu]
}

exec { "modass-kqemu":
  # modass returns 249 with non-inter ...
  command => 'module-assistant --non-inter a-i kqemu || dpkg -l "kqemu-modules-`uname -r`" | grep ^ii',
  unless => 'dpkg -l "kqemu-modules-`uname -r`" | grep ^ii',
  require => Package[kqemu-source]
}

exec { "add kqemu in /etc/modules":
  command => "echo kqemu >> /etc/modules",
  unless => "grep kqemu /etc/modules",
  require => Exec["modass-kqemu"]
}

exec { "modprobe-kqemu":
  command => "modprobe kqemu",
  unless => "lsmod | grep kqemu",
  require => Exec["modass-kqemu"]
}

file { "/dev/kqemu":
  # default permissions on debian, but not on ubuntu
  mode => 666,
  require => Exec["modprobe-kqemu"]
}

# install uml-utilities for tunctl 

package { uml-utilities: }

exec { "add tun in /etc/modules":
  command => "echo tun >> /etc/modules",
  unless => "grep tun /etc/modules"
}

exec { "modprobe tun":
  unless => "lsmod | grep tun"
}

file { "/dev/net/tun":
  mode => 666
}

# provide a basic qemu-ifup

file { "/etc/qemu-ifup":
  mode => 755,
  content => '#!/bin/sh -x

if [ "$USER" != "root" -o "$1" != "sudo" ]; then
  exec sudo -p "Password for $0:" $0 sudo $1
fi

[ "$1" = "sudo" ] && shift

/sbin/ifconfig $1 172.20.0.1
iptables -t nat -A POSTROUTING -s 172.20.0.1/24 -o eth0 -j MASQUERADE
sysctl -w net.ipv4.ip_forward=1
',
  require => Package[qemu]
}
