LoadScript("src/utils.lua")

-- ---------------------------------- Types --------------------------------- --

---@alias SimpleCustomThirdPerson_options { useInvertedControlX: boolean, useInvertedControlY: boolean, sensitivity: number, yawOffsetDegree: number, heightOffset: number, posDist: number, lookDist: number, maxZoom: number, zoomMult: number, enableSprintFOV: boolean, baseFOV: number, sprintFOVOffset: number, zoomInterpolationSpeed: number, sprintFOVInterpolationSpeed: number, shoulderSwapInterpolationSpeed: number, enableBobbing: boolean, enableBobFreqSyncWithAnimSpeed: boolean, bobbingAmountHorizontal: number, bobbingAmountVertical: number, bobbingFreqHorizontal: number, bobbingFreqVertical: number }
---@alias SimpleCustomThirdPerson_ShoulderSide "left"|"right"
---@alias SimpleCustomThirdPerson_ShoulderSideWithCenter SimpleCustomThirdPerson_ShoulderSide|"center"

-- -------------------------------------------------------------------------- --
--                            Attributes & Methods                            --
-- -------------------------------------------------------------------------- --

---@class (exact) SimpleCustomThirdPerson
---@field private __index SimpleCustomThirdPerson
---@field private _isSimpleFirstPersonInstalled boolean
---@field private _isCameraFOVInstalled boolean
---@field private _maxYaw number
---@field private _maxPitch number
---@field private _CheckSimpleFirstPersonInstalled fun(): boolean
---@field private _CheckCameraFOVInstalled fun(): boolean
---@field private _HandleSprintFOV fun(self: SimpleCustomThirdPerson): nil
---@field private _CalculateOrientation fun(self: SimpleCustomThirdPerson): nil
---@field private _CalculateActualYaw fun(self: SimpleCustomThirdPerson): nil
---@field private _CalculateZoom fun(self: SimpleCustomThirdPerson): nil
---@field private _HandleShoulderSwap fun(self: SimpleCustomThirdPerson): nil
---@field private _GetVehicleHeightOffset fun(self: SimpleCustomThirdPerson, vehicleId: integer): number
---@field private _CalculateCamPosAndLook fun(self: SimpleCustomThirdPerson): nil
---@field private _HandleHeadBobbing fun(self: SimpleCustomThirdPerson): nil
---@field isEnabled boolean
---@field yaw number
---@field actualYaw number
---@field pitch number
---@field pos ArrayOfNumbers3D
---@field look ArrayOfNumbers3D
---@field useInvertedControlX boolean
---@field useInvertedControlY boolean
---@field sensitivity number
---@field heightOffset number
---@field yawOffsetDegree number
---@field currentYawOffsetDegree number
---@field posDist number
---@field currentPosDist number
---@field lookDist number
---@field maxZoom number
---@field zoomMult number
---@field isSprintFOVEnabled boolean
---@field sprintFOVOffset number
---@field baseFOV number
---@field currentFOV number
---@field zoomInterpolationSpeed number
---@field sprintFOVInterpolationSpeed number
---@field shoulderSwapInterpolationSpeed number
---@field isBobbingEnabled boolean
---@field isBobbingFreqSyncEnabled boolean
---@field bobbingAmountHorizontal number
---@field bobbingAmountVertical number
---@field bobbingFreqHorizontal number
---@field bobbingFreqVertical number
---@field new fun(options: SimpleCustomThirdPerson_options): SimpleCustomThirdPerson
---@field IsEnabled fun(self: SimpleCustomThirdPerson): boolean
---@field SetEnabled fun(self: SimpleCustomThirdPerson, enable: boolean): nil
---@field GetSensitivity fun(self: SimpleCustomThirdPerson): number
---@field SetSensitivity fun(self: SimpleCustomThirdPerson, sensitivity: number): nil
---@field GetYaw fun(self: SimpleCustomThirdPerson): number
---@field GetPitch fun(self: SimpleCustomThirdPerson): number
---@field GetShoulderSide fun(self: SimpleCustomThirdPerson): SimpleCustomThirdPerson_ShoulderSideWithCenter
---@field SetShoulderSide fun(self: SimpleCustomThirdPerson, side: SimpleCustomThirdPerson_ShoulderSide): nil
---@field ToggleShoulderSide fun(self: SimpleCustomThirdPerson): nil
---@field CalculateAll fun(self: SimpleCustomThirdPerson): nil
---@field ApplyCameraTransform fun(self: SimpleCustomThirdPerson): nil
SimpleCustomThirdPerson = {}
SimpleCustomThirdPerson.__index = SimpleCustomThirdPerson

