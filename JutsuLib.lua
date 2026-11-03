local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- ═══ CLICK SOUND (criado uma vez, tocado em todo clique de tab) ═══
local ClickSound = Instance.new("Sound")
ClickSound.Name = "JutsuClickSound"
ClickSound.SoundId = "rbxassetid://6895079853"
ClickSound.Volume = 0.4
ClickSound.Parent = SoundService

local function playClick()
    if ClickSound.Parent then
        ClickSound.TimePosition = 0
        pcall(function() ClickSound:Play() end)
    end
end

local Lib = {}

local C = Color3.fromRGB

local UI = {
	tabGap = 7,
	tabHeight = 32,
	rowGap = 6,
	labelHeight = 28,
	buttonHeight = 34,
	toggleHeight = 36,
	sliderHeight = 52,
	dropdownHeight = 36,
	sectionHeight = 22,
	barHeight = 44,
}
Lib.UI = UI

local THEMES = {
	Ocean = {
		bg = C(9, 24, 36), top = C(13, 35, 52), item = C(18, 46, 67), stroke = C(30, 76, 104),
		accent = C(34, 158, 201), onAccent = C(255, 255, 255),
		text = C(224, 242, 250), sub = C(124, 166, 188), knob = C(240, 250, 255),
	},
	Sky = {
		bg = C(236, 245, 255), top = C(218, 234, 252), item = C(250, 252, 255), stroke = C(184, 207, 236),
		accent = C(64, 148, 238), onAccent = C(255, 255, 255),
		text = C(26, 46, 72), sub = C(96, 122, 152), knob = C(255, 255, 255),
	},
	["Full Black"] = {
		bg = C(0, 0, 0), top = C(12, 12, 12), item = C(22, 22, 22), stroke = C(52, 52, 52),
		accent = C(235, 235, 235), onAccent = C(8, 8, 8), dot = C(0, 0, 0),
		text = C(240, 240, 240), sub = C(128, 128, 128), knob = C(255, 255, 255),
	},
	Purple = {
		bg = C(19, 14, 31), top = C(29, 21, 47), item = C(39, 29, 63), stroke = C(78, 58, 124),
		accent = C(147, 102, 255), onAccent = C(255, 255, 255),
		text = C(240, 233, 255), sub = C(163, 148, 194), knob = C(250, 246, 255),
	},
	Pink = {
		bg = C(30, 14, 24), top = C(43, 21, 35), item = C(58, 29, 48), stroke = C(115, 58, 90),
		accent = C(255, 107, 170), onAccent = C(255, 255, 255),
		text = C(255, 236, 245), sub = C(205, 152, 178), knob = C(255, 246, 250),
	},
}
local ORDER = { "Ocean", "Sky", "Full Black", "Purple", "Pink" }
Lib.Themes = THEMES
Lib.ThemeOrder = ORDER

local MONT = "rbxasset://fonts/families/Montserrat.json"
local montOk = pcall(function()
	return game:GetService("TextService"):GetFamilyInfoAsync(MONT)
end)
local function mkFont(weight, fallback)
	if montOk then return Font.new(MONT, weight) end
	return Font.fromEnum(fallback)
end
local FONT_REG = mkFont(Enum.FontWeight.Regular, Enum.Font.Gotham)
local FONT_MED = mkFont(Enum.FontWeight.Medium, Enum.Font.GothamMedium)
local FONT_BOLD = mkFont(Enum.FontWeight.Bold, Enum.Font.GothamBold)

local function new(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props) do i[k] = v end
	i.Parent = parent
	return i
end

local function corner(p, r)
	return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, p)
end

local function tween(o, t, p, style, dir)
	local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), p)
	tw:Play()
	return tw
end

