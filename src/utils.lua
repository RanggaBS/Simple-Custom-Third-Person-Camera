-- -------------------------------------------------------------------------- --
--                                  Utilities                                 --
-- -------------------------------------------------------------------------- --

UTIL = {}

---@param value number
---@param min number
---@param max number
---@return number
function UTIL.Clamp(value, min, max)
	return value < min and min or value > max and max or value
end

---@param value number
---@param min number
---@param max number
---@param ifmin number
---@param ifmax number
---@return number
function UTIL.Clamp2(value, min, max, ifmin, ifmax)
	return value < min and ifmin or value > max and ifmax or value
end

---@param rads number
---@return number
function UTIL.FixRadians(rads) -- keep radians between -pi and pi.
	while rads > math.pi do
		rads = rads - math.pi * 2
	end
	while rads <= -math.pi do
		rads = rads + math.pi * 2
	end
	return rads
end

---@param a number
---@param b number
---@param t number
---@return number
function Lerp(a, b, t)
	return a + (b - a) * t
end

local DIGITS_PRECISION_TOLERANCY = 0.01
---@param a number
---@param b number
---@param t number
---@return number
function UTIL.LerpOptimized(a, b, t)
	local lerp = Lerp(a, b, t)

	if b < 0 then
		-- if (-v < -b) && (-v > -b) - 0.01
		if lerp < b and lerp > b - DIGITS_PRECISION_TOLERANCY then
			return b

			-- if (-v > -b) && (-v < -b) + 0.01
		elseif lerp > b and lerp < b + DIGITS_PRECISION_TOLERANCY then
			return b
		end
	--
	elseif b > 0 then
		-- if (v < b) && (v > b) - 0.01
		if lerp < b and lerp > b - DIGITS_PRECISION_TOLERANCY then
			return b

			-- if (v > b) && (v < b) + 0.01
		elseif lerp > b and lerp < b + DIGITS_PRECISION_TOLERANCY then
			return b
		end
	end

	return lerp
end

---https://gist.github.com/HelloKitty/91b7af87aac6796c3da9
---
---https://stackoverflow.com/questions/11492299/quaternion-to-euler-angles-algorithm-how-to-convert-to-y-up-and-between-ha
---@param yaw number
---@param pitch number
---@param roll number
---@return number x, number y, number z, number w
function CreateFromYawPitchRoll(yaw, pitch, roll)
	local rollOver2 = roll * 0.5
	local sinRollOver2 = math.sin(rollOver2)
	local cosRollOver2 = math.cos(rollOver2)

	local pitchOver2 = pitch * 0.5
	local sinPitchOver2 = math.sin(pitchOver2)
	local cosPitchOver2 = math.cos(pitchOver2)

	local yawOver2 = yaw * 0.5
	local sinYawOver2 = math.sin(yawOver2)
	local cosYawOver2 = math.cos(yawOver2)

	local result = { 0, 0, 0, 0 }
	result[1] = cosYawOver2 * cosPitchOver2 * cosRollOver2
		+ sinYawOver2 * sinPitchOver2 * sinRollOver2
	result[2] = cosYawOver2 * cosPitchOver2 * sinRollOver2
		- sinYawOver2 * sinPitchOver2 * cosRollOver2
	result[3] = cosYawOver2 * sinPitchOver2 * cosRollOver2
		+ sinYawOver2 * cosPitchOver2 * sinRollOver2
	result[4] = sinYawOver2 * cosPitchOver2 * cosRollOver2
		- cosYawOver2 * sinPitchOver2 * sinRollOver2

	return unpack(result)
end

local lastSprintPressed = GetTimer()
local DELAY = 300
function UTIL.PlayerIsSprinting()
	if
		math.abs(GetStickValue(16, 0)) > 0 or math.abs(GetStickValue(17, 0)) > 0
	then
		if IsButtonPressed(7, 0) then
			lastSprintPressed = GetTimer()
			return true
		elseif
			GetTimer()
			< lastSprintPressed + DELAY * 100 / GameGetPedStat(gPlayer, 20)
		then
			return true
		end
	end
	return false
end

---@return number, number
function UTIL.GetDirectionalMovement()
	local leftRight, forwardBackward = -GetStickValue(16, 0), GetStickValue(17, 0)
	-- return leftRight + forwardBackward
	return leftRight, forwardBackward
end

local playerPos = { 0, 0, 0 }
local playerLastPos = { 0, 0, 0 }
local playerVelocity = { 0, 0, 0 }
local frameTime = 0
---Don't call this function twice, otherwise it'll always return 0.
---@return number velocityX, number velocityY, number velocityZ
function UTIL.GetPlayerVelocity()
	-- Update last position
	for axis = 1, 3 do
		playerLastPos[axis] = playerPos[axis]
	end

	playerPos[1], playerPos[2], playerPos[3] = PlayerGetPosXYZ()

	frameTime = GetFrameTime()

	for axis = 1, 3 do
		playerVelocity[axis] = (playerPos[axis] - playerLastPos[axis]) / frameTime
	end

	return unpack(playerVelocity)
end
