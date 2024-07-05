local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GunFiringEvent = ReplicatedStorage:FindFirstChild("GunFiringEvent")
local MediShootEvent = ReplicatedStorage:FindFirstChild("MediShootEvent")
local AnimationEvent = ReplicatedStorage:FindFirstChild("AnimationEvent")
local DamageMarker = ReplicatedStorage:FindFirstChild("DamageMarker")
local Players = game:GetService("Players")
local DamageGiven = nil

function PlayerJoined(Player)
	local function QueryToggle(Character) --Sets the CanQuery Property of all Accessories on each player to false; No Damage through hats
		local CharacterHumanoid = Character.Humanoid
		for i,Accessories in pairs (Character:GetDescendants()) do
			if Accessories:IsA("Accessory") then
				Accessories.Handle.CanQuery = false
			end
		end
	end
	Player.CharacterAppearanceLoaded:Connect(QueryToggle)
end

Players.PlayerAdded:Connect(PlayerJoined)

--Damage facilitation with variables from LocalGunScript

local TeamColorIsDifferent = nil

function CastRay(Player, Humanoid, MousePosition, Handle, CHR, Gun, MouseTarget, HeadDamage, TorsoDamage, LimbDamage, FriendlyFireEnabled, ServerRayBeam, ServerHitting, ServerDistance, ServerRayPartCFrame, ServerRayPartSize)
	if Humanoid and Humanoid ~= 0 then
		for i,OtherPlayer in pairs (game.Players:GetPlayers()) do
			if OtherPlayer ~= Player then
				GunFiringEvent:FireClient(OtherPlayer, ServerRayPartCFrame, ServerRayPartSize)
			end
		end
		if ServerHitting and ServerHitting.Parent and (ServerHitting.Parent:FindFirstChild("Humanoid") or ServerHitting.Parent.Parent:FindFirstChild("Humanoid")) then
			local OtherHumanoid = ServerHitting.Parent:FindFirstChild("Humanoid") or ServerHitting.Parent.Parent:FindFirstChild("Humanoid")
			if OtherHumanoid then
				
				local NonLimbDamage = (ServerHitting.Name ~= "Head" and ServerHitting.Name ~= "Torso" and ServerHitting.Name ~= "HumanoidRootPart" and ServerHitting.Parent.ClassName ~= "Handle")
				local HitPlayer = game.Players:GetPlayerFromCharacter(OtherHumanoid.Parent)
				if HitPlayer then
					if HitPlayer.TeamColor ~= Player.TeamColor then
						TeamColorIsDifferent = true
						if NonLimbDamage then
							OtherHumanoid:TakeDamage(LimbDamage)
							DamageGiven = LimbDamage
						elseif ServerHitting.Name == "Head" then
							print'HeadDamage'
							OtherHumanoid:TakeDamage(HeadDamage)
							DamageGiven = HeadDamage
						elseif ServerHitting.Name == "Torso" or ServerHitting.Name == "HumanoidRootPart" then
							OtherHumanoid:TakeDamage(TorsoDamage)
						elseif ServerHitting.Name == "Handle" then
							OtherHumanoid:TakeDamage(HeadDamage)
							print'AccessoryDamage'
							DamageGiven = HeadDamage
						end
						DamageMarker:FireClient(Player, DamageGiven, OtherHumanoid, ServerHitting, TeamColorIsDifferent)
					else
						if FriendlyFireEnabled then
							TeamColorIsDifferent = true
							if NonLimbDamage then
								OtherHumanoid:TakeDamage(LimbDamage)
							elseif ServerHitting.Name == "Head" then
								print'HeadDamage'
								OtherHumanoid:TakeDamage(HeadDamage)
								DamageGiven = HeadDamage
							elseif ServerHitting.Name == "Torso" or ServerHitting.Name == "HumanoidRootPart" then
								OtherHumanoid:TakeDamage(TorsoDamage)
								DamageGiven = TorsoDamage
							elseif ServerHitting.Name == "Handle" then
								OtherHumanoid:TakeDamage(HeadDamage)
								print'AccessoryDamage'
								DamageGiven = HeadDamage
							end
						end
						DamageMarker:FireClient(Player, DamageGiven, OtherHumanoid, ServerHitting, TeamColorIsDifferent)
					end
					
				else --Assumes there is no player attached to character; NPC
					TeamColorIsDifferent = true
					if NonLimbDamage then
						OtherHumanoid:TakeDamage(LimbDamage)
						print(LimbDamage)
						DamageGiven = LimbDamage
					elseif ServerHitting.Name == "Head" then
						OtherHumanoid:TakeDamage(HeadDamage)
						print'HeadDamage'
						DamageGiven = HeadDamage
					elseif ServerHitting.Name == "Torso" or ServerHitting.Name == "HumanoidRootPart" then
						OtherHumanoid:TakeDamage(TorsoDamage)
						DamageGiven = TorsoDamage
						print(TorsoDamage)
					elseif ServerHitting.Name == "Handle" then
						OtherHumanoid:TakeDamage(HeadDamage)
						DamageGiven = HeadDamage
						print'AccessoryDamage'
					end
					DamageMarker:FireClient(Player, DamageGiven, OtherHumanoid, ServerHitting, TeamColorIsDifferent)
				end
				TeamColorIsDifferent = false
			end
		end
	end
end



--Healing facilitation with variables from LocalMediScript

function Heal(Player, Handle, OtherCharacter, OtherHumanoid)
	print'healing'
	OtherHumanoid:TakeDamage(-4)
	for i,OtherPlayer in pairs (game.Players:GetPlayers()) do
		if OtherPlayer ~= Player then
			MediShootEvent:FireClient(OtherPlayer, Handle, OtherCharacter, OtherHumanoid)
		end
	end
end

GunFiringEvent.OnServerEvent:Connect(CastRay)
MediShootEvent.OnServerEvent:Connect(Heal)
