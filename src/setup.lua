for _, filename in ipairs({
	"Config",
	"DSLCommandManager",
	"SimpleCustomThirdPerson",
}) do
	LoadScript("src/" .. filename .. ".lua")
end

-- -------------------------------------------------------------------------- --

---@class SIMPLE_CUSTOM_THIRD_PERSON
---@field private _INTERNAL table
local privateFields = {
	_INTERNAL = {
		INITIALIZED = false,

		CONFIG = {
			FILENAME_WITH_EXTENSION = "settings.ini",
			DEFAULT_SETTING = {
				bEnabled = false,
				bEnableThirdPerson = false,

				sKeycode = "T",
				sModifierKey = "LSHIFT",
				sShoulderSwapKey = "V",
				sZoomModifierKey = "G",

				bInvertCameraX = false,
				bInvertCameraY = false,

				fLookSensitivity = 1.5,
				fHeightOffset = 1.25,
				fAngleOffset = 20,
				fLookAtDist = 5,
				fPosDist = 2.5,
				fZoomMult = 2,
				fMaxZoom = 5,

				bEnableSprintFOV = true,
				fSprintFOVOffset = 20,
				fFOV = 90,

				fZoomInterpolationSpeed = 0.1,
				fSprintFOVInterpolationSpeed = 0.1,
				fShoulderSwapInterpolationSpeed = 0.1,

				bEnableBobbing = true,
				bEnableBobFreqSyncWithAnimSpeed = true,
				fBobAmountHorizontal = 0.0625,
				fBobAmountVertical = 0.05,
				fBobFreqHorizontal = 10,
				fBobFreqVertical = 20,
			},
		},

		COMMAND = {
			NAME = "simpletp",
			HELP_TEXT = [[simpletp

Usage:
  - simpletp <toggle> (Enable/disable the mod, where <toggle> must be "enable" or "disable")
  - simpletp set sensitivity <value> (Set the camera look sensitivity, <value> must be numbers)]],
		},

		INSTANCE = {
			---@type Config
			Config = nil,

			---@type SimpleCustomThirdPerson
			SimpleCustomThirdPerson = nil,
		},
	},
}

-- -------------------------------------------------------------------------- --
--                           Private Static Methods                           --
-- -------------------------------------------------------------------------- --

function privateFields._RegisterCommand()
	local command = privateFields._INTERNAL.COMMAND
	local instance = privateFields._INTERNAL.INSTANCE

	---@param value string
	---@param argType string
	---@return boolean
	local function checkIfArgSpecified(value, argType)
		if not value or value == "" then
			PrintError(argType .. " didn't specified.")
			return false
		end

		return true
	end

	---@param value string
	---@return boolean
	local function isFirstArgValid(value)
		if not checkIfArgSpecified(value, "Command action type") then
			return false
		end

		if
			not ({
				["enable"] = true,
				["disable"] = true,
				["set"] = true,
			})[string.lower(value)]
		then
			PrintError('Allowed command action types are "enable"|"disable"|"set".')
			return false
		end

		return true
	end

	---@param value string
	---@return boolean
	local function isSecondArgValid(value)
		if not checkIfArgSpecified(value, "Key setting") then
			return false
		end

		if not ({ ["sensitivity"] = true })[string.lower(value)] then
			PrintError('Key must be "sensitivity".')
			return false
		end

		return true
	end

	---@param value string
	---@return boolean
	local function isThirdArgValid(value)
		if not checkIfArgSpecified(value, "Number didn't specified.") then
			return false
		end

		if not tonumber(value) then
			PrintError("Invalid number.")
			return false
		end

		return true
	end

	if DSLCommandManager.IsAlreadyExist(command.NAME) then
		DSLCommandManager.Unregister(command.NAME)
	end

	DSLCommandManager.Register(command.NAME, function(...)
		local actionType = arg[1]
		local keySetting = arg[2]
		local valueSetting = arg[3]

		if not isFirstArgValid(actionType) then
			return
		end

		actionType = string.lower(actionType)

		-- Toggle ON/OFF
		if actionType == "enable" or actionType == "disable" then
			SIMPLE_CUSTOM_THIRD_PERSON.SetEnabled(actionType == "enable")
			print("Simple Third Person: Mod " .. actionType .. "d.")

		-- Set sensitivity
		else
			if
				not (isSecondArgValid(keySetting) and isThirdArgValid(valueSetting))
			then
				return
			end

			instance.SimpleCustomThirdPerson:SetSensitivity(
				tonumber(valueSetting) --[[@as number]]
			)
			print(
				string.format(
					"Simple Third Person: Sensitivity set to %s.",
					tostring(valueSetting)
				)
			)
		end
	end, {
		rawArgument = false,
		helpText = command.HELP_TEXT,
	})
end

-- -------------------------------------------------------------------------- --

-- Hide all the above key/attribute from `pairs()`.

-- Using `_G` notation to create a global variable that can be accessed across
-- different scripts.

privateFields.__index = privateFields

