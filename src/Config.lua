-- -------------------------------------------------------------------------- --
--                        Utilities / Helper Functions                        --
-- -------------------------------------------------------------------------- --

---Reference:
---[Code](https://help.interfaceware.com/v6/extract-a-filename-from-a-file-path),
---[Regex](https://onecompiler.com/lua/3zzskbj4q)
---@param path string
---@return string
local function GetFilenameWithExtensionFromPath(path)
	local startIndex, _ = string.find(path, "[^%\\/]-$")
	---@diagnostic disable-next-line: param-type-mismatch
	return string.sub(path, startIndex, string.len(path))
end

---@param word string
---@return string
local function CapitalizeFirstLetter(word)
	return string.upper(string.sub(word, 1, 1))
		.. string.sub(word, 2, string.len(word))
end

-- -------------------------------------------------------------------------- --
--                                    Types                                   --
-- -------------------------------------------------------------------------- --

---@alias Config_Value boolean|number|string

-- -------------------------------------------------------------------------- --

---@class Config
---@field private _filePath string
---@field private _filenameWithExtension string
---@field private _configUserdata userdata
---@field private _LoadFile fun(self: Config): nil
---@field private _ReadSettings fun(self: Config): nil
---@field settings { [string]: Config_Value }
---@field keys string[]
---@field new fun(filePath: string, defaultSetting: { [string]: Config_Value }): Config
---@field GetFilePath fun(self: Config): string
---@field GetConfigUserdata fun(self: Config): userdata
---@field GetKeys fun(self: Config): string[]
---@field GetSettingValue fun(self: Config, key: string): Config_Value
---@field SetSettingValue fun(self: Config, key: string, value: Config_Value): nil
Config = {}
Config.__index = Config

-- -------------------------------------------------------------------------- --
--                                 Constructor                                --
-- -------------------------------------------------------------------------- --

---@param filePath string
---@param defaultSetting { [string]: Config_Value }
---@return Config
function Config.new(filePath, defaultSetting)
	local instance = setmetatable({}, Config)

	instance._filePath = filePath
	instance._filenameWithExtension = GetFilenameWithExtensionFromPath(filePath)
	instance._configUserdata = nil

	instance.settings = defaultSetting

	instance.keys = {}
	for key, _ in pairs(defaultSetting) do
		table.insert(instance.keys, key)
	end

	instance:_LoadFile()
	instance:_ReadSettings()

	return instance
end

-- -------------------------------------------------------------------------- --
--                                   Methods                                  --
-- -------------------------------------------------------------------------- --

-- Private

function Config:_LoadFile()
	self._configUserdata = LoadConfigFile(self._filePath)
	if IsConfigMissing(self._configUserdata) then
		error(
			string.format('Missing config file "%s".', self._filenameWithExtension)
		)
	end
end

function Config:_ReadSettings()
	---@param value string
	---@return boolean
	local function isBoolean(value)
		return ({ ["true"] = true, ["false"] = true })[value] or false
	end

	---@param value string
	---@return boolean
	local function isNumber(value)
		return tonumber(value) ~= nil
	end

	---@param valueType type
	---@return "Number"|"String"|"Value"
	local function GetConfig_ValueTypeFuncName(valueType)
		return valueType == "string" and CapitalizeFirstLetter(valueType) or "Value"
	end

	local errorMessage = string.format(
		'Failed to read config file "%s".\n',
		self._filenameWithExtension
	)

	for key, defaultSettingValue in pairs(self.settings) do
		local name = GetConfig_ValueTypeFuncName(type(defaultSettingValue))
		local settingValue = _G["GetConfig" .. name](self._configUserdata, key)

		-- Check the value, is valid or not
		if
			type(defaultSettingValue) == "boolean" and not isBoolean(settingValue)
		then
			error(
				errorMessage
					.. string.format(
						'Invalid value on key "%s"'
							.. ' The value must be either "true" or "false" (without the ")'
							.. ', got "%s" instead.',
						key,
						tostring(settingValue)
					)
			)
		elseif
			type(defaultSettingValue) == "number" and not isNumber(settingValue)
		then
			error(
				errorMessage
					.. string.format('Invalid number value "%s".', tostring(settingValue))
			)
		end

		-- Convert & apply
		local convertedValue = ({
			["boolean"] = settingValue == "true",
			["number"] = tonumber(settingValue),
			["string"] = settingValue,
		})[type(defaultSettingValue)]
		self.settings[key] = convertedValue
	end
end

-- Public

---@return string
function Config:GetFilePath()
	return self._filePath
end

---@return userdata
function Config:GetConfigUserdata()
	return self._configUserdata
end

---@return string[]
function Config:GetKeys()
	return self.keys
end

---@param key string
---@return Config_Value
function Config:GetSettingValue(key)
	return self.settings[key]
end

---@param key string
---@param value Config_Value
function Config:SetSettingValue(key, value)
	self.settings[key] = value
end
