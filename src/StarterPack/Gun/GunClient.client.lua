local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local tool = script.Parent

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local fireWeapon = remotes:WaitForChild("FireWeapon")

local canShoot = true
local fireCooldown = 0.2

tool.Activated:Connect(function()
	if not canShoot then
		return
	end

	canShoot = false

	fireWeapon:FireServer(mouse.Hit.Position)

	task.wait(fireCooldown)
	canShoot = true
end)