-- -------------------------------------------------------------------------- --
--                                 Constructor                                --
-- -------------------------------------------------------------------------- --

---@param options SimpleCustomThirdPerson_options
---@return SimpleCustomThirdPerson
function SimpleCustomThirdPerson.new(options)
	local instance = setmetatable({}, SimpleCustomThirdPerson)

	instance._isSimpleFirstPersonInstalled = false
	instance._isCameraFOVInstalled = false

	local sctp = SimpleCustomThirdPerson

	CreateThread(function()
		-- No need to wait a milisecond, because this mod loads after SimpleFP

		if sctp._CheckSimpleFirstPersonInstalled() then --[[@diagnostic disable-line]]
			instance._isSimpleFirstPersonInstalled = true --[[@diagnostic disable-line]]
			print('"Simple First Person" mod installed.')
		end

		if sctp._CheckCameraFOVInstalled() then --[[@diagnostic disable-line]]
			instance._isCameraFOVInstalled = true --[[@diagnostic disable-line]]
			print('"Camera FOV" mod installed.')
		end
	end)

	instance._maxYaw = math.rad(180)
	instance._maxPitch = math.rad(75)

	instance.isEnabled = false

	instance.yaw = 0
	-- instance.unclampedYaw = 0
	-- instance.targetYaw = 0
	-- instance.lastYawMoved = GetTimer()
	instance.actualYaw = 0
	instance.pitch = 0

	instance.pos = { 0, 0, 0 }
	instance.look = { 0, 0, 0 }

	instance.useInvertedControlX = options.useInvertedControlX
	instance.useInvertedControlY = options.useInvertedControlY

	instance.sensitivity = options.sensitivity
	instance.yawOffsetDegree = options.yawOffsetDegree
	instance.currentYawOffsetDegree = instance.yawOffsetDegree
	instance.heightOffset = options.heightOffset
	instance.posDist = options.posDist
	instance.currentPosDist = instance.posDist
	instance.lookDist = options.lookDist
	instance.maxZoom = options.maxZoom
	instance.zoomMult = options.zoomMult

	instance.isSprintFOVEnabled = options.enableSprintFOV
	instance.sprintFOVOffset = options.sprintFOVOffset
	instance.baseFOV = options.baseFOV
	instance.currentFOV = instance.baseFOV

	instance.zoomInterpolationSpeed = options.zoomInterpolationSpeed
	instance.sprintFOVInterpolationSpeed = options.sprintFOVInterpolationSpeed
	instance.shoulderSwapInterpolationSpeed =
		options.shoulderSwapInterpolationSpeed

	instance.isBobbingEnabled = options.enableBobbing
	instance.isBobbingFreqSyncEnabled = options.enableBobFreqSyncWithAnimSpeed
	instance.bobbingAmountHorizontal = options.bobbingAmountHorizontal
	instance.bobbingAmountVertical = options.bobbingAmountVertical
	instance.bobbingFreqHorizontal = options.bobbingFreqHorizontal
	instance.bobbingFreqVertical = options.bobbingFreqVertical

	return instance
end

-- -------------------------------------------------------------------------- --
--                         Local Variables & Functions                        --
-- -------------------------------------------------------------------------- --

local MIN_SPRINT_VELOCITY = 5
local yawDiff = 0

-- --------------------------- _HandleSprintFOV() --------------------------- --

-- local isTransitioning = false
-- local magnitude = 0
local ANIM_SPEED_PEDSTAT_ID = 20
local isSprinting = false
local speed = 0

-- -------------------------- _HandleHeadBobbing() -------------------------- --

local timerDiv1000 = 0

-- ------------------------- _CalculateOrientation() ------------------------ --

local MOUSE_MULT = -0.01
local ctrlRotX, ctrlRotY = 0, 0
local frameTime = 0

-- ------------------------ _CalculateCamPosAndLook() ----------------------- --

