# KeystoneUi::Colors

A Rails engine that adds per-user color palette persistence and preset themes. Companion to [keystone_ui](https://github.com/DYB-Development/keystone_ui).

Users pick from preset themes or custom hex colors. The gem generates CSS custom properties (`--color-accent-*`, `--color-surface-*`) and injects them via a `<style>` tag -- no frontend build step required.

## Requirements

- Ruby >= 3.1
- Rails >= 7.0
- [keystone_ui](https://github.com/DYB-Development/keystone_ui) >= 0.4.1

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

Run the update generator to get the latest Stimulus controller and any new migrations (such as the text colour column), then migrate:

```bash
bin/rails generate keystone_ui:colors:update
```

## License

MIT License. See [MIT-LICENSE](MIT-LICENSE).
