# JutsuLib

```lua
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jutsu777/Jutsu-Ui/abffbbb9745fcd6dc2314a2f0b9cfecd8342fe21/JutsuLib.lua"))()

local Win = Lib:CreateWindow({
	Title = "My Hub",          -- window title
	Subtitle = "Game",         -- small gray text under the title (optional)
	Theme = "Ocean",           -- Ocean, Sky, Full Black, Purple, Pink
	Key = Enum.KeyCode.RightShift, -- open/close key (false = none)
	Logo = "rbxassetid://123", -- square logo in the title bar + floating button (optional)
	Size = Vector2.new(480, 300),
	Name = "MyHubGui",         -- change per script so two hubs don't replace each other
})

local Tab = Win:AddTab("Main", "icon")   -- icon is optional: text symbol or rbxassetid://
```

## Elements
| Call | Returns |
|---|---|
| `Tab:AddSection("Title")` | |
| `Tab:AddLabel("text")` | `:Set(text)` |
| `Tab:AddButton({ Name, Callback })` | `:SetText(text)` |
| `Tab:AddToggle({ Name, Default, Callback(v) })` | `:Set(v)` `:Get()` |
| `Tab:AddSlider({ Name, Min, Max, Default, Callback(v) })` | `:Set(v)` `:Get()` |
| `Tab:AddDropdown({ Name, Options, Default, Callback(name) })` | `:Set(name)` `:Get()` `:SetOptions(list)` |
| `Tab:AddThemes()` | theme picker |

Toggle and Slider run `Callback` once at creation with the default value. Dropdown does not.

## Window
`Win:Toggle(true/false)` · `Win:Destroy()` · `Win:SetTheme("Pink")` · `Win:GetTheme()`

## Library
`Lib:AddTheme("Name", { bg, top, item, stroke, accent, onAccent, text, sub, knob })` (missing colors use Ocean)

## Spacing and sizes
Change before creating the window:

```lua
Lib.UI.tabGap = 9        -- space between tabs
Lib.UI.tabHeight = 34    -- tab button height
Lib.UI.rowGap = 8        -- space between elements
Lib.UI.buttonHeight = 36
Lib.UI.toggleHeight = 38
Lib.UI.sliderHeight = 54
Lib.UI.dropdownHeight = 38
Lib.UI.sectionHeight = 24
Lib.UI.barHeight = 44    -- title bar height
Lib.UI.labelHeight = 28
```
