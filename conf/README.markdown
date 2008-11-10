# Documentation for Configuration

Ruby DS configuration files are YAML format.

# DS.yaml

Ruby DS basic configuration.
Configuration parameters are below.
Value type is shown in parentheses.

* :adapter(Symbol)

One of Ramaze support application servers.
Don't support WEBrick and Ebb at the moment, 
because don't treat multiple cookie.

* :port(Interger)

Port number using application server.

* :common_domain(String or null)

Set the trust circle domain(must start '.').
If null, server's domain.

* :expires(Integer)

Use the permanent cookie expire.
Default value is 31536000(3600 * 24 * 365).

* :default_language(String)

Use view that user don't support localization.

* :languages(String array)

Support localization languages.
This value has to be locale file name.

* :admin & :mail(String)

Contact infomation.

* :org_name & :org_link(String)

Organaization information that the DS belongs to.
These values use the view footer.

* :log_level(Symbol array)

Support levels are error, warn, info, debug, dev.

# idp.yaml

Configurate a IdP list.
Use tools/m2p.rb to create idp.yaml from metadata.

## Format

    Test Federation: (1)
      https://idp2.ait230.tokushima-u.ac.jp/idp/shibboleth: (2)
        :SSO: https://idp2.ait230.tokushima-u.ac.jp/idp/profile/Shibboleth/SSO
        :name: "IdP name"
        :site: 'https://idp2.ait230.tokushima-u.ac.jp/'

* (1)

Federation name using optgroup element.

* (2)

IdP's entityID.

* :SSO

SSO end point URI for WAYF(Current DS don't use, because don't support WAYF protocol).

* :name(Option)

IdP name using option element.
Represent a OrganizationDisplayName element of IdP entity in metadata.

* :site(Option)

Password change site URI.
This value is used in transfer action.
Represent a OrganizationURL element of IdP entity in metadata.

# sp.yaml

Configurate a SP list using a access check.
Use tools/m2p.rb to create sp.yaml from metadata.

## Format

    https://n.ait.tokushima-u.ac.jp/shibboleth: (1)
      :disc:
      - https://n.ait.tokushima-u.ac.jp/Shibboleth.sso/DS
      - http://n.ait.tokushima-u.ac.jp/Shibboleth.sso/DS

* (1)

SP's entityID.

* :disc

Represent a Location attribute of a idpdisc:DiscoveryResponse in metadata.

# Local

Message mapping for localize view.
File name format is two letter that Accept-Language of request header field.
Refer to tools/localegenerator.rb.
