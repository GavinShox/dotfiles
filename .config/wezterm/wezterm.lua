-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 130
config.initial_rows = 35
config.window_padding = {
	left = 15,
	right = 15,
	top = 15,
	bottom = 15,
}
config.max_fps = 240
config.animation_fps = 240
config.color_scheme = 'Catppuccin Mocha'
config.font_size = 12.25
config.bold_brightens_ansi_colors = 'BrightAndBold'
--config.font = wezterm.font('CaskaydiaCove Nerd Font Mono')
config.font = wezterm.font('CaskaydiaCove Nerd Font Mono', { weight = 'Medium' })
config.line_height = 1.0
config.freetype_load_flags = "DEFAULT"
config.window_background_opacity = 0.75
config.kde_window_background_blur = true
config.default_cursor_style = 'SteadyBar'
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = true
config.tab_max_width = 1600
config.hide_tab_bar_if_only_one_tab = true
config.tab_and_split_indices_are_zero_based = false

-- tab bar stuff
local current_theme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
config.window_frame = {
	font = wezterm.font { family = 'CaskaydiaCove Nerd Font', weight = 'Bold' },
	font_size = 12.0,
	-- inactive_titlebar_bg = 'rgba(30, 30, 46, 0.25)',
	-- active_titlebar_bg = 'rgba(30, 30, 46, 0.25)',
	inactive_titlebar_bg = 'none',
	active_titlebar_bg = 'none',
}
config.colors = {
	tab_bar = {
		new_tab = {
			bg_color = '#313244',
			fg_color = '#cdd6f4',
		},
		new_tab_hover = {
			bg_color = '#45475a',
			fg_color = '#cdd6f4',
		},
		inactive_tab = {
			bg_color = '#181825',
			fg_color = '#cdd6f4',
		},
		inactive_tab_hover = {
			bg_color = '#1e1e2e',
			fg_color = '#cdd6f4',
		},
		active_tab = {
			bg_color = '#cba6f7',
			fg_color = '#11111b',
		},
		background = 'rgba(0, 0, 0, 0.25)',
		--background = 'none',
		inactive_tab_edge = '#313244'
	}
}

return config
