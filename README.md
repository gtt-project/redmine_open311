# Redmine Open311 Plugin

![CI #develop](https://github.com/gtt-project/redmine_open311/workflows/Test%20with%20Redmine/badge.svg)

This plugin adds [Open311](https://www.open311.org/) Georeport API endpoints to Redmine.

## Requirements

This plugin **requires PostgreSQL/PostGIS** and depends on the [`redmine_gtt` Plugin](https://github.com/gtt-project/redmine_gtt)!!!

- Redmine >= 4.2.0
- PostgreSQL >= 10
- PostGIS >= 2.5

## Installation

To install Redmine Open311 plugin, download or clone this repository in your Redmine installation plugins directory!
```
cd path/to/plugin/directory
git clone https://github.com/gtt-project/redmine_open311.git
```

Then run

```
bundle install
bundle exec rake redmine:plugins:migrate
```

After restarting Redmine, you should be able to see the Redmine Open311 plugin in the Plugins page.

More information on installing (and uninstalling) Redmine plugins can be found here: https://www.redmine.org/wiki/redmine/Plugins

## How to use

[Settings, screenshots, etc.]

## Contributing and Support

The GTT Project appreciates any [contributions](https://github.com/gtt-project/.github/blob/main/CONTRIBUTING.md)! Feel free to contact us for [reporting problems and support](https://github.com/gtt-project/.github/blob/main/CONTRIBUTING.md).

## Version History

- 2.0.0 Support Redmine >= 5.0 and drop Redmine <= 4.1 support
- 1.2.0 Publish on GitHub

See [all releases](https://github.com/gtt-project/redmine_open311/releases) with release notes.

## Authors

  - [Jens Kraemer](https://github.com/jkraemer)
  - [Daniel Kastl](https://github.com/dkastl)
  - [Thibault Mutabazi](https://github.com/eyewritecode)
  - [Ko Nagase](https://github.com/sanak)
  - ... [and others](https://github.com/gtt-project/redmine_open311/graphs/contributors)

## LICENSE

This program is free software. See [LICENSE](LICENSE) for more information.
