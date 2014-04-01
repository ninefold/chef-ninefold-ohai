# CHANGELOG for ninefold\_ohai

This file is used to list changes made in each version of ninefold\_ohai.

## 1.1.4

* Ignore non-existent virtual routers which are hangovers from
  DHCP leases on the machine that was templated to create this server

## 1.1.3

* Handle 404 error returned from router for metdata missing so that
  attribute gets nil rather than a massive HTML string

## 1.1.2

* Bring version and tag refs into alignment!

## 1.1.1

* Remove explicit cookbook deps to avoid conflicts with ninefold\_app cookbook deps

## 1.1.0

* Refactor attributes to better surface network by router
* Prefer non NinefoldNet router as the source of truth

## 1.0.0

* Improved installation process and public release

## 0.1.0

* Initial release which creates 'ninefold' hash of cloudstack meta-data about the node (virtual server)

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.