---@class SIMPLE_CUSTOM_THIRD_PERSON
_G.SIMPLE_CUSTOM_THIRD_PERSON = setmetatable({
	VERSION = "1.0.0",

	DATA = {
		-- The core mod state. If `false`, you cannot switch to third person.
		-- This can be toggled only via console.
		IS_ENABLED = true,
	},
}, privateFields)

-- -------------------------------------------------------------------------- --
--                            Public Methods / API                            --
-- -------------------------------------------------------------------------- --

local internal = SIMPLE_CUSTOM_THIRD_PERSON._INTERNAL
local instance = internal.INSTANCE

function SIMPLE_CUSTOM_THIRD_PERSON.GetSingleton()
	if not instance.SimpleCustomThirdPerson then
		local conf = instance.Config

		instance.SimpleCustomThirdPerson = SimpleCustomThirdPerson.new({
			useInvertedControlX = conf:GetSettingValue("bInvertCameraX") --[[@as boolean]],
			useInvertedControlY = conf:GetSettingValue("bInvertCameraY") --[[@as boolean]],

			sensitivity = conf:GetSettingValue("fLookSensitivity") --[[@as number]],

			yawOffsetDegree = conf:GetSettingValue("fAngleOffset") --[[@as number]],
			heightOffset = conf:GetSettingValue("fHeightOffset") --[[@as number]],
			posDist = conf:GetSettingValue("fPosDist") --[[@as number]],
			lookDist = conf:GetSettingValue("fLookAtDist") --[[@as number]],
			maxZoom = conf:GetSettingValue("fMaxZoom") --[[@as number]],
			zoomMult = conf:GetSettingValue("fZoomMult") --[[@as number]],

			enableSprintFOV = conf:GetSettingValue("bEnableSprintFOV") --[[@as boolean]],
			sprintFOVOffset = conf:GetSettingValue("fSprintFOVOffset") --[[@as number]],
			baseFOV = conf:GetSettingValue("fFOV") --[[@as number]],

			zoomInterpolationSpeed = conf:GetSettingValue("fZoomInterpolationSpeed") --[[@as number]],
			sprintFOVInterpolationSpeed = conf:GetSettingValue(
				"fSprintFOVInterpolationSpeed"
			) --[[@as number]],
			shoulderSwapInterpolationSpeed = conf:GetSettingValue(
				"fShoulderSwapInterpolationSpeed"
			) --[[@as number]],

			enableBobbing = conf:GetSettingValue("bEnableBobbing") --[[@as boolean]],
			enableBobFreqSyncWithAnimSpeed = conf:GetSettingValue(
				"bEnableBobFreqSyncWithAnimSpeed"
			) --[[@as boolean]],
			bobbingAmountHorizontal = conf:GetSettingValue("fBobAmountHorizontal") --[[@as number]],
			bobbingAmountVertical = conf:GetSettingValue("fBobAmountVertical") --[[@as number]],
			bobbingFreqHorizontal = conf:GetSettingValue("fBobFreqHorizontal") --[[@as number]],
			bobbingFreqVertical = conf:GetSettingValue("fBobFreqVertical") --[[@as number]],
		})

		-- Apply settings
		instance.SimpleCustomThirdPerson:SetEnabled(
			conf:GetSettingValue("bEnableThirdPerson") --[[@as boolean]]
		)
	end

	return instance.SimpleCustomThirdPerson
end

function SIMPLE_CUSTOM_THIRD_PERSON.Init()
	if not internal.INITIALIZED then
		-- Create & get instances

		instance.Config = Config.new(
			"src/" .. internal.CONFIG.FILENAME_WITH_EXTENSION,
			internal.CONFIG.DEFAULT_SETTING
		)

		instance.SimpleCustomThirdPerson = SIMPLE_CUSTOM_THIRD_PERSON.GetSingleton()

		SIMPLE_CUSTOM_THIRD_PERSON._RegisterCommand()

		SIMPLE_CUSTOM_THIRD_PERSON.DATA.IS_ENABLED =
			instance.Config:GetSettingValue("bEnabled") --[[@as boolean]]

		-- Delete

		Config = nil --[[@diagnostic disable-line]]
		SimpleCustomThirdPerson = nil --[[@diagnostic disable-line]]

		collectgarbage()

		internal.INITIALIZED = true
	end
end

---@return string
function SIMPLE_CUSTOM_THIRD_PERSON.GetVersion()
	return internal.VERSION
end

function SIMPLE_CUSTOM_THIRD_PERSON.IsInstalled()
	return true
end

---@return boolean
function SIMPLE_CUSTOM_THIRD_PERSON.IsEnabled()
	return SIMPLE_CUSTOM_THIRD_PERSON.DATA.IS_ENABLED
end

---@param enable boolean
function SIMPLE_CUSTOM_THIRD_PERSON.SetEnabled(enable)
	SIMPLE_CUSTOM_THIRD_PERSON.DATA.IS_ENABLED = enable

	-- If the mod is set to disabled..
	if not enable then
		-- ..then disable the Custom Third Person POV as well
		instance.SimpleCustomThirdPerson:SetEnabled(false)
	end
end
