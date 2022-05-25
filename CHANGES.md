# 0.2.6.2 (2022-05-25)

- Fix `NoMethodError` when calling `BerkeleyLibrary::Logging::Loggers.default_logger` before
  Rails is fully initialized

# 0.2.6.1 (2022-05-11)

- Fix `LoadError` on Rails 6.x.

# 0.2.6 (2022-03-14)

- Add support for Rails 7.

# 0.2.5 (2021-11-04)

- Rails event logs now include a subset of session attributes (`session_id` and `_csrf_token`).
  Set `Rails.config.lograge.verbose_session_logging` to log the full session hash.

# 0.2.4 (2021-11-02)

- Rails event logs now include the following, in addition to the
  headers already logged:

  - `request.origin`
  - `request.base_url`
  - `request.x_csrf_token`
  - `params[:authenticity_token]`

# 0.2.3 (2021-09-02)

- JSON formatter now strips all ANSI 7-bit C1 escapes from strings
  (fixes [#1](https://github.com/BerkeleyLibrary/logging/issues/1) properly)

# 0.2.2 (2021-09-02)

- JSON formatter now strips ANSI color escapes from strings
  (fixes [#1](https://github.com/BerkeleyLibrary/logging/issues/1))

# 0.2.1 (2021-08-19)

- Recursively log error cause

# 0.2.0 (2021-08-18)

- Rename to `BerkeleyLibrary::Logging` in prep for move to GitHub

# 0.1.1 (2021-05-03)

- Adds a global logger accessible by including `UCBLIT::Logging`, or via class methods
  on that module.
  
# 0.1.0 (2021-03-12)

- Initial pseudo-release.
