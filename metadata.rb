name             "ninefold_ohai"
maintainer       "Ninefold Pty Limited"
maintainer_email "warren@ninefold.com"
license          "All rights reserved"
description      "Installs/Configures ninefold ohai plugins"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.0"

depends "ohai",         "1.1.8"
depends "chef-client",  "3.0.4"
