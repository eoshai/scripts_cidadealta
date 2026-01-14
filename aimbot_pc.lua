--Updated Keybind Logic now just type "RightShift" in the "K" 
--https://raw.githubusercontent.com/randomuser832/Settings/refs/heads/main/Settings for a rundown on the settings

--// SETTINGS (user-editable)
_G.AimbotEnabled = true
_G.TeamCheck = false
_G.AimPart = "Head"
_G.Sensitivity = 1 -- 1 = snap, lower = smooth

-- ESP Settings
_G.ESPEnabled = true
_G.ESPColorName = "green"
_G.ESPFilled = false
_G.ESPThickness = 1
_G.ESPTransparency = 1
_G.ESPRainbow = true

-- FOV Settings
_G.FOVEnabled = true
_G.FOVColorName = "white"
_G.FOVRadius = 60
_G.FOVFilled = false
_G.FOVTransparency = 0.7
_G.FOVThickness = 1
_G.FOVRainbow = true
_G.FOVCircleSides = 64


_G.ScriptEnabled = true
_G.ToggleKey = "RightShift"


loadstring(game:HttpGet("https://raw.githubusercontent.com/randomuser832/Scripts25/refs/heads/main/UniversalAimbotLoadString"))()
