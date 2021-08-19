# BerkeleyLibrary::Logging

[![Build Status](https://travis-ci.com/BerkeleyLibrary/logging.svg?branch=main)](https://travis-ci.com/github/BerkeleyLibrary/logging/)
[![Gem Version](https://img.shields.io/gem/v/berkeley_library-logging.svg)](https://github.com/BerkeleyLibrary/logging/releases)

Opinionated logging for UCB Library IT Rails applications.

## Usage

### With Rails

`BerkeleyLibrary::Logging` is implemented as a Railtie, so adding it to your Gemfile should
cause it to be loaded automatically.

### With or without Rails

You can load `BerkeleyLibrary::Logging` explicitly with `require`:

```ruby
require 'berkeley_library/logging'

logger = BerkeleyLibrary::Logging::Logger.default_logger
```

In a Rails environment, this will return the Rails logger (already configured by the
Railtie); in a non-Rails environment, it will return a default, human-readable STDOUT
logger.

Alternatively, you can create a logger directly:

```ruby
require 'berkeley_library/logging'

logger = BerkeleyLibrary::Logging::Loggers.new_readable_logger('/tmp/mylog.log')
logger.warn('oops')
puts File.read('/tmp/mylog.log')

# => # Logfile created on 2021-02-03 16:47:06 -0800 by logger.rb/v1.4.2
     [2021-02-03T16:47:10.506-08:00] WARN: oops

logger = BerkeleyLibrary::Logging::Loggers.new_json_logger('/tmp/mylog.json')
logger.warn('oops')
puts File.read('/tmp/mylog.log')

# => # Logfile created on 2021-02-03 16:49:30 -0800 by logger.rb/v1.4.2
     {"name":"irb","hostname":"test.example.org","pid":7080,"level":40,"time":"2021-02-03T16:49:34.842-08:00","v":0,"severity":"WARN","msg":"oops"}
```
