-- PathFollower
-- Mueve una Part a lo largo de waypoints con velocidad variable
-- Ubicación: ServerScriptService > AI > PathFollower (ModuleScript)
--
-- Uso:
--   local pf = PathFollower.new(part, waypoints, speed)
--   pf:Update(dt)             → avanza
--   pf:IsFinished()           → true si llego al final
--   pf:GetProgress()          → 0..1 progreso total del camino
--   pf:SetSpeedMultiplier(m)  → para slow effects (IceTrap, etc.)
--
-- Diseño: puro, sin dependencias externas. Reutilizable para cualquier
-- entidad que necesite seguir un camino.

local PathFollower = {}
PathFollower.__index = PathFollower

function PathFollower.new(part: BasePart, waypoints: {Vector3}, baseSpeed: number)
	local self = setmetatable({}, PathFollower)

	self._part = part
	self._waypoints = waypoints
	self._baseSpeed = baseSpeed
	self._speedMult = 1.0
	self._currentIndex = 2       -- apuntamos al segundo wp (ya estamos en el primero)
	self._finished = false
	self._totalDistance = 0
	self._distanceTraveled = 0

	-- Pre-calcular distancia total (para GetProgress)
	for i = 1, #waypoints - 1 do
		self._totalDistance += (waypoints[i + 1] - waypoints[i]).Magnitude
	end

	-- Posicionar en el primer waypoint
	if #waypoints > 0 then
		part.Position = waypoints[1]
	end
	if #waypoints < 2 then
		self._finished = true
	end

	return self
end

function PathFollower:Update(dt: number)
	if self._finished then return end
	if not self._part or not self._part.Parent then
		self._finished = true
		return
	end

	local waypoints = self._waypoints
	local speed = self._baseSpeed * self._speedMult
	local remaining = speed * dt

	while remaining > 0 and self._currentIndex <= #waypoints do
		local target = waypoints[self._currentIndex]
		local current = self._part.Position
		local delta = target - current
		local dist = delta.Magnitude

		if dist < 0.01 then
			-- Ya estamos en el waypoint, avanzar indice
			self._currentIndex += 1
			continue
		end

		if dist <= remaining then
			self._part.Position = target
			self._distanceTraveled += dist
			remaining -= dist
			self._currentIndex += 1
		else
			local direction = delta.Unit
			self._part.Position = current + direction * remaining
			self._distanceTraveled += remaining
			remaining = 0
		end
	end

	if self._currentIndex > #waypoints then
		self._finished = true
	end
end

function PathFollower:IsFinished(): boolean
	return self._finished
end

function PathFollower:GetProgress(): number
	if self._totalDistance == 0 then return 1 end
	return math.clamp(self._distanceTraveled / self._totalDistance, 0, 1)
end

function PathFollower:SetSpeedMultiplier(mult: number)
	self._speedMult = math.max(0, mult)
end

function PathFollower:GetSpeedMultiplier(): number
	return self._speedMult
end

function PathFollower:GetCurrentSpeed(): number
	return self._baseSpeed * self._speedMult
end

function PathFollower:GetPosition(): Vector3?
	if self._part then return self._part.Position end
	return nil
end

function PathFollower:Destroy()
	self._finished = true
	self._part = nil
end

return PathFollower
