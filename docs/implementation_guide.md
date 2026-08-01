# Implementation Guide

Reference for integrating `keystone_ui-colors` into a Rails app.

## Architecture Overview

```
keystone_ui-colors (Rails Engine)
├── ThemePreference model     -- persists per-user accent/surface choices
├── CurrentPalette concern    -- builds CSS vars, caches in session
├── PaletteHelper             -- renders <style> tag in layout
├── SettingsController        -- CRUD UI for theme selection
├── Palettes module           -- color constants + hex shade generation
└── Templates module          -- preset theme definitions
```

## Database

Single table: `keystone_ui_colors_theme_preferences`

| Column        | Type    | Notes |
|---------------|---------|-------|
| accent        | string  | NOT NULL. Named color (`"blue"`) or hex (`"#3b82f6"`) |
| surface       | string  | NOT NULL. Named color (`"zinc"`) or hex (`"#44403c"`) |
| template_name | string  | Nullable. Template key if a preset was selected |
| owner_type    | string  | NOT NULL. Polymorphic type |
| owner_id      | integer | NOT NULL. Polymorphic ID |
| created_at    | datetime | |
| updated_at    | datetime | |

Unique index on `(owner_type, owner_id)` -- one preference per owner.

## Integration Steps

### 1. Install

```bash
bundle add keystone_ui-colors
bin/rails generate keystone_ui:colors:install
bin/rails db:migrate
```

### 2. Mount engine

```ruby
# config/routes.rb
mount KeystoneUi::Colors::Engine => "/keystone_ui_colors"
```

### 3. Wire up the controller concern

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include KeystoneUi::Colors::CurrentPalette
  before_action :set_current_palette
end
```

This makes `keystone_palette_css` available as a controller method and view helper.

### 4. Inject CSS into layout

```erb
<!-- app/views/layouts/application.html.erb -->
<head>
  <%= keystone_palette_style_tag %>
</head>
```

Output looks like:

```html
<style>:root {
  --color-accent-50: #eff6ff;
  --color-accent-100: #dbeafe;
  --color-accent-200: #bfdbfe;
  --color-accent-300: #93c5fd;
  --color-accent-400: #60a5fa;
  --color-accent-500: #3b82f6;
  --color-accent-600: #2563eb;
  --color-accent-700: #1d4ed8;
  --color-accent-800: #1e40af;
  --color-accent-900: #1e3a8a;
  --color-accent-950: #172554;
  --color-surface-50: #fafafa;
  ...
  --color-surface-950: #09090b;
}</style>
```

### 5. Register the Stimulus controller

```js
// app/javascript/controllers/index.js
import ThemeSettingsController from "./keystone_ui/colors/theme_settings_controller"
application.register("keystone-ui--colors--theme-settings", ThemeSettingsController)
```

### 6. Configure (optional)

```ruby
# config/initializers/keystone_ui_colors.rb
KeystoneUi::Colors.configure do |config|
  config.owner_class_name = "User"            # default
  config.current_owner_method = :current_user  # default
  config.default_template = :ocean             # default
  config.default_accent = "blue"               # default
  config.default_surface = "zinc"              # default
  config.layout = "application"                # default
end
```

### 7. Add association to owner model (optional)

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one :theme_preference, class_name: "KeystoneUi::Colors::ThemePreference", as: :owner
end
```

This is optional but useful for `user.theme_preference` access.

## How the Palette Pipeline Works

1. `set_current_palette` (before_action) runs on every request
2. Checks `session[:keystone_palette]` for cached values
3. If cached and not stale (compared via `updated_at`), builds CSS from cache -- no DB hit
4. If no cache or stale, loads `ThemePreference` from DB
5. Resolves colors: named colors map to predefined hex palettes; hex values get auto-generated shade palettes via `Palettes.generate_shades`
6. Builds CSS string with `:root { --color-accent-50: ...; ... }` format
7. Stores result in `@keystone_palette_css` (exposed as helper)
8. `keystone_palette_style_tag` wraps it in a `<style>` tag

## Color Resolution

Named colors (e.g., `"blue"`) map to hardcoded Tailwind-compatible hex palettes in `Palettes::ACCENTS` and `Palettes::SURFACES`.

Custom hex colors (e.g., `"#e11d48"`) are expanded into a full shade palette using `Palettes.generate_shades(hex)`, which mixes the base color toward white (lighter shades) or black (darker shades) using linear interpolation.

Each palette produces 11 shades: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950.

## Validation Rules

- `accent`: must be one of `blue, emerald, cyan, indigo, violet, rose` OR a valid hex `#RRGGBB`
- `surface`: must be one of `zinc, slate, gray, neutral, stone` OR a valid hex `#RRGGBB`
- `template_name`: must be a known template name or blank (blank = custom colors)

## Settings UI

The engine provides a settings page at its mount point with:
- Template preset cards (radio buttons with color swatches)
- A "Custom" option
- Accent color picker (`ui_color_picker` component from keystone_ui)
- Surface color picker
- Save button

Selecting a template updates the color pickers. Changing a color picker switches to "Custom" mode. The form submits via standard HTTP (no Turbo).

## Linking to Settings

```erb
<a href="<%= keystone_ui_colors.root_path %>">Color Settings</a>
```

## Programmatic Usage

```ruby
# Apply a template
pref = KeystoneUi::Colors::ThemePreference.find_or_create_by(owner: current_user) do |p|
  p.accent = "blue"
  p.surface = "zinc"
end
pref.apply_template!(:twilight)

# Set custom colors
pref.update!(accent: "#e11d48", surface: "#44403c", template_name: "")

# Read palette data
KeystoneUi::Colors::Palettes.accent(:blue)       # => { 50 => "#eff6ff", ... }
KeystoneUi::Colors::Templates[:ocean]             # => { accent: :blue, surface: :slate, ... }
KeystoneUi::Colors::Templates.names               # => [:default, :ocean, :forest, :twilight, :coral, :arctic]
```

## Dependencies

- `keystone_ui` >= 0.4.1 -- provides UI components (`ui_panel`, `ui_section`, `ui_color_picker`, etc.)
- `activerecord` >= 7.0
- `activesupport` >= 7.0
- `@hotwired/stimulus` (JavaScript, for the settings page)