local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local function pressFx(btn)
	local s = new("UIScale", {}, btn)
	local function up() tween(s, 0.28, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end
	btn.InputBegan:Connect(function(i)
		if isPress(i) then tween(s, 0.08, { Scale = 0.96 }) end
	end)
	btn.InputEnded:Connect(function(i)
		if isPress(i) then up() end
	end)
	btn.MouseLeave:Connect(up)
end

local function bounce(s)
	tween(s, 0.1, { Scale = 1.18 })
	task.delay(0.1, function()
		tween(s, 0.3, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
end

local function makeDraggable(handle, target, o, bind)
	o = o or {}
	local dragging, moved, start, startPos = false, false, nil, nil
	handle.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging, moved = true, false
			start, startPos = i.Position, target.Position
			if o.onDown then o.onDown() end
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
					if o.onUp then o.onUp(moved) end
					if not moved and o.onClick then o.onClick() end
				end
			end)
		end
	end)
	bind(UIS.InputChanged, function(i)
		if dragging and isMove(i) then
			local d = i.Position - start
			if d.Magnitude > 6 then moved = true end
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

local function getUiParent()
	local ok, ui = pcall(function()
		return (gethui and gethui()) or game:GetService("CoreGui")
	end)
	if ok and ui then return ui end
	return lp:WaitForChild("PlayerGui")
end

function Lib:CreateWindow(opts)
	if type(opts) ~= "table" then opts = { Title = opts } end
	local title, subtitle = opts.Title or "Window", opts.Subtitle
	if not subtitle then
		local a, b = title:match("^(.-)%s*|%s*(.+)$")
		if a then title, subtitle = a, b end
	end
	local guiName = opts.Name or "JutsuLib"
	local toggleKey = opts.Key
	if toggleKey == nil then toggleKey = Enum.KeyCode.RightShift end

	local env = (getgenv and getgenv()) or _G
	local prev = env["JutsuLib_" .. guiName]
	if type(prev) == "function" then pcall(prev) end
	local old = getUiParent():FindFirstChild(guiName)
	if old then old:Destroy() end

	local conns = {}
	local function bind(signal, fn)
		local c = signal:Connect(fn)
		table.insert(conns, c)
		return c
	end

	local Theme = THEMES[opts.Theme] or THEMES.Ocean
	local currentTheme = THEMES[opts.Theme] and opts.Theme or "Ocean"

	local reg, onTheme = {}, {}
	local selected

	local function resolve(r)
		if type(r) == "function" then return r() end
		return Theme[r]
	end
	local function themed(inst, prop, r)
		inst[prop] = resolve(r)
		table.insert(reg, { inst, prop, r })
	end
	local function applyTheme(name, animate)
		Theme = THEMES[name]
		currentTheme = name
		for _, e in ipairs(reg) do
			if e[1].Parent then
				local v = resolve(e[3])
				if animate then
					tween(e[1], 0.35, { [e[2]] = v })
				else
					e[1][e[2]] = v
				end
			end
		end
		for _, f in ipairs(onTheme) do f() end
	end
	local function border(inst)
		local st = new("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, inst)
		themed(st, "Color", "stroke")
		return st
	end

	local function flash(st)
		st.Color = Theme.accent
		st.Thickness = 2.5
		tween(st, 0.5, { Color = Theme.stroke, Thickness = 1 })
	end

	local gui = new("ScreenGui", {
		Name = guiName, ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
	}, getUiParent())

	local view = cam.ViewportSize
	local size = opts.Size or Vector2.new(480, 300)
	local w = math.min(size.X, view.X - 40)
	local h = math.min(size.Y, view.Y - 60)

	local main = new("CanvasGroup", {
		Size = UDim2.fromOffset(w, h), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), BorderSizePixel = 0,
		GroupTransparency = 1, Visible = false,
	}, gui)
	themed(main, "BackgroundColor3", "bg")
	corner(main, 12)
	border(main)
	local mainScale = new("UIScale", { Scale = 0.6 }, main)

	local BAR = UI.barHeight
	local bar = new("Frame", { Size = UDim2.new(1, 0, 0, BAR), BorderSizePixel = 0 }, main)
	themed(bar, "BackgroundColor3", "top")

	local LOGO = 28
	local logoX = 10
	local logoY = (BAR - LOGO) / 2
	if opts.Logo then
		local logo = new("ImageLabel", {
			Size = UDim2.fromOffset(LOGO, LOGO), Position = UDim2.fromOffset(logoX, logoY),
			BackgroundTransparency = 1, Image = opts.Logo, ScaleType = Enum.ScaleType.Crop,
		}, bar)
		corner(logo, 8)
	else
		local tile = new("Frame", {
			Size = UDim2.fromOffset(LOGO, LOGO), Position = UDim2.fromOffset(logoX, logoY), BorderSizePixel = 0,
		}, bar)
		corner(tile, 8)
		themed(tile, "BackgroundColor3", "accent")
		local letter = new("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
			Text = string.upper(string.sub(title, 1, 1)), FontFace = FONT_BOLD, TextSize = 16,
		}, tile)
		themed(letter, "TextColor3", "onAccent")
	end

	local textX = logoX + LOGO + 8
	local titleLbl = new("TextLabel", {
		Size = UDim2.new(1, -(textX + 34), 0, subtitle and 18 or BAR),
		Position = UDim2.fromOffset(textX, subtitle and 6 or 0),
		BackgroundTransparency = 1, Text = title, TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = FONT_BOLD, TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd,
	}, bar)
	themed(titleLbl, "TextColor3", "text")

	if subtitle then
		local subLbl = new("TextLabel", {
			Size = UDim2.new(1, -(textX + 34), 0, 14), Position = UDim2.fromOffset(textX, 23),
			BackgroundTransparency = 1, Text = subtitle, TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = FONT_MED, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd,
		}, bar)
		themed(subLbl, "TextColor3", "sub")
	end

	local closeBtn = new("TextButton", {
		Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -24, 0, (BAR - 14) / 2),
		BackgroundColor3 = Color3.fromRGB(200, 60, 70), Text = "",
		AutoButtonColor = false, BorderSizePixel = 0,
	}, bar)

	corner(closeBtn, 100)
	pressFx(closeBtn)
	makeDraggable(bar, main, nil, bind)

	local grip = new("TextButton", {
		Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -2, 1, -2), BackgroundTransparency = 1,
		Text = "◢", FontFace = FONT_BOLD, TextSize = 14,
		AutoButtonColor = false, ZIndex = 5,
	}, main)
	themed(grip, "TextColor3", "sub")

	local MIN_W, MIN_H = 300, 200
	local resizing, rStart, rSize, rPos = false, nil, nil, nil
	grip.InputBegan:Connect(function(i)
		if isPress(i) then
			resizing = true
			rStart, rSize, rPos = i.Position, main.Size, main.Position
			tween(grip, 0.12, { TextColor3 = Theme.accent, TextSize = 18 })
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					resizing = false
					tween(grip, 0.2, { TextColor3 = Theme.sub, TextSize = 14 })
				end
			end)
		end
	end)
	bind(UIS.InputChanged, function(i)
		if resizing and isMove(i) then
			local d = (i.Position - rStart) / mainScale.Scale
			local vs = cam.ViewportSize
			local nw = math.clamp(rSize.X.Offset + d.X, MIN_W, vs.X - 20)
			local nh = math.clamp(rSize.Y.Offset + d.Y, MIN_H, vs.Y - 20)
			main.Size = UDim2.fromOffset(nw, nh)
			main.Position = UDim2.new(
				rPos.X.Scale, rPos.X.Offset + (nw - rSize.X.Offset) / 2,
				rPos.Y.Scale, rPos.Y.Offset + (nh - rSize.Y.Offset) / 2
			)
		end
	end)

	local tabList = new("ScrollingFrame", {
		Size = UDim2.new(0, 104, 1, -(BAR + 10)), Position = UDim2.fromOffset(6, BAR + 6), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
	}, main)
	new("UIListLayout", { Padding = UDim.new(0, UI.tabGap), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)
	new("UIPadding", {
		PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3),
		PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3),
	}, tabList)

	local content = new("Frame", {
		Size = UDim2.new(1, -124, 1, -(BAR + 12)), Position = UDim2.fromOffset(116, BAR + 6),
		BackgroundTransparency = 1, ClipsDescendants = true,
	}, main)

	local float = new("ImageButton", {
		Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0, 14, 0.5, -23),
		Image = opts.Logo or "", ScaleType = Enum.ScaleType.Crop,
		AutoButtonColor = false, BorderSizePixel = 0, Visible = opts.FloatButton ~= false,
	}, gui)
	themed(float, "BackgroundColor3", "accent")
	corner(float, 8)
	local floatStroke = new("UIStroke", { Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, float)
	themed(floatStroke, "Color", "stroke")
	local floatScale = new("UIScale", {}, float)
	if not opts.Logo then
		local letter = new("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
			Text = string.upper(string.sub(title, 1, 1)), FontFace = FONT_BOLD, TextSize = 20,
		}, float)
		themed(letter, "TextColor3", "onAccent")
	end

	local Window = {}
	local tabs = {}
	local isOpen = false
	local token = 0

	function Window:Toggle(state)
		if state == nil then state = not isOpen end
		if state == isOpen then return end
		isOpen = state
		token += 1
		local my = token
		if state then
			main.Visible = true
			tween(mainScale, 0.34, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			tween(main, 0.22, { GroupTransparency = 0 })
		else
			tween(mainScale, 0.22, { Scale = 0.6 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			tween(main, 0.2, { GroupTransparency = 1 })
			task.delay(0.24, function()
				if token == my then main.Visible = false end
			end)
		end
	end

	local function toggleWin() Window:Toggle() end

	makeDraggable(float, float, {
		onDown = function() tween(floatScale, 0.08, { Scale = 0.88 }) end,
		onUp = function(moved)
			if moved then
				tween(floatScale, 0.15, { Scale = 1 })
			else
				bounce(floatScale)
			end
		end,
		onClick = toggleWin,
	}, bind)
	closeBtn.MouseButton1Click:Connect(function() Window:Toggle(false) end)

	bind(UIS.InputBegan, function(i, gp)
		if not gp and toggleKey and i.KeyCode == toggleKey then toggleWin() end
	end)

	function Window:Destroy()
		for _, c in ipairs(conns) do c:Disconnect() end
		gui:Destroy()
	end
	function Window:SetTheme(name)
		if THEMES[name] then applyTheme(name, true) end
	end
	function Window:GetTheme() return currentTheme end
	env["JutsuLib_" .. guiName] = function() Window:Destroy() end

	local function select(t, silent)
		selected = t
		for _, o in ipairs(tabs) do
			local on = o == t
			o.page.Visible = on
			tween(o.btn, 0.22, { BackgroundColor3 = resolve(o.bgRole) })
			tween(o.lbl, 0.22, { TextColor3 = resolve(o.txtRole) })
			if o.ico then tween(o.ico, 0.22, { [o.iconProp] = resolve(o.icoRole) }) end
			tween(o.edge, 0.22, { Transparency = on and 0 or 1 })
		end
		if not silent then
			t.page.Position = UDim2.fromOffset(0, 14)
			tween(t.page, 0.3, { Position = UDim2.new() }, Enum.EasingStyle.Quint)
			t.glow.Transparency = 0.1
			tween(t.glow, 0.6, { Transparency = 1 })
		end
	end

	function Window:AddTab(name, icon)
		local t = {}
		t.bgRole = function() return selected == t and Theme.item or Theme.top end
		t.txtRole = function() return selected == t and Theme.text or Theme.sub end
		t.icoRole = function() return selected == t and Theme.accent or Theme.sub end

		local btn = new("TextButton", {
			Size = UDim2.new(1, 0, 0, UI.tabHeight), Text = "", AutoButtonColor = false,
			BorderSizePixel = 0, LayoutOrder = #tabs + 1,
		}, tabList)
		corner(btn, 12)
		themed(btn, "BackgroundColor3", t.bgRole)
		pressFx(btn)

		local ico
		if icon then
			if icon:find("rbxasset") then
				ico = new("ImageLabel", {
					Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 10, 0.5, -8),
					BackgroundTransparency = 1, Image = icon,
				}, btn)
				t.iconProp = "ImageColor3"
			else
				ico = new("TextLabel", {
					Size = UDim2.fromOffset(20, 32), Position = UDim2.fromOffset(8, 0),
					BackgroundTransparency = 1, Text = icon, FontFace = FONT_BOLD, TextSize = 15,
				}, btn)
				t.iconProp = "TextColor3"
			end
			themed(ico, t.iconProp, t.icoRole)
		end

		local lx = ico and 32 or 0
		local lbl = new("TextLabel", {
			Size = UDim2.new(1, -lx, 1, 0), Position = UDim2.fromOffset(lx, 0),
			BackgroundTransparency = 1, Text = name,
			TextXAlignment = ico and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
			FontFace = FONT_MED, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
		}, btn)
		themed(lbl, "TextColor3", t.txtRole)

		local edge = new("UIStroke", {
			Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}, btn)
		themed(edge, "Color", "accent")

		local glow = new("UIStroke", {
			Thickness = 3, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}, btn)
		themed(glow, "Color", "accent")

		local page = new("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
			ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
		}, content)
		themed(page, "ScrollBarImageColor3", "accent")
		new("UIListLayout", { Padding = UDim.new(0, UI.rowGap), SortOrder = Enum.SortOrder.LayoutOrder }, page)
		new("UIPadding", { PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 4), PaddingTop = UDim.new(0, 2) }, page)

		t.btn, t.lbl, t.ico, t.edge, t.page, t.glow = btn, lbl, ico, edge, page, glow
		table.insert(tabs, t)
		btn.MouseButton1Click:Connect(function()
			playClick()
			if selected ~= t then select(t) end
		end)
		if #tabs == 1 then select(t, true) end

		local Tab = {}
		local nextOrder = 0

		local function setOrder(obj)
			nextOrder += 1
			obj.LayoutOrder = nextOrder
			return obj
		end

		local function row(height, clickable)
			local r = new(clickable and "TextButton" or "Frame", {
				Size = UDim2.new(1, 0, 0, height), BorderSizePixel = 0,
			}, page)
			setOrder(r)
			if clickable then
				r.Text = ""
				r.AutoButtonColor = false
			end
			corner(r, 10)
			themed(r, "BackgroundColor3", "item")
			return r, border(r)
		end

		local function rowLabel(parent, text, size)
			local l = new("TextLabel", {
				Size = size or UDim2.new(1, -70, 0, 20), Position = UDim2.fromOffset(10, 0),
				BackgroundTransparency = 1, Text = text, TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = FONT_REG, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
			}, parent)
			themed(l, "TextColor3", "text")
			return l
		end

		function Tab:AddSection(text)
			local l = new("TextLabel", {
				Size = UDim2.new(1, 0, 0, UI.sectionHeight), BackgroundTransparency = 1, Text = string.upper(text),
				TextXAlignment = Enum.TextXAlignment.Left, FontFace = FONT_BOLD, TextSize = 11,
			}, page)
			setOrder(l)
			new("UIPadding", { PaddingLeft = UDim.new(0, 4) }, l)
			themed(l, "TextColor3", "accent")
		end

		function Tab:AddLabel(text)
			local r = row(UI.labelHeight)
			r.AutomaticSize = Enum.AutomaticSize.Y
			new("UIPadding", { PaddingBottom = UDim.new(0, 6) }, r)
			local l = rowLabel(r, text, UDim2.new(1, -20, 0, 0))
			l.Position = UDim2.fromOffset(10, 6)
			l.AutomaticSize = Enum.AutomaticSize.Y
			l.TextWrapped = true
			l.TextTruncate = Enum.TextTruncate.None
			l.TextYAlignment = Enum.TextYAlignment.Top
			themed(l, "TextColor3", "sub")
			return { Set = function(_, s) l.Text = s end }
		end

		function Tab:AddButton(o)
			local b = new("TextButton", {
				Size = UDim2.new(1, 0, 0, UI.buttonHeight), Text = o.Name, FontFace = FONT_MED,
				TextSize = 13, AutoButtonColor = false, BorderSizePixel = 0,
			}, page)
			setOrder(b)

			corner(b, 10)
			themed(b, "BackgroundColor3", "item")
			themed(b, "TextColor3", "text")
			local st = border(b)
			pressFx(b)
			b.MouseButton1Click:Connect(function()
				tween(b, 0.08, { BackgroundColor3 = Theme.accent, TextColor3 = Theme.onAccent })
				task.delay(0.14, function()
					tween(b, 0.3, { BackgroundColor3 = Theme.item, TextColor3 = Theme.text })
				end)
				flash(st)
				if o.Callback then task.spawn(o.Callback) end
			end)
			return { SetText = function(_, t) b.Text = t end }
		end

		function Tab:AddToggle(o)
			local state = o.Default or false
			local r, st = row(UI.toggleHeight, true)
			pressFx(r)
			rowLabel(r, o.Name, UDim2.new(1, -70, 1, 0))

			local function pos(v) return v and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2) end

			local sw = new("Frame", {
				Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -50, 0.5, -10), BorderSizePixel = 0,
			}, r)
			corner(sw, 10)
			themed(sw, "BackgroundColor3", function() return state and Theme.accent or Theme.stroke end)
			local knob = new("Frame", {
				Size = UDim2.fromOffset(16, 16), Position = pos(state), BorderSizePixel = 0,
			}, sw)
			corner(knob, 8)
			themed(knob, "BackgroundColor3", "knob")

			local function set(v)
				state = v
				tween(sw, 0.22, { BackgroundColor3 = v and Theme.accent or Theme.stroke })
				tween(knob, 0.3, { Position = pos(v) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				flash(st)
				if o.Callback then task.spawn(o.Callback, v) end
			end
			r.MouseButton1Click:Connect(function() set(not state) end)
			if o.Callback then task.spawn(o.Callback, state) end
			return { Set = function(_, v) set(v) end, Get = function() return state end }
		end

		function Tab:AddSlider(o)
			local min, max = o.Min, o.Max
			local val = math.clamp(o.Default or min, min, max)
			local function alpha(v) return (v - min) / (max - min) end

			local r = row(UI.sliderHeight)
			rowLabel(r, o.Name, UDim2.new(1, -80, 0, 26))
			local valLbl = new("TextLabel", {
				Size = UDim2.fromOffset(60, 26), Position = UDim2.new(1, -70, 0, 0),
				BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right,
				FontFace = FONT_BOLD, TextSize = 13, Text = tostring(val),
			}, r)
			themed(valLbl, "TextColor3", "accent")

			local hit = new("TextButton", {
				Size = UDim2.new(1, -24, 0, 26), Position = UDim2.fromOffset(12, 24),
				BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
			}, r)
			local track = new("Frame", {
				Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0.5, -3), BorderSizePixel = 0,
			}, hit)
			corner(track, 3)
			themed(track, "BackgroundColor3", "stroke")
			local fill = new("Frame", { Size = UDim2.new(alpha(val), 0, 1, 0), BorderSizePixel = 0 }, track)
			corner(fill, 3)
			themed(fill, "BackgroundColor3", "accent")
			local thumb = new("Frame", {
				Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(alpha(val), 0, 0.5, 0), BorderSizePixel = 0, ZIndex = 2,
			}, track)
			new("UICorner", { CornerRadius = UDim.new(1, 0) }, thumb)
			themed(thumb, "BackgroundColor3", "knob")
			local ts = new("UIStroke", { Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, thumb)
			themed(ts, "Color", "accent")

			local function set(v)
				v = math.clamp(math.floor(v + 0.5), min, max)
				val = v
				fill.Size = UDim2.new(alpha(v), 0, 1, 0)
				thumb.Position = UDim2.new(alpha(v), 0, 0.5, 0)
				valLbl.Text = tostring(v)
				if o.Callback then o.Callback(v) end
			end
			local function fromX(x)
				local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				set(min + (max - min) * a)
			end

			local dragging = false
			hit.InputBegan:Connect(function(i)
				if isPress(i) then
					dragging = true
					page.ScrollingEnabled = false
					tween(thumb, 0.15, { Size = UDim2.fromOffset(20, 20) }, Enum.EasingStyle.Back)
					fromX(i.Position.X)
				end
			end)
			bind(UIS.InputChanged, function(i)
				if dragging and isMove(i) then fromX(i.Position.X) end
			end)
			bind(UIS.InputEnded, function(i)
				if dragging and isPress(i) then
					dragging = false
					page.ScrollingEnabled = true
					tween(thumb, 0.2, { Size = UDim2.fromOffset(14, 14) })
				end
			end)
			if o.Callback then o.Callback(val) end
			return { Set = function(_, v) set(v) end, Get = function() return val end }
		end

		function Tab:AddDropdown(o)
			local opts = o.Options
			local current = o.Default or opts[1] or ""
			local isOpen = false
			local HEAD, ITEM = UI.dropdownHeight, 30

			local r, st = row(HEAD)
			r.ClipsDescendants = true

			local head = new("TextButton", {
				Size = UDim2.new(1, 0, 0, HEAD), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
			}, r)
			rowLabel(head, o.Name, UDim2.new(1, -130, 1, 0))

			local valLbl = new("TextLabel", {
				Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(1, -130, 0, 0),
				BackgroundTransparency = 1, Text = current, TextXAlignment = Enum.TextXAlignment.Right,
				FontFace = FONT_BOLD, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
			}, head)
			themed(valLbl, "TextColor3", "accent")

			local arrow = new("TextLabel", {
				Size = UDim2.fromOffset(20, HEAD), Position = UDim2.new(1, -26, 0, 0),
				BackgroundTransparency = 1, Text = "▼", FontFace = FONT_BOLD, TextSize = 10,
			}, head)
			themed(arrow, "TextColor3", "sub")

			local sep = new("Frame", {
				Size = UDim2.new(1, -20, 0, 1), Position = UDim2.fromOffset(10, HEAD - 1), BorderSizePixel = 0,
			}, r)
			themed(sep, "BackgroundColor3", "stroke")

			local list = new("Frame", {
				Size = UDim2.new(1, 0, 0, #opts * ITEM), Position = UDim2.fromOffset(0, HEAD), BackgroundTransparency = 1,
			}, r)
			new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, list)

			local btns = {}
			local function refresh()
				valLbl.Text = current
				for name, b in pairs(btns) do
					tween(b, 0.2, { TextColor3 = name == current and Theme.accent or Theme.text })
				end
			end

			local function setOpen(v)
				isOpen = v
				tween(r, 0.25, { Size = UDim2.new(1, 0, 0, v and (HEAD + #opts * ITEM + 4) or HEAD) }, Enum.EasingStyle.Quint)
				tween(arrow, 0.25, { Rotation = v and 180 or 0 })
			end
			head.MouseButton1Click:Connect(function() setOpen(not isOpen) end)

			local function choose(name, silent)
				current = name
				refresh()
				if not silent then
					flash(st)
					if o.Callback then task.spawn(o.Callback, name) end
				end
			end

			local function rebuild()
				for _, b in pairs(btns) do b:Destroy() end
				btns = {}
				list.Size = UDim2.new(1, 0, 0, #opts * ITEM)
				for i, name in ipairs(opts) do
					local b = new("TextButton", {
						Size = UDim2.new(1, 0, 0, ITEM), LayoutOrder = i, BackgroundTransparency = 1,
						Text = name, FontFace = FONT_MED, TextSize = 13, AutoButtonColor = false,
					}, list)
					themed(b, "TextColor3", function() return name == current and Theme.accent or Theme.text end)
					btns[name] = b
					b.MouseButton1Click:Connect(function()
						setOpen(false)
						if name ~= current then choose(name) end
					end)
				end
				refresh()
				if isOpen then setOpen(true) end
			end
			rebuild()

			return {
				Set = function(_, name) choose(name, true) end,
				Get = function() return current end,
				SetOptions = function(_, newOpts)
					opts = newOpts
					if not table.find(opts, current) then current = opts[1] or "" end
					rebuild()
				end,
			}
		end

		function Tab:AddThemes()
			for _, name in ipairs(ORDER) do
				local th = THEMES[name]
				local r, st = row(38, true)
				pressFx(r)

				local dot = new("Frame", {
					Size = UDim2.fromOffset(22, 22), Position = UDim2.new(0, 10, 0.5, -11),
					BackgroundColor3 = th.dot or th.accent, BorderSizePixel = 0,
				}, r)
				new("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)

				local lbl = new("TextLabel", {
					Size = UDim2.new(1, -90, 1, 0), Position = UDim2.fromOffset(42, 0),
					BackgroundTransparency = 1, Text = name, TextXAlignment = Enum.TextXAlignment.Left,
					FontFace = FONT_MED, TextSize = 13,
				}, r)
				themed(lbl, "TextColor3", "text")

				local check = new("TextLabel", {
					Size = UDim2.fromOffset(30, 38), Position = UDim2.new(1, -38, 0, 0),
					BackgroundTransparency = 1, Text = "✓", FontFace = FONT_BOLD, TextSize = 16,
					TextTransparency = (currentTheme == name) and 0 or 1,
				}, r)
				themed(check, "TextColor3", "accent")

				table.insert(onTheme, function()
					tween(check, 0.25, { TextTransparency = (currentTheme == name) and 0 or 1 })
				end)

				r.MouseButton1Click:Connect(function()
					if currentTheme ~= name then
						applyTheme(name, true)
						flash(st)
					end
				end)
			end
		end

		return Tab
	end

	task.defer(function() Window:Toggle(true) end)
	return Window
end

function Lib:AddTheme(name, colors)
	local theme = {}
	for k, v in pairs(THEMES.Ocean) do theme[k] = colors[k] or v end
	theme.dot = colors.dot
	THEMES[name] = theme
	if not table.find(ORDER, name) then table.insert(ORDER, name) end
end

return Lib
