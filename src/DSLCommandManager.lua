-- Don't run the script if the global variable is already defined.
if _G.DSLCommandManager then
	return
end

-- -------------------------------------------------------------------------- --
--                              Helper Functions                              --
-- -------------------------------------------------------------------------- --

---@param tbl string[]
---@param separator string
---@return string
local function JoinTableToString(tbl, separator)
	separator = separator or ""
	local result = tbl[1]

	for i = 2, table.getn(tbl) do
		result = result .. separator .. tbl[i]
	end

	return result
end

-- -------------------------------------------------------------------------- --
--                                    Types                                   --
-- -------------------------------------------------------------------------- --

---@alias DSLCommandManager_CommandTableCheck { type: "number"|"option"|"text", valueOptions: { options: string[], caseSensitive: boolean, textFormat: "upper"|"lower" } }
---@alias DSLCommandManager_ArgTableValidation { commands: DSLCommandManager_CommandTableCheck[], onError?: fun(), onSuccess?: fun()}

---@alias DSLCommandManager_Options { rawArgument?: boolean, helpText?: string }

---@alias DSLCommandManager_CommandCallback fun(...: string): nil

---@alias DSLCommandManager_Command { callback: DSLCommandManager_CommandCallback, rawArgument?: boolean, helpText?: string }

-- -------------------------------------------------------------------------- --
--                                 Attributes                                 --
-- -------------------------------------------------------------------------- --

-- Private fields. Does not exposed when using `pairs()`.

---@class DSLCommandManager
---@field private _commands DSLCommandManager_Command[]
---@field IsAlreadyExist fun(commandName: string): boolean
---@field Register fun(commandName: string, callback, options: DSLCommandManager_Options): boolean
---@field Unregister fun(commandName: string): nil
---@field Run fun(commandName?: string, ...: string): boolean
---@field GetAllCommands fun(): string[]
local privateFields = {
	_commands = {},
}
privateFields.__index = privateFields

-- Define/declare global variable

---@class DSLCommandManager
_G.DSLCommandManager = setmetatable({}, privateFields)

-- -------------------------------------------------------------------------- --
--                                   Methods                                  --
-- -------------------------------------------------------------------------- --

-- For shortening purpose.
local cm = DSLCommandManager

-- Static

---@param commandName string
---@return boolean
function DSLCommandManager.IsAlreadyExist(commandName)
	return DoesCommandExist(commandName) or cm._commands[commandName] ~= nil
end

---@param commandName string
---@param callback fun(...: string): nil
---@param options? DSLCommandManager_Options
---@return boolean success
function DSLCommandManager.Register(commandName, callback, options)
	if cm.IsAlreadyExist(commandName) then
		PrintError(
			string.format('Command "%s" is already registered.', commandName)
		)
		return false
	end

	options = options or { rawArgument = nil, helpText = nil }
	local success =
		SetCommand(commandName, callback, options.rawArgument, options.helpText)

	if success then
		cm._commands[commandName] = {
			callback = callback,
			rawArgument = options.rawArgument,
			helpText = options.helpText,
		}
	end
	return success
end

---@param commandName string
function DSLCommandManager.Unregister(commandName)
	if cm.IsAlreadyExist(commandName) then
		ClearCommand(commandName)
		cm._commands[commandName] = nil
	else
		PrintError(string.format('Command "%s" not found.', commandName))
	end
end

---@param commandName? string
---@param ... string
---@return boolean ran
function DSLCommandManager.Run(commandName, ...)
	commandName = commandName or ""
	return RunCommand(commandName .. " " .. JoinTableToString(arg, " "))
end

---@return string[]
function DSLCommandManager.GetAllCommands()
	local commandList = {}
	for commandName, _ in pairs(cm._commands) do
		table.insert(commandList, commandName)
	end
	return commandList
end

-- Unused

--[[ ---@param commandName string
---@param callback fun(...: string): nil
---@param options? DSLCommandManager_Options
---@return boolean success
function DSLCommandManager.RegisterIfNotExist(commandName, callback, options)
	if cm.IsAlreadyExist(commandName) then
		return false
	end
	cm.Register(commandName, callback, options)
end ]]

-- -------------------------------------------------------------------------- --
--                                 Constructor                                --
-- -------------------------------------------------------------------------- --

--[[ ---@param commandName string
---@param callback? fun(...: string): nil
---@param options? DSLCommandManager_Options
---@return DSLCommandManager
function DSLCommandManager.new(commandName, callback, options)
	local instance = setmetatable({}, DSLCommandManager)

	instance.commandName = commandName

	if callback then
		instance:Register(callback, options)
	end

	return instance
end ]]

-- -------------------------------------------------------------------------- --
--                                   Methods                                  --
-- -------------------------------------------------------------------------- --

-- Static

--[[ ---@param tbl DSLCommandManager_ArgTableValidation
---@param ... string
---@return boolean ran
function DSLCommandManager.RunWithCheck(tbl, ...)
	local function OnError(argtbl)
		return type(argtbl) == "function" and argtbl() or nil
	end

	local isAllValid = true

	for commandIndex, argTable in ipairs(tbl.commands) do
		local argProvided = arg[commandIndex]
		local commandIndexStr = tostring(commandIndex)

		if not argProvided then
			PrintError(commandIndexStr .. ". Invalid arg type: " .. type(argProvided))
			OnError(tbl.onError)
			return false
		elseif type(argProvided) == "number" then
			PrintError(commandIndexStr .. ". Arg type cannot be type of number.")
			OnError(tbl.onError)
			return false
		end

		if argTable.type == "number" then
			if not tonumber(argProvided) then
				PrintError(tostring("Invalid number: ") .. tostring(argProvided))
				OnError(tbl.onError)
				return false
			end
		elseif argTable.type == "option" then
			if argTable.valueOptions.caseSensitive then
				local isValid = false

				for _, v in ipairs(argTable.valueOptions.options) do
					if argProvided == v then
						isValid = true
						break
					end
				end

				if not isValid then
					local allowedValue = argTable.valueOptions.options[1]
					for i = 2, table.getn(argTable.valueOptions.options) do
						allowedValue = allowedValue
							.. "|"
							.. argTable.valueOptions.options[i]
					end
					PrintError(
						"Value is not match with any of the following options: "
							.. allowedValue
					)
					OnError(tbl.onError)
					return false
				end
			end
		end
	end

	local ran = RunCommand("")

	if ran then
		tbl.onSuccess()
	end

	return ran
end ]]
-- -------------------------------------------------------------------------- --
--                                    Test                                    --
-- -------------------------------------------------------------------------- --

--[[ DSLCommandManager.RunWithCheck({
	commands = {
		{
			type = "option",
			valueOptions = {
				options = { "enable", "disable" },
			},
		},
	},
}) ]]
