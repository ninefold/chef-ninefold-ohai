name             "ninefold_ohai"
maintainer       "Ninefold Pty Limited"
maintainer_email "warren@ninefold.com"
license          "All rights reserved"
description      "Installs/Configures ninefold ohai plugins"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          "1.1.5"

depends "ohai"
depends "chef-client"
