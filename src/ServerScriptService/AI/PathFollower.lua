-- PathFollower.lua
-- Mueve brainrots por waypoints predefinidos
-- Ubicación: ServerScriptService/AI/PathFollower

local PathFollower = {}
PathFollower.__index = PathFollower

local waypoints: {Vector3} = {}
local waypointsLoaded = false

-- Cargar waypoints del mapa (se llama una vez al inicio)
function PathFollower.LoadWaypoints()
	if waypointsLoaded then return end

	local waypointFolder = workspace:FindFirstChild("Map")
		and workspace.Map:FindFirstChild("Path")
		and workspace.Map.Path:FindFirstChild("Waypoints")

	if not waypointFolder then
		warn("[PathFollower] No se encontró Workspace.Map.Path.Waypoints")
		return
	end

	-- Recolectar y ordenar waypoints por nombre numérico
	local parts = {}
	for _, child in ipairs(waypointFolder:GetChildren()) do
		if child:IsA("BasePart") then
			local num = tonumber(child.Name)
			if num then
				parts[num] = child.Position
			end
		end
	end

	-- Construir array ordenado
	waypoints = {}
	local index = 1
	while parts[index] do
		table.insert(waypoints, parts[index])
		index = index + 1
	end

	waypointsLoaded = true
	print("[PathFollower] Cargados " .. #waypoints .. " waypoints")
end

-- Obtener total de waypoints
function PathFollower.GetWaypointCount(): number
	return #waypoints
end

-- Obtener posición del primer waypoint (spawn point)
function PathFollower.GetSpawnPosition(): Vector3
	if #waypoints == 0 then
		return Vector3.new(0, 2, 0)
	end
	return waypoints[1] + Vector3.new(0, 1, 0)
end

-- Obtener posición de un waypoint específico
function PathFollower.GetWaypointPosition(index: number): Vector3?
	return waypoints[index]
end

-- Mover un brainrot hacia su siguiente waypoint
-- Retorna true si llegó al final del camino
function PathFollower.Update(brainrot: any, dt: number): boolean
	if #waypoints == 0 then return false end

	local targetIndex = brainrot.pathIndex + 1
	local target = waypoints[targetIndex]

	-- Si no hay más waypoints, llegó al final
	if not target then
		return true
	end

	-- Calcular dirección y movimiento
	local currentPos = brainrot.position
	local direction = target - currentPos
	local distance = direction.Magnitude

	if distance < 0.1 then
		-- Llegó al waypoint, avanzar al siguiente
		brainrot.pathIndex = targetIndex
		return PathFollower.Update(brainrot, dt) -- Recursión para el siguiente
	end

	-- Calcular velocidad efectiva (con slow)
	local effectiveSpeed = brainrot.speed * (1 - brainrot.slowAmount)
	effectiveSpeed = math.max(effectiveSpeed, brainrot.speed * 0.1) -- Mínimo 10% velocidad

	-- Mover
	local moveDistance = effectiveSpeed * dt
	if moveDistance >= distance then
		-- Llegamos al waypoint este frame
		brainrot.position = target
		brainrot.pathIndex = targetIndex
	else
		brainrot.position = currentPos + direction.Unit * moveDistance
	end

	return false
end

return PathFollower
