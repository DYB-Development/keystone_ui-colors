# Changelog

## [Unreleased]

## [0.4.1] - 2026-09-24

### Changed

- Requires keystone_ui 0.15.1 or later, which keeps a custom page's theme across Turbo visits.

### Fixed

- The update generator adds no migration for a column the app's colour preference migrations already create, so an app installed with the mode or text column no longer gets a migration that fails on it.
- A palette cached in a cookie session is served without reading the preference again, where before the cache's keys came back as strings and every page read the database.

## [0.4.0] - 2026-09-24

### Added

- An account can have its own colours, which its members see unless the account lets them choose their own.
- `config.account_colors` lets an app stop accounts, and so their members, from choosing colours.
- `config.current_account_method` names the controller method that returns the current account.
- The update generator adds the members choose column.
- An account picker partial and `PickAccountColours` let an account's owner set the account's colours and whether members choose their own.
- The picker shows a user only the mode when they may not choose colours, and a save from them keeps only the mode.
- The picker offers Custom to a user who may choose colours, or whose applying colours draw a background other than white.

### Fixed

- Picking custom colours forgets a preset theme chosen earlier, so a custom page shows the picked surface and text colours and not that preset's.

## [0.3.1] - 2026-09-24

### Changed

- Requires keystone_ui 0.14.0 or later, which marks a page custom when this gem supplies Custom mode.

## [0.3.0] - 2026-09-24

### Added

- Users can choose Custom as their mode on the settings page, saved with their palette.
- Users can pick a text colour, and each preset theme has a background and a text colour, which the gem writes for Custom mode.
- `config.default_background` and `config.default_text` set the Custom mode colours when nothing else does.
- The update generator adds the text colour column.
- A controller that declares `keystone_host_colors` shows its pages in the host's configured colours and mode, whatever the signed-in user saved.

## [0.2.0] - 2026-09-14

### Added

- Users choose Light, Dark or System on the settings page, saved with their palette.
- `config.default_mode` sets the mode for users who saved none and for visitors who are not signed in, and defaults to `"light"`.
- keystone_ui renders pages in the saved or default mode, unless keystone_ui's toggle has a choice in that browser.

### Upgrading

- Requires keystone_ui 0.10.0 or later.
- Run `rails g keystone_ui:colors:update` and `rails db:migrate` to add the `mode` column to `keystone_ui_colors_theme_preferences`.

### Breaking

Renamed from `keystone_colors` to `keystone_ui-colors`, and the namespace from
`KeystoneColors` to `KeystoneUi::Colors`. The repo now lives at
`DYB-Development/keystone_ui-colors`.

Host apps must update:

| Was | Now |
|---|---|
| `gem "keystone_colors"` | `gem "keystone_ui-colors"` |
| `KeystoneColors::Engine` | `KeystoneUi::Colors::Engine` |
| `KeystoneColors::CurrentPalette` | `KeystoneUi::Colors::CurrentPalette` |
| `KeystoneColors.configure` | `KeystoneUi::Colors.configure` |
| `keystone_colors.settings_path` | `keystone_ui_colors.settings_path` |
| `rails g keystone_colors:install` | `rails g keystone_ui:colors:install` |
| `config/initializers/keystone_colors.rb` | `config/initializers/keystone_ui_colors.rb` |
| `keystone_colors_theme_preferences` | `keystone_ui_colors_theme_preferences` |

The table rename needs a migration in each host app:

```ruby
rename_table :keystone_colors_theme_preferences, :keystone_ui_colors_theme_preferences
rename_index :keystone_ui_colors_theme_preferences,
  "index_keystone_colors_theme_prefs_on_owner",
  "index_keystone_ui_colors_theme_prefs_on_owner"
```

The Stimulus controller moves to
`app/javascript/controllers/keystone_ui/colors/theme_settings_controller.js`
(identifier `keystone-ui--colors--theme-settings`). Re-run
`rails g keystone_ui:colors:update` and delete the old
`controllers/keystone_colors/` directory.

Unchanged: the `keystone_palette_style_tag` helper, `keystone_palette_css`, and
`set_current_palette` keep their names. The cached session key changes to
`:keystone_ui_colors_palette`, which causes a one-time palette rebuild per session.

## [0.1.0] - 2026-05-07

Initial release.

- Per-user theme persistence via polymorphic `ThemePreference` model
- 5 preset themes: Ocean, Forest, Twilight, Coral, Arctic
- Configurable default template, accent, and surface colors
- 6 accent colors (blue, emerald, cyan, indigo, violet, rose) and 5 surface colors (zinc, slate, gray, neutral, stone)
- Full shade scale (50-950) matching Tailwind, with custom hex color support via auto-generated shades
- CSS custom property injection (`--color-accent-*`, `--color-surface-*`) via `<style>` tag helper
- Session-based caching with staleness detection
- Settings UI with preset selector and color pickers (requires keystone_ui)
- Stimulus controller for interactive theme selection
- Install and update generators
- Default palette for unauthenticated visitors
