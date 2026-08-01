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
  config.layout = "application"                # Layout for settings page
end
```

All values shown are defaults and can be omitted.

## Preset Themes

| Name     | Accent  | Surface | Description                    |
|----------|---------|---------|--------------------------------|
| Default  | *(configured)* | *(configured)* | Uses config defaults |
| Ocean    | blue    | slate   | Cool blues with slate undertones |
| Forest   | emerald | stone   | Natural greens with warm stone   |
| Twilight | violet  | zinc    | Deep violet with clean zinc      |
| Coral    | rose    | neutral | Warm rose with neutral balance   |
| Arctic   | cyan    | gray    | Bright cyan with crisp gray      |

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

Run the update generator to get the latest Stimulus controller:

```bash
bin/rails generate keystone_ui:colors:update
```

## License

MIT License. See [MIT-LICENSE](MIT-LICENSE).
