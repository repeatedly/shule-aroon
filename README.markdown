# About

The Discovery Service solves the IdP discovery problem on SAML.

Shule Aroon is the Ruby based implementation.

# Feature

* Support Discovery Service Protocol
* Auto redirection to previous selected IdP
* Transfer the user to Password change site

# Require

* [Ruby](http://www.ruby-lang.org/)
* [Ramaze](http://ramaze.net/)
  * locale (for localize)

# Run

  $ ramaze start -s thin

If you know other options, check help.

  $ ramaze --help

# Link

## SAML

* [OASIS Security Services (SAML) TC](http://www.oasis-open.org/committees/tc_home.php?wg_abbrev=security)

  OASIS Security Services Technical Committee

* [Shibboleth](http://shibboleth.internet2.edu/)

  Shibboleth official site

* [Discovery Service specification](http://docs.oasis-open.org/security/saml/Post2.0/sstc-saml-idp-discovery.html)

  Identity Provider Discovery Service Protocol and Profile

## Other implementation

* [Discovery Service](https://spaces.internet2.edu/display/SHIB2/DiscoveryService)

  Java based DS written by Shibboleth Project.

* [SWITCH WAYF](http://www.switch.ch/aai/wayf/)

  PHP based DS written by SWITCHaai.

Shule Aroon UI refers to above projects.

# Copyright

    Copyright (c) 2008-2010 Masahiro Nakagawa

Shule Aroon is released under the Ruby license.
