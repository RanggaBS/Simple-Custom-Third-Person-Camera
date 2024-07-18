--[[
	A modification script for Bully SE game

	Mod name: Simple Custom Third Person Camera
	Author: RBS ID

	Requirements:
		- Derpy's Script Loader v7 or greater.
]]

-- Header

RequireLoaderVersion(7)

-- -------------------------------------------------------------------------- --
--                                 Entry Point                                --
-- -------------------------------------------------------------------------- --

function main()
	while not SystemIsReady() do
		Wait(0)
	end

	LoadScript("src/setup.lua")
	LoadScript("src/hook.lua")

	local MOD = SIMPLE_CUSTOM_THIRD_PERSON

	MOD.Init()

	local simpleTP = MOD.GetSingleton()
	local conf = MOD._INTERNAL.INSTANCE.Config --[[@diagnostic disable-line]]

	local activationKey = conf:GetSettingValue("sKeycode") --[[@as string]]
	local modifierKey = conf:GetSettingValue("sModifierKey") --[[@as string]]
	local shoulderSwapKey = conf:GetSettingValue("sShoulderSwapKey") --[[@as string]]
	local zoomModifierKey = conf:GetSettingValue("sZoomModifierKey") --[[@as string]]

	local scroll = 0

	while true do
		Wait(0)

		if MOD.IsEnabled() then
			if GetCutsceneRunning() == 0 then
				-- Activation
				if modifierKey ~= "none" then
					if IsKeyPressed(modifierKey) and IsKeyBeingPressed(activationKey) then
						simpleTP:SetEnabled(not simpleTP:IsEnabled())
					end
				else
					if IsKeyBeingPressed(activationKey) then
						simpleTP:SetEnabled(not simpleTP:IsEnabled())
					end
				end

				-- On active
				if simpleTP:IsEnabled() then
					if IsKeyPressed(zoomModifierKey) then
						scroll = GetMouseScroll()
						if scroll < 0 then
							simpleTP:SetZoom("increment")
						elseif scroll > 0 then
							simpleTP:SetZoom("decrement")
						end
					end

					-- Shoulder swap
					if IsKeyBeingPressed(shoulderSwapKey) then
						simpleTP:ToggleShoulderSide()
					end

					simpleTP:CalculateAll()
					simpleTP:ApplyCameraTransform()
				end
			end
		end
	end
end
