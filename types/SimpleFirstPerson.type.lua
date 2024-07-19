---@diagnostic disable: missing-return

-- DO NOT LOAD THIS SCRIPT!

---@class (exact) SimpleFirstPerson
---@field private __index SimpleFirstPerson
---@field private _isSimpleCustomThirdPersonInstalled boolean
---@field private _maxYaw number
---@field private _maxPitch number
---@field private _thread userdata
---@field private _dslCommand userdata
---@field private _CreateThread fun(self: SimpleFirstPerson): nil
---@field private _HandleSprintFOV fun(self: SimpleFirstPerson): nil
---@field private _CalculateOrientation fun(self: SimpleFirstPerson): nil
---@field private _CalculateOnFootOffset fun(self: SimpleFirstPerson): nil
---@field private _CalculateInVehicleOffset fun(self: SimpleFirstPerson): nil
---@field private _CalculateOffset fun(self: SimpleFirstPerson): nil
---@field private _CalculateCamPosAndLook fun(self: SimpleFirstPerson): nil
---@field isEnabled boolean
---@field yaw number
-- ---@field unclampedYaw number
---@field pitch number
---@field offset2d ArrayOfNumbers2D
---@field pos ArrayOfNumbers3D
---@field look ArrayOfNumbers3D
---@field sensitivity number
---@field isSprintFOVEnabled boolean
---@field baseFOV number
---@field currentFOV number
---@field sprintFOVOffset number
---@field new fun(sensitivity: number, options: { enableSprintFOV: boolean, baseFOV: number, sprintFOVOffset: number }): SimpleFirstPerson
---@field IsEnabled fun(self: SimpleFirstPerson): nil
---@field SetEnabled fun(self: SimpleFirstPerson, enable: boolean): nil
---@field GetSensitivity fun(self: SimpleFirstPerson): nil
---@field SetSensitivity fun(self: SimpleFirstPerson, sensitivity: number): nil
---@field GetYaw fun(self: SimpleFirstPerson): nil
---@field GetUnclampedYaw fun(self: SimpleFirstPerson): nil
---@field GetYawSameAsHeading fun(self: SimpleFirstPerson): nil
---@field GetPitch fun(self: SimpleFirstPerson): nil
---@field CalculateAll fun(self: SimpleFirstPerson): nil
---@field ApplyCameraTransform fun(self: SimpleFirstPerson): nil

SIMPLE_FIRST_PERSON = {}

---@return SimpleFirstPerson
function SIMPLE_FIRST_PERSON.GetSingleton() end
