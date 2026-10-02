local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create the RemoteEvent folder
local remotes = ReplicatedStorage:FindFirstChild("Remotes")

if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
end

-- Create the firing RemoteEvent
local fireWeapon = remotes:FindFirstChild("FireWeapon")

if not fireWeapon then
	fireWeapon = Instance.new("RemoteEvent")
	fireWeapon.Name = "FireWeapon"
	fireWeapon.Parent = remotes
end

local DAMAGE = 25
local RANGE = 500
local FIRE_COOLDOWN = 0.15

local lastShot = {}

fireWeapon.OnServerEvent:Connect(function(player, targetPosition)
	-- Make sure the client sent a Vector3
	if typeof(targetPosition) ~= "Vector3" then
		return
	end

	-- Server-side fire rate check
	local currentTime = os.clock()

	if currentTime - (lastShot[player] or 0) < FIRE_COOLDOWN then
		return
	end

	lastShot[player] = currentTime

	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local head = character:FindFirstChild("Head")
	local gun = character:FindFirstChild("Gun")

	-- Player must be alive and actually holding the gun
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	if not head or not gun then
		return
	end

	-- Calculate shooting direction
	local direction = targetPosition - head.Position

	if direction.Magnitude <= 0 then
		return
	end

	direction = direction.Unit * math.min(direction.Magnitude, RANGE)

	-- Raycast settings
	local raycastParams = RaycastParams.new()

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		character
	}

	raycastParams.IgnoreWater = true

	-- Shoot the ray
	local result = workspace:Raycast(
		head.Position,
		direction,
		raycastParams
	)

	if not result then
		return
	end

	-- Find the model that was hit
	local hitModel = result.Instance:FindFirstAncestorOfClass("Model")

	if not hitModel then
		return
	end

	local targetHumanoid = hitModel:FindFirstChildOfClass("Humanoid")

	-- Damage the target
	if targetHumanoid and targetHumanoid ~= humanoid then
		targetHumanoid:TakeDamage(DAMAGE)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	lastShot[player] = nil
end)