local VEH_HEIGHT_OFFSET = {
	-- Bike
	[272] = 0.4, -- Green BMX
	[273] = 0.4, -- Brown BMX
	[274] = 0.4, -- Crap BMX
	[277] = 0.4, -- Red BMX
	[278] = 0.4, -- Blue BMX
	[279] = 0.4, -- Bicycle
	[280] = 0.4, -- Mountain bike
	[281] = 0.4, -- Old lady bike
	[282] = 0.4, -- Racer bike
	[283] = 0.4, -- Aquaberry bike

	-- Car
	[284] = 0.7, -- Mower
	[285] = 0.9, -- Arcade 3
	[286] = 0.9, -- Taxi
	[287] = 0.9, -- Arcade 2
	[288] = 0.9, -- Dozer
	[289] = 0.9, -- Go-Kart
	[290] = 0.9, -- Limo
	[291] = 0.9, -- Delivery Truck
	[292] = 1, -- Foreign Car
	[293] = 0.9, -- Regular Car
	[294] = 0.9, -- 70 Wagon
	[295] = 0.9, -- Cop Car
	[296] = 0.9, -- Domestic Car
	[297] = 0.9, -- SUV
	[298] = 0.6, -- Arcade 1
}
local px, py, pz = 0, 0, 0
local posRot = { 0, 0, 0 }
local lookRot = { 0, 0, 0 }

-- ------------------------ _GetVehicleHeightOffset() ----------------------- --

local vehHeightOffset = 0

-- bobbing

local velocity3d = { 0, 0, 0 }
local bobHorFreqSynchronized = 0
local bobVertFreqSynchronized = 0
local finalBobHorFreqValue = 0
local finalBobVertFreqValue = 0

-- -------------------------------------------------------------------------- --
--                                   Methods                                  --
-- -------------------------------------------------------------------------- --

-- --------------------------------- Private -------------------------------- --

-- Static

---@return boolean
function SimpleCustomThirdPerson._CheckSimpleFirstPersonInstalled()
	---@diagnostic disable-next-line: undefined-field
	if type(_G.SIMPLE_FIRST_PERSON) == "table" then
		return true
	end
	return false
end

---@return boolean
function SimpleCustomThirdPerson._CheckCameraFOVInstalled()
	---@diagnostic disable-next-line: undefined-field
	if type(_G.CAMERA_FOV_MOD) == "table" then
		return true
	end
	return false
end

-- Non-static

function SimpleCustomThirdPerson:_HandleSprintFOV()
	if self.isSprintFOVEnabled then
		--[[ if not PlayerIsInAnyVehicle() and PedGetWeapon(gPlayer) ~= 437 then
			-- velocity[1], velocity[2], velocity[3] = GetPlayerVelocity()
			-- magnitude = math.sqrt(velocity[1] ^ 2 + velocity[2] ^ 2)

			if
				-- magnitude > MIN_SPRINT_VELOCITY / 100 * GameGetPedStat(gPlayer, 20)
				UTIL.PlayerIsSprinting() or PedMePlaying(gPlayer, "Jump")
			then
				isSprinting = true
			else
				isSprinting = false
			end
		end ]]

		isSprinting = not PlayerIsInAnyVehicle()
			and PedGetWeapon(gPlayer) ~= 437
			and (UTIL.PlayerIsSprinting() or PedMePlaying(gPlayer, "Jump"))
			and speed
				>= MIN_SPRINT_VELOCITY / 100 * GameGetPedStat(
					gPlayer,
					ANIM_SPEED_PEDSTAT_ID
				)

		if isSprinting then
			-- isTransitioning = true
			if CameraGetFOV() ~= self.baseFOV + self.sprintFOVOffset then
				self.currentFOV = UTIL.LerpOptimized(
					self.currentFOV,
					self.baseFOV + self.sprintFOVOffset,
					self.sprintFOVInterpolationSpeed
				)
				CameraSetFOV(self.currentFOV)
			end
		else
			if CameraGetFOV() ~= self.baseFOV then
				-- isTransitioning = false

				self.currentFOV = UTIL.LerpOptimized(
					self.currentFOV,
					self.baseFOV,
					self.sprintFOVInterpolationSpeed
				)
				CameraSetFOV(self.currentFOV)
			end
		end
	end
end

