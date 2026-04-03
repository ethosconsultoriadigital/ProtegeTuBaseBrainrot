-- PathFollower
-- Carga waypoints del mapa y mueve brainrots por ellos
-- Ubicación: ServerScriptService > AI > PathFollower (ModuleScript)

local PathFollower = {}
PathFollower.__index = PathFollower

local waypoints: {Vector3} = {}
local loaded = false

-- Cargar waypoints una sola vez
function PathFollower.LoadWaypoints()
	if loaded then return end

	local folder = workspace:FindFirstChild("Map")
		and workspace.Map:FindFirstChild("Path")
		and workspace.Map.Path:FindFirstChild("Waypoints")

	if not folder then
		warn("[PathFollower] Workspace.Map.Path.Waypoints no encontrado")
		return
	end

	local parts = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("BasePart") then
			local n = tonumber(child.Name)
			if n then parts[n] = child.Position end
		end
	end

	waypoints = {}
	local i = 1
	while parts[i] do
		table.insert(waypoints, parts[i])
		i += 1
	end

	loaded = true
	print("[PathFollower] " .. #waypoints .. " waypoints cargados")
end

function PathFollower.GetSpawnPosition(): Vector3
	if #waypoints == 0 then return Vector3.new(0, 2, 0) end
	return waypoints[1] + Vector3.new(0, 1, 0)
end

function PathFollower.GetWaypointCount(): number
	return #waypoints
end

-- Mover brainrot un paso. Retorna true si llego al final.
function PathFollower.Update(br, dt: number): boolean
	if #waypoints == 0 then return false end

	local nextIdx = br.pathIndex + 1
	local target = waypoints[nextIdx]
	if not target then return true end

	local dir = target - br.position
	local dist = dir.Magnitude

	if dist < 0.5 then
		br.pathIndex = nextIdx
		return PathFollower.Update(br, dt) -- recursion al siguiente wp
	end

	local effectiveSpeed = br.speed * math.max(0.1, 1 - br.slowAmount)
	local step = effectiveSpeed * dt

	if step >= dist then
		br.position = target
		br.pathIndex = nextIdx
	else
		br.position = br.position + dir.Unit * step
	end

	return false
end

return PathFollower
