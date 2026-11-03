local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jutsu777/Jutsu-Ui/refs/heads/main/JutsuLib.lua"))()

local Win = Lib:CreateWindow({
	Title = "JutsuLib",
	Subtitle = "Teste funcional",
	Theme = "Ocean",
	Logo = "rbxassetid://89557631183529",
	Name = "JutsuLibTest",
})

local Main = Win:AddTab("Main", "rbxassetid://7733673987")
Main:AddSection("Toggle")
local tg = Main:AddToggle({
	Name = "Meu toggle",
	Default = false,
	Callback = function(v) print("Toggle:", v) end,
})

Main:AddSection("Botão")
local lbl
Main:AddButton({
	Name = "Clique aqui",
	Callback = function()
		lbl:Set("Botão clicado! Toggle está " .. (tg:Get() and "ligado" or "desligado"))
	end,
})
lbl = Main:AddLabel("Esperando clique...")

Main:AddSection("Slider")
Main:AddSlider({
	Name = "Meu slider",
	Min = 0,
	Max = 100,
	Default = 50,
	Callback = function(v) print("Slider:", v) end,
})

Main:AddSection("Dropdown")
local dd = Main:AddDropdown({
	Name = "Meu dropdown",
	Options = { "Opção 1", "Opção 2", "Opção 3" },
	Default = "Opção 1",
	Callback = function(v) lbl:Set("Dropdown: " .. v) end,
})
Main:AddButton({
	Name = "Trocar opções",
	Callback = function() dd:SetOptions({ "A", "B", "C", "D" }) end,
})

local Themes = Win:AddTab("Temas", "rbxassetid://7743875962")
Themes:AddSection("Selecione um tema")
Themes:AddThemes()