function SimpleCustomThirdPerson:_CalculateOrientation()
	-- Controller handler
	if IsUsingJoystick(0) then
		ctrlRotX, ctrlRotY = GetStickValue(18, 0), GetStickValue(19, 0)
		ctrlRotX, ctrlRotY = ctrlRotX * 1.5, ctrlRotY * 1.5
	else
		ctrlRotX, ctrlRotY = GetMouseInput()
		ctrlRotX, ctrlRotY = ctrlRotX * 3 * MOUSE_MULT, ctrlRotY * 3 * MOUSE_MULT
	end

	frameTime = GetFrameTime()

	if self.useInvertedControlX then
		ctrlRotX = -ctrlRotX
	end
	if self.useInvertedControlY then
		ctrlRotY = -ctrlRotY
	end

	self.yaw = self.yaw + ctrlRotX * self.sensitivity * frameTime
	self.pitch = self.pitch + ctrlRotY * self.sensitivity * frameTime

	self.yaw = UTIL.FixRadians(self.yaw)
	self.pitch = UTIL.Clamp(self.pitch, -self._maxPitch, self._maxPitch)

	-- Auto camera rotation based on player's direction
	--   (plz hlep.. i don't know the math 😭)
	--[[ if
		math.abs(GetStickValue(16, 0)) > 0 or math.abs(GetStickValue(17, 0)) > 0
	then
		if math.abs(mouseX) > 0 then
			self.lastYawMoved = GetTimer()
		elseif GetTimer() >= self.lastYawMoved + 1000 then
			self.targetYaw = UTIL.FixRadians(
				PedGetHeading(gPlayer) + math.rad(90) + (self.yaw - self.actualYaw)
			)
			-- self.yaw = UTIL.LerpOptimized(self.yaw, self.targetYaw, 0.05) -- ???
			self.yaw = self.targetYaw
		end
	end ]]
end

function SimpleCustomThirdPerson:_CalculateActualYaw()
	self.actualYaw =
		math.atan2(self.look[2] - self.pos[2], self.look[1] - self.pos[1])

	yawDiff = self.actualYaw - self.yaw
end

function SimpleCustomThirdPerson:_HandleShoulderSwap()
	if self.currentYawOffsetDegree ~= self.yawOffsetDegree then
		self.currentYawOffsetDegree = UTIL.LerpOptimized(
			self.currentYawOffsetDegree,
			self.yawOffsetDegree,
			self.shoulderSwapInterpolationSpeed
		)
	end
end

---@param vehicleId integer
function SimpleCustomThirdPerson:_GetVehicleHeightOffset(vehicleId)
	vehHeightOffset = VEH_HEIGHT_OFFSET[vehicleId]
	return vehHeightOffset or 0
end

function SimpleCustomThirdPerson:_CalculateCamPosAndLook()
	posRot[1] = math.cos(self.yaw + math.rad(180 + self.currentYawOffsetDegree))
		* math.cos(self.pitch)
	posRot[2] = math.sin(self.yaw + math.rad(180 + self.currentYawOffsetDegree))
		* math.cos(self.pitch)
	posRot[3] = math.sin(self.pitch)

	lookRot[1] = math.cos(self.yaw) * math.cos(self.pitch)
	lookRot[2] = math.sin(self.yaw) * math.cos(self.pitch)
	lookRot[3] = math.sin(self.pitch)

	px, py, pz = PlayerGetPosXYZ()
	pz = pz + self.heightOffset

	---Lower a little bit the camera position while driving a vehicle
	if PlayerIsInAnyVehicle() then
		pz = pz
			- self:_GetVehicleHeightOffset(
				VehicleGetModelId(VehicleFromDriver(gPlayer))
			)
	end

	self.currentPosDist = UTIL.LerpOptimized(
		self.currentPosDist,
		self.posDist,
		self.zoomInterpolationSpeed
	)

	self.pos[1] = px + posRot[1] * self.currentPosDist
	self.pos[2] = py + posRot[2] * self.currentPosDist
	self.pos[3] = pz - posRot[3] * self.currentPosDist

	self.look[1] = px + lookRot[1] * self.lookDist
	self.look[2] = py + lookRot[2] * self.lookDist
	self.look[3] = pz + lookRot[3] * self.lookDist
end

function SimpleCustomThirdPerson:_HandleHeadBobbing()
	if
		self.isBobbingEnabled
		and not PlayerIsInAnyVehicle()
		and not PedMePlaying(gPlayer, "Jump")
		and UTIL.PlayerIsSprinting()
		and speed
			>= MIN_SPRINT_VELOCITY / 100 * GameGetPedStat(
				gPlayer,
				ANIM_SPEED_PEDSTAT_ID
			)
	then
		timerDiv1000 = GetTimer() / 1000

		if self.isBobbingFreqSyncEnabled then
			bobHorFreqSynchronized = self.bobbingFreqHorizontal
				/ 100
				* GameGetPedStat(gPlayer, ANIM_SPEED_PEDSTAT_ID)

			bobVertFreqSynchronized = self.bobbingFreqVertical
				/ 100
				* GameGetPedStat(gPlayer, ANIM_SPEED_PEDSTAT_ID)

			finalBobHorFreqValue = bobHorFreqSynchronized
			finalBobVertFreqValue = bobVertFreqSynchronized
		else
			finalBobHorFreqValue = self.bobbingFreqHorizontal
			finalBobVertFreqValue = self.bobbingFreqVertical
		end

		self.pos[1] = self.pos[1]
			+ math.sin(timerDiv1000 * finalBobHorFreqValue)
				* math.cos(self.yaw + math.rad(90)) -- add or subtract by 90 degree in radians to move left-right instead of forward-backward
				* self.bobbingAmountHorizontal

		self.pos[2] = self.pos[2]
			+ math.sin(timerDiv1000 * finalBobHorFreqValue)
				* math.sin(self.yaw + math.rad(90)) -- add or subtract by 90 degree in radians to move left-right instead of forward-backward
				* self.bobbingAmountHorizontal

		self.pos[3] = self.pos[3]
			+ math.sin(timerDiv1000 * finalBobVertFreqValue)
				* self.bobbingAmountVertical
	end
end

-- --------------------------------- Public --------------------------------- --

-- Non-static, utility methods

---@return boolean
function SimpleCustomThirdPerson:IsEnabled()
	return self.isEnabled
end

---@param enable boolean
function SimpleCustomThirdPerson:SetEnabled(enable)
	self.isEnabled = enable

	if self.isEnabled then
		-- Disable First Person if Simple First Person is installed
		if self._isSimpleFirstPersonInstalled then
			_G.SIMPLE_FIRST_PERSON.GetSingleton():SetEnabled(false)
		end
		-- if self._isCameraFOVInstalled then
		-- _G.CAMERA_FOV_MOD
		-- end

		self.yaw = UTIL.FixRadians(PedGetHeading(gPlayer) + math.rad(90) - yawDiff)
	else
		self.currentFOV = self.baseFOV
		CameraDefaultFOV()
		CameraAllowChange(true)
		CameraReturnToPlayer()
	end
end

---@return number
function SimpleCustomThirdPerson:GetSensitivity()
	return self.sensitivity
end

---@param sensitivity number
function SimpleCustomThirdPerson:SetSensitivity(sensitivity)
	self.sensitivity = sensitivity
end

---@return number
function SimpleCustomThirdPerson:GetYaw()
	return self.actualYaw
end

---@return number
function SimpleCustomThirdPerson:GetPitch()
	return self.pitch
end

local MIN_ZOOM = 0.5
---@param change "increment"|"decrement"
function SimpleCustomThirdPerson:SetZoom(change)
	if change == "increment" then
		self.posDist = math.min(self.maxZoom, self.posDist + 0.1 * self.zoomMult)
	else
		self.posDist = math.max(MIN_ZOOM, self.posDist - 0.1 * self.zoomMult)
	end
	self.currentPosDist = UTIL.LerpOptimized(
		self.currentPosDist,
		self.posDist,
		self.zoomInterpolationSpeed
	)
end

---@return SimpleCustomThirdPerson_ShoulderSideWithCenter
function SimpleCustomThirdPerson:GetShoulderSide()
	return self.yawOffsetDegree < 0 and "left"
		or self.yawOffsetDegree > 0 and "right"
		or "center"
end

---@param side SimpleCustomThirdPerson_ShoulderSide
function SimpleCustomThirdPerson:SetShoulderSide(side)
	self.yawOffsetDegree = side == "left" and -self.yawOffsetDegree
		or math.abs(self.yawOffsetDegree)
end

function SimpleCustomThirdPerson:ToggleShoulderSide()
	-- local currentSide = self:GetShoulderSide()
	-- self:SetShoulderSide(currentSide == "left" and "right" or "left")
	self.yawOffsetDegree = -self.yawOffsetDegree
end

function SimpleCustomThirdPerson:CalculateAll()
	-- Update local shared variables

	velocity3d[1], velocity3d[2], velocity3d[3] = UTIL.GetPlayerVelocity()
	speed = math.sqrt(velocity3d[1] ^ 2 + velocity3d[2] ^ 2 + velocity3d[3] ^ 2)

	-- Local shared variable is now updated with the new value & ready to be used
	-- inside below functions.

	self:_CalculateOrientation()
	self:_HandleShoulderSwap()
	self:_CalculateCamPosAndLook()
	self:_CalculateActualYaw()
	self:_HandleSprintFOV()
	self:_HandleHeadBobbing()
end

function SimpleCustomThirdPerson:ApplyCameraTransform()
	CameraSetXYZ(
		self.pos[1],
		self.pos[2],
		self.pos[3],
		self.look[1],
		self.look[2],
		self.look[3]
	)
	CameraAllowChange(false)
end
