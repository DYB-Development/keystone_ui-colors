# KeystoneUi::Colors

**keystone_ui-colors is retired.** No version follows 0.6.2. Use these two gems instead:

- [keystone_ui-preferences](https://github.com/DYB-Development/keystone_ui-preferences) saves each person's and each account's colours, mode and look.
- [keystone_ui-looks](https://github.com/DYB-Development/keystone_ui-looks) holds the colour palettes, the colour templates and the looks.

The sections from [About 0.6.2](#about-062) onward document 0.6.2, for apps that have not moved yet.

## Moving to keystone_ui-preferences

keystone_ui-preferences depends on keystone_ui-looks, so the app's Gemfile needs only keystone_ui-preferences. Follow these steps in this order. An app that does not have keystone_ui-preferences yet runs `bin/rails generate keystone_ui:preferences:install` at step 5 instead of the update generator.

1. Set keystone_ui-preferences to `~> 0.7` and remove keystone_ui-colors from the Gemfile, then run `bundle install`.
2. Change each name in the table below, and move any settings from a keystone_ui-colors initializer into a keystone_ui-preferences initializer. An initializer or route that still names `KeystoneUi::Colors` stops the app from booting.
3. Register the person's appearance section and the account's appearance section with settings_hub. Register the account's behind the capability the app already uses for its other account sections, since settings_hub refuses a capability the app does not define.
4. Call `super` from any `after_settings_change` the app defines, so saving the appearance section clears the light or dark choice made with keystone_ui's theme toggle.
5. Run its update generator. It copies the migration that copies each saved choice out of `keystone_ui_colors_theme_preferences`, and copies the template picker script when the app does not have it yet.
6. Run `bin/rails db:migrate`.

The app refuses to boot while keystone_ui-colors is loaded, and the generator and the migration both boot the app, so steps 1 to 4 have to come first.

```bash
# set keystone_ui-preferences to ~> 0.7 and remove gem "keystone_ui-colors" from the Gemfile
bundle install
# change each name in the table below, move the initializer settings, register both appearance sections, call super from after_settings_change
bin/rails generate keystone_ui:preferences:update
bin/rails db:migrate
```

```ruby
SettingsHub.section :appearance, area: :user, title: "Appearance",
  renders: "keystone_ui/preferences/settings/appearance",
  runs: "KeystoneUi::Preferences::PickAppearance"

SettingsHub.section :account_appearance, area: :account, title: "Appearance",
  capability: :manage_account, # the capability the app uses for its other account sections
  renders: "keystone_ui/preferences/settings/account_appearance",
  runs: "KeystoneUi::Preferences::PickAccountAppearance"
```

```ruby
def after_settings_change(**options)
  super
  # the app's own work
end
```

keystone_ui-preferences' README says how the copy maps each saved column, and that `keystone_ui_colors_theme_preferences` can be dropped once the copy has run.

### Names that change

| keystone_ui-colors | Replaced by |
|--------------------|-------------|
| `gem "keystone_ui-colors"` | `gem "keystone_ui-preferences"` |
| `KeystoneUi::Colors` | `KeystoneUi::Preferences` |
| `KeystoneUi::Colors::VERSION` | `KeystoneUi::Preferences::VERSION` |
| `KeystoneUi::Colors.configure` | `KeystoneUi::Preferences.configure` |
| `KeystoneUi::Colors.configuration` | `KeystoneUi::Preferences.configuration` |
| `KeystoneUi::Colors.reset_configuration!` | `KeystoneUi::Preferences.reset_configuration!` |
| `KeystoneUi::Colors::Configuration` | `KeystoneUi::Preferences::Configuration` |
| `config.current_owner_method` | `config.current_owner_method` |
| `config.authentication_method` | `config.authentication_method` |
| `config.current_account_method` | `config.current_account_method` |
| `config.default_accent` | `config.default_accent` |
| `config.default_surface` | `config.default_surface` |
| `config.default_background` | `config.default_background` |
| `config.default_text` | `config.default_text` |
| `config.default_mode` | `config.default_mode` |
| `config.account_colors` | `config.account_colors` |
| `config.user_looks` | `config.user_looks` |
| `config.account_looks` | `config.account_looks` |
| `config.app_look_label` | `config.app_look_label` |
| `config.default_template` | No replacement |
| `config.layout` | No replacement |
| `KeystoneUi::Colors::Engine`, mounted at `/keystone_ui_colors` | `KeystoneUi::Preferences::Engine`, mounted at `/keystone_ui_preferences` |
| The settings page at the engine's mount, and its `keystone_ui_colors.settings_path` | No replacement, the appearance sections take its place |
| `KeystoneUi::Colors::ApplicationController` | `KeystoneUi::Preferences::ApplicationController` |
| `KeystoneUi::Colors::SettingsController` | No replacement |
| `KeystoneUi::Colors::CurrentPalette` | `KeystoneUi::Preferences::ComponentPreferences` |
| `before_action :set_current_palette` | No replacement, remove it |
| `keystone_palette_css` | No replacement |
| `keystone_palette_style_tag` | `keystone_palette_style_tag`, from `KeystoneUi::Preferences::ComponentPreferences` |
| `keystone_theme_mode` | `keystone_theme_mode` |
| `keystone_look` | `keystone_look` |
| `keystone_host_colors` | `keystone_host_colors` |
| `KeystoneUi::Colors::PaletteHelper` | No replacement, `KeystoneUi::Preferences::ComponentPreferences` provides `keystone_palette_style_tag` |
| `KeystoneUi::Colors::HostRoutesHelper` | No replacement |
| `KeystoneUi::Colors::ApplicationRecord` | `KeystoneUi::Preferences::ApplicationRecord` |
| `KeystoneUi::Colors::ThemePreference` | `KeystoneUi::Preferences::ComponentPreference`, under the `colours`, `mode` and `look` keys |
| `ThemePreference#apply_template!` | No replacement |
| `keystone_ui_colors_theme_preferences` table | `keystone_ui_preferences_component_preferences` table |
| `KeystoneUi::Colors::ColourChoice` | `KeystoneUi::Preferences::AppearanceChoice` |
| `KeystoneUi::Colors::CustomColours` | No replacement |
| `KeystoneUi::Colors::ForgetTheThemeChoice` | No replacement, `after_settings_change` in `KeystoneUi::Preferences::ComponentPreferences` clears the toggle's choice |
| `KeystoneUi::Colors::PickColours` | `KeystoneUi::Preferences::PickAppearance` |
| `KeystoneUi::Colors::PickAccountColours` | `KeystoneUi::Preferences::PickAccountAppearance` |
| `KeystoneUi::Colors::Kept` | `KeystoneUi::Preferences::Kept` |
| `KeystoneUi::Colors::Refusal` | `KeystoneUi::Preferences::Refusal` |
| `keystone_ui/colors/settings/picker` | `keystone_ui/preferences/settings/appearance` |
| `keystone_ui/colors/settings/account_picker` | `keystone_ui/preferences/settings/account_appearance` |
| `keystone_ui/colors/settings/colours` | `keystone_ui/preferences/settings/colour_choices` |
| `keystone_ui/colors/settings/looks` | `keystone_ui/preferences/settings/look_choices` |
| `keystone_ui/colors/settings/show` | No replacement |
| `KeystoneUi::Colors::Palettes` | `KeystoneUi::Looks::Palettes` |
| `KeystoneUi::Colors::Templates` | `KeystoneUi::Looks::Templates`, which has no `default` template |
| `KeystoneUi::Colors::Templates.default_template` | No replacement |
| `keystone_ui:colors:install` generator | `keystone_ui:preferences:install` generator |
| `keystone_ui:colors:update` generator | `keystone_ui:preferences:update` generator |
| `app/javascript/controllers/keystone_ui/colors/theme_settings_controller.js` | `app/javascript/controllers/keystone_ui/preferences/theme_settings_controller.js` |
| `keystone-ui--colors--theme-settings` Stimulus controller | `keystone-ui--preferences--theme-settings` Stimulus controller |

## About 0.6.2

A Rails engine that adds per-user color palette persistence and preset themes. Companion to [keystone_ui](https://github.com/DYB-Development/keystone_ui).

Users pick from preset themes or custom hex colors. The gem generates CSS custom properties (`--color-accent-*`, `--color-surface-*`) and injects them via a `<style>` tag -- no frontend build step required.

## Requirements

- Ruby >= 3.1
- Rails >= 7.0
- [keystone_ui](https://github.com/DYB-Development/keystone_ui) >= 0.18.0

## Installation

Add to your Gemfile:

```ruby
gem "keystone_ui-colors"
```

Run the install generator:

```bash
bin/rails generate keystone_ui:colors:install
bin/rails db:migrate
```

This creates:
- A migration for `keystone_ui_colors_theme_preferences`
- A Stimulus controller at `app/javascript/controllers/keystone_ui/colors/theme_settings_controller.js`

### Manual setup

**1. Mount the engine** in `config/routes.rb`:

```ruby
mount KeystoneUi::Colors::Engine => "/keystone_ui_colors"
```

**2. Include the concern** in your `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  include KeystoneUi::Colors::CurrentPalette
  before_action :set_current_palette
end
```

**3. Add the style tag** to your layout (`<head>`):

```erb
<%= keystone_palette_style_tag %>
```

This outputs CSS variables:

```css
:root {
  --color-accent-50: #eff6ff;
  --color-accent-100: #dbeafe;
  /* ... through 950 */
  --color-surface-50: #f8fafc;
  /* ... through 950 */
}
```

**4. Register the Stimulus controller** in `app/javascript/controllers/index.js`:

```js
import ThemeSettingsController from "./keystone_ui/colors/theme_settings_controller"
application.register("keystone-ui--colors--theme-settings", ThemeSettingsController)
```

## Configuration

Create `config/initializers/keystone_ui_colors.rb`:

```ruby
KeystoneUi::Colors.configure do |config|
  config.owner_class_name = "User"            # Model that owns preferences
  config.current_owner_method = :current_user  # Controller method for current user
  config.default_template = :ocean             # Fallback theme
  config.default_accent = "blue"               # Fallback accent color
  config.default_surface = "zinc"              # Fallback surface color
  config.default_mode = "light"                # Fallback theme mode: "light", "dark", "system" or "custom"
  config.default_background = "#ffffff"        # Custom mode background when nothing else sets one
  config.default_text = "#18181b"              # Custom mode text colour when nothing else sets one
  config.account_colors = true                 # Let account owners choose their account's colours
  config.current_account_method = nil          # Controller method for the current account, such as :current_account
  config.layout = "application"                # Layout for settings page
end
```

All values shown are defaults and can be omitted.

## Light and Dark Mode

Users choose Light, Dark, System or Custom on the settings page, and the choice is
saved with their palette. keystone_ui renders each page in, strongest first:

1. The choice made with keystone_ui's `ui_theme_toggle` in this browser.
2. The mode the signed-in user saved.
3. `config.default_mode`, for users who saved none and for visitors who are not signed in.

Saving a mode on the settings page clears the toggle's choice in that browser, so the
saved mode takes effect. Pages are marked through keystone_ui's
`keystone_theme_attributes` helper on the layout's `html` tag.

## Custom Mode

A page in Custom mode is drawn from a background colour and a text colour, which
the gem writes as `--color-custom-background` and `--color-custom-text` with the
rest of the palette. keystone_ui-styles draws white in the background and every
gray and zinc shade as a blend of the text into it.

- A preset theme supplies both colours.
- With custom colours, the surface colour the user picks is the background and
  the Text Color picker sets the text.
- Anything not set falls back to `config.default_background` and
  `config.default_text`.

## Account Colours

Colours are chosen at up to three levels, and a page uses the first that applies:

1. The signed-in user's own colours, when the app lets accounts choose and the
   user's account lets its members choose.
2. The account's colours, when the app lets accounts choose.
3. The app's configured defaults, which fall back to keystone_ui's own colours.

An account's colours are a `ThemePreference` owned by the account. Its
`members_choose` column, `true` by default, decides whether members may use their
own colours. Set `config.current_account_method` to the controller method that
returns the current account. With none set, the account level is skipped.

Light, Dark and System stay each user's own choice at every level. Custom is
offered to a user who may choose their own colours, and to anyone whose applying
colours draw a background other than white.

Two partials place the pickers in an app's own settings, each taking `person:`,
`account:` and `submit_url:`:

- `keystone_ui/colors/settings/picker` saves through `KeystoneUi::Colors::PickColours`.
  A user who may not choose colours sees only the mode, and a save from them keeps
  only the mode.
- `keystone_ui/colors/settings/account_picker` saves through
  `KeystoneUi::Colors::PickAccountColours`, and holds the account's colours and
  its Members switch.

Who may set an account's colours is for the app to decide. With settings_hub,
register the account picker in the account area behind a capability:

```ruby
SettingsHub.section :account_appearance, area: :account, title: "Appearance",
  capability: :manage_account,
  renders: "keystone_ui/colors/settings/account_picker",
  runs: "KeystoneUi::Colors::PickAccountColours"
```

## Keeping a Page on the Host's Colours

A controller that declares `keystone_host_colors` renders its pages in the host's
configured accent, surface, custom colours and mode, whatever the signed-in user
saved. It takes the same `only:` and `except:` options as `before_action`.

```ruby
class HomeController < ApplicationController
  keystone_host_colors
end
```

A choice made with keystone_ui's `ui_theme_toggle` in that browser still sets
light or dark on these pages.

Such a page also shows the host's default look, over any look a user or account chose, for the same actions.

## Looks

When the host registers looks with keystone_ui, a signed-in user's preference can
hold one in its `look` column, and every page they see carries it as
`data-look` on the `html` tag. A user with no saved look, and a visitor who is
not signed in, see the host's `default_look`. A saved look the host no longer registers is passed over for the account's look,
or for the host's default when the account's look is not registered either. The
settings page then shows no look selected and still saves. While an account's colours apply, the
page still shows the user's own look.

The colours settings page lists the app's own look first and then every
registered look, with the user's current look chosen, and saves the one they
pick. The app's own look is labelled "Classic" unless the app sets
`app_look_label`, is chosen when no look is saved, and saving it clears the saved
look, so the page goes back to the account's look or the app's default. A name the host does not register is
refused with a message and nothing is stored. With no looks registered the page
shows no look choice.

A host that wants every user on one look sets `user_looks` to false:

```ruby
KeystoneUi::Colors.configure do |config|
  config.user_looks = false
end
```

The settings page then shows no look choice, a save ignores any look sent with
it and keeps the rest, and every page shows the host's default look, even for a
user who saved one earlier. `user_looks` is true by default.

An account admin picks the account's look on the account picker, which lists
every registered look with the account's current one chosen. A member with no
look of their own sees the account's look, and a member who chose one keeps it.
A host that keeps accounts off looks sets `account_looks` to false, and the
account picker then shows no look choice and a saved account look is not
applied. `account_looks` is true by default.

The account picker also has a switch for whether members choose their own
look, on by default and separate from the switch for colours. With it off, every
member sees the account's look whatever they saved, and a member's picker shows
no look choice. Run the update generator to add its column to an app that
installed an earlier version.

## Preset Themes

| Name     | Accent  | Surface | Custom background | Custom text | Description                    |
|----------|---------|---------|-------------------|-------------|--------------------------------|
| Default  | *(configured)* | *(configured)* | *(configured)* | *(configured)* | Uses config defaults |
| Ocean    | blue    | slate   | `#e0f2fe` | `#0c4a6e` | Cool blues with slate undertones |
| Forest   | emerald | stone   | `#ecfdf5` | `#064e3b` | Natural greens with warm stone   |
| Twilight | violet  | zinc    | `#1e1b4b` | `#ede9fe` | Deep violet with clean zinc      |
| Coral    | rose    | neutral | `#fff1f2` | `#4c0519` | Warm rose with neutral balance   |
| Arctic   | cyan    | gray    | `#ecfeff` | `#164e63` | Bright cyan with crisp gray      |

## Available Colors

**Accents:** blue, emerald, cyan, indigo, violet, rose

**Surfaces:** zinc, slate, gray, neutral, stone

Each color includes shades 50 through 950 (Tailwind scale). Users can also pick arbitrary hex colors -- the gem generates a full shade palette automatically.

## Custom Owner Models

The owner association is polymorphic:

```ruby
KeystoneUi::Colors.configure do |config|
  config.owner_class_name = "Account"
  config.current_owner_method = :current_account
end
```

## Using the CSS Variables

```css
.btn-primary {
  background-color: var(--color-accent-500);
  color: white;
}

.page-bg {
  background-color: var(--color-surface-50);
}

.sidebar {
  background-color: var(--color-surface-900);
  color: var(--color-surface-100);
}
```

## Engine Routes

| Method | Path | Action |
|--------|------|--------|
| GET    | /    | Settings page |
| PATCH  | /    | Update preference |
| DELETE | /    | Reset to default |

## API Reference

### `KeystoneUi::Colors::Palettes`

```ruby
KeystoneUi::Colors::Palettes.accent(:blue)             # => { 50 => "#eff6ff", ..., 950 => "#172554" }
KeystoneUi::Colors::Palettes.surface(:zinc)             # => { 50 => "#fafafa", ..., 950 => "#09090b" }
KeystoneUi::Colors::Palettes.generate_shades("#8b5cf6")  # => full shade palette from hex
```

### `KeystoneUi::Colors::Templates`

```ruby
KeystoneUi::Colors::Templates.names      # => [:default, :ocean, :forest, :twilight, :coral, :arctic]
KeystoneUi::Colors::Templates[:ocean]    # => { accent: :blue, surface: :slate, label: "Ocean", ... }
KeystoneUi::Colors::Templates.all        # => Hash of all templates
```

### `KeystoneUi::Colors::ThemePreference`

```ruby
pref = KeystoneUi::Colors::ThemePreference.find_by(owner: current_user)
pref.apply_template!(:forest)
```

Accepts named colors (`"blue"`) or hex values (`"#3b82f6"`) for `accent` and `surface`.

## Updating

Run the update generator to get the latest Stimulus controller and any new migrations (such as the text colour and look columns), then migrate:

```bash
bin/rails generate keystone_ui:colors:update
```

## License

MIT License. See [MIT-LICENSE](MIT-LICENSE).
