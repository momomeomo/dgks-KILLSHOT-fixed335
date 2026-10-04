local version = "3.3.5." .. "113"

local killingstreak = 0
local deathstreak = 0
local multikill = 0
local lastkill = 0
local myPlayerName = UnitName("player")
local lastDamageDealer = ""

dgks = LibStub("AceAddon-3.0"):NewAddon(
	"dgks",
	"AceEvent-3.0",
	"AceConsole-3.0",
	"LibSink-2.0"
)

function dgks:SoundEventHandler(sound)
	if not self.db.profile.dosound then
		return
	end

	if GetCVar("Sound_EnableAllSound") ~= "1" or GetCVar("Sound_EnableSFX") ~= "1" then
		return
	end

	PlaySoundFile(sound)
end

--local dgks = dgks

local function giveOptions() 
	local options = { 
		type = "group",
		name = "dG KillShot Notifier",
		--handler = dgks,
		get = function(k) return db[k.arg] end,
		set = function(k, v) db[k.arg] = v end,
		args = {
			maxks = {
				type = "description",
				name = "Version " .. version .. "\n\nCurrent killing streak: " .. killingstreak .. "\nLongest killing streak: " .. dgks.db.profile.maxkillingstreak .. "\n\nCurrent death streak: " .. deathstreak .. "\nLongest death streak: " .. dgks.db.profile.maxdeathstreak .. "\n\nLast 25 Kills\n" .. dgks.getKillLog() .. "\n\n",
				order = 10
			},			
			resetmaxks = {
				type = 'execute',
				name = 'Reset Stats',
				func = function()
					dgks.db.profile.maxkillingstreak = dgks.db.defaults.profile.maxkillingstreak
					dgks.db.profile.maxdeathstreak = dgks.db.defaults.profile.maxdeathstreak
					dgks.db.profile.killlog = dgks.db.defaults.profile.killlog
				end,
				width = "full",
				order = 20
			}
		}
	}
	return options
end

local function giveGeneral()
	local general = {
		type = "group",
		name = "General",
		handler = dgks,
		args = {
			dozonechange = {
				type = 'toggle',
				name = 'Clear Streaks on Zone Change',
				get = function()
					return dgks.db.profile.dozonechange
				end,
				set = function(info, b)
					dgks.db.profile.dozonechange = b
				end,
				width = "full",
				order = 20
			},
			doemote = {
				type = 'toggle',
				name = 'Show Emote',
				desc = 'Toggle Emote Spam',
				get = function()
					return dgks.db.profile.doemote
				end,
				set = function(info, b)
					dgks.db.profile.doemote = b
				end,
				width = "full",
				order = 30
			},
			ksemote = {
				type = 'input',
				name = 'Emote Message',
				desc = "Use this to customize the emote message. $v = victim $s = killingstreak",
				usage = "<message>",
				get = function()
					return dgks.db.profile.ksemote
				end,
				set = function(info, b)
					dgks.db.profile.ksemote = b
				end,
				width = "full",
				order = 40
			},
			docombattext = {
				type = 'toggle',
				name = "Show Combat Text",
				desc = 'Toggle Combat Text Spam',
				get = function()
					return dgks.db.profile.docombattext
				end,
				set = function(info, b)
					dgks.db.profile.docombattext = b
				end,
				width = "full",
				order = 50
			},			
			kstext = {
				type = 'input',
				name = 'Scrolling Text Message',
				desc = 'Use this to customize the Scrolling Text Message. $k = killer, $v = victim',
				usage = "<message>",
				get = function()
					return dgks.db.profile.kstext
				end,
				set = function(info, b)
					dgks.db.profile.kstext = b
				end,
				width = "full",
				order = 60
			},
			soundpack = {
				type = 'select',
				name = 'Sound Pack',
				desc = 'Choose a sound pack',
				get = "getSoundPack",
				set = "setSoundPack",
				values = {
					male = "male",
					female = "female",
					sexy = "sexy",
					baby = "baby"
				},
				order = 70
			},
			dosound = {
				type = 'toggle',
				name = "Play Sounds",
				desc = 'Toggle Sound Spam',
				get = function()
					return dgks.db.profile.dosound
				end,
				set = function(info, b)
					dgks.db.profile.dosound = b
				end,
				order = 80
			}
		}
	}
	return general
end


local function giveBroadcasts()
	local broadcasts = {
		type = "group",
		name = "Broadcasts",
		handler = dgks,
		args = {
			dobroadcasts = {
				type = 'toggle',
				name = 'Enable Broadcasts',
				desc = 'Enable/Disable all broadcasts',
				get = function()
					return dgks.db.profile.dobroadcast
				end,
				set = function(info, b)
					dgks.db.profile.dobroadcast = b
				end,
				width = "full",
				order = 80
			},
			doguild = {
				type = 'toggle',
				name = 'Broadcast to Guild',
				desc = 'Broadcast killshot to dgks users in guild.',
				get = function()
					return dgks.db.profile.doguild
				end,
				set = function(info, b)
					dgks.db.profile.doguild = b
				end,
				width = "full",
				order = 90
			},
			checkguild = {  
				type = 'execute',
				name = 'Check Guild Versions',
				width = "full",
				desc = 'Check Guild dgks versions',
				func = "CheckGuildVersions",
				order = 100
			},
			doraid = {
				type = 'toggle',
				name = 'Broadcast to Party, Raid or Battleground',
				desc = 'Broadcast killshot to dgks users in your paty, raid or battleground.',
				get = function()
					return dgks.db.profile.doraid
				end,
			 set = function(info, b)
					dgks.db.profile.doraid = b
				end,
				width = "full",
				order = 110
			},
			checkbg = {
				type = 'execute',
				width = "full",
				name = 'Check Battlegroup Versions',
				desc = 'Check BG Versions',
				func = "CheckBGVersions",
				order = 120
			},
			checkraid = {
				type = 'execute',
				width = "full",
				name = 'Check Raid Versions',
				desc = 'Check Raid Versions',
				func = "CheckRaidVersions",
				order = 130
			}
		}
	}
	return broadcasts 
end

local function giveProfiles()
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(dgks.db)
	return profiles
end

local function giveRanks()
	local ranks = {
		type = "group",
		name = "Rank Tuning",
		args = {
			ksrank1 = {
				type = 'range',
				name = 'KS Rank 1',
				desc = 'Number of kills to reach Rank 1',
				width = "full",
				get = function() return dgks.db.profile.ksrank[1] end,
				set = function(info, v) dgks.db.profile.ksrank[1] = v end,
				min = 0,
				max = 50,
				step = 1
			},
			ksrank2 = {
				type = 'range',
				name = 'KS Rank 2',
				desc = 'Number of kills to reach Rank 2',
				width = "full",
				get = function() return dgks.db.profile.ksrank[2] end,
				set = function(info, v) dgks.db.profile.ksrank[2] = v end,
				min = 1,
				max = 50,
				step = 1
			},
			ksrank3 = {
				type = 'range',
				name = 'KS Rank 3',
				desc = 'Number of kills to reach Rank 3',
				width = "full",
				get = function()
					return dgks.db.profile.ksrank[3]
				end,
				set = function(info, v)
					dgks.db.profile.ksrank[3] = v
				end,
				min = -1,
				max = 50,
				step = 1
			},
			ksrank4 = {
				type = 'range',
				name = 'KS Rank 4',
				desc = 'Number of kills to reach Rank 4',
				width = "full",
				get = function()
					return dgks.db.profile.ksrank[4]
				end,
				set = function(info, v)
					dgks.db.profile.ksrank[4] = v
				end,
				min = -1,
				max = 50,
				step = 1
			},
			ksrank5 = {
				type = 'range',
				name = 'KS Rank 5',
				desc = 'Number of kills to reach Rank 5',
				width = "full",
				get = function()
					return dgks.db.profile.ksrank[5]
				end,
				set = function(info, v)
					dgks.db.profile.ksrank[5] = v
				end,
				min = -1,
				max = 50,
				step = 1
			},
			ksrank6 = {
				type = 'range',
				name = 'KS Rank 6',
				desc = 'Number of kills to reach Rank 6',
				width = "full",
				get = function() return dgks.db.profile.ksrank[6] end,
				set = function(info, v)	dgks.db.profile.ksrank[6] = v end,
				min = -1,
				max = 50,
				step = 1
			},
			ksrank7 = {
				type = 'range',
				name = 'KS Rank 7',
				desc = 'Number of kills to reach Rank 7',
				width = "full",
				get = function() return dgks.db.profile.ksrank[7] end,
				set = function(info, v)	dgks.db.profile.ksrank[7] = v end,
				min = -1,
				max = 50,
				step = 1
			}
		}
	}
	return ranks
end

function giveSoundFileSetup()
	local soundfilesetup = {
		type = "group",
		name = "Sound File Setup",
		desc = "For setting up custom sounds only",
		args = {
			resetkssound = {
				type = 'execute',
				width = "full",
				name = 'Reset to default files',
				func = function() dgks.db.profile.kssound = dgks.db.defaults.profile.kssound end,
			},
			kssound1 = {
				type = 'input',
				name = 'KS Sound 1',
				desc = 'Choose a sound file',
				usage = "End the name of a sound file",
				get = function()
					return dgks.db.profile.kssound[1]
				end,
				set = function(info, v)
					dgks.db.profile.kssound[1] = v
				end
			},
			kssound2 = {
				type = 'input',
				name = 'KS Sound 2',
			desc = 'Choose a sound file',
				usage = "End the name of a sound file",
				get = function()
				return dgks.db.profile.kssound[2]
					end,
				set = function(info, v)
					dgks.db.profile.kssound[2] = v
				end
				},
			kssound3 = {
				type = 'input',
				name = 'KS Sound 3',
				desc = 'Choose a sound file',
				usage = "End the name of a sound file",
				get = function()
					return dgks.db.profile.kssound[3]
				end,
				set = function(info, v)
					dgks.db.profile.kssound[3] = v
				end
			},
			kssound4 = {
				type = 'input',
				name = 'KS Sound 4',
				desc = 'Choose a sound file',
				usage = "End the name of a sound file",
				get = function()
					return dgks.db.profile.kssound[4]
				end,
				set = function(info, v)
					dgks.db.profile.kssound[4] = v
				end
			},
			kssound5 = {
				type = 'input',
				name = 'KS Sound 5',
				desc = 'Choose a sound file',
				usage = "End the name of a sound file",
				get = function()
					return dgks.db.profile.kssound[5]
				end,
				set = function(info, v)
					dgks.db.profile.kssound[5] = v
				end
			},
			kssound6 = {
				type = 'input',
				name = 'KS Sound 6',
				desc = 'Choose a sound file',
				usage = "End the name of a sound file",
				get = function()
					return dgks.db.profile.kssound[6]
				end,
				set = function(info, v)
					dgks.db.profile.kssound[6] = v
				end
			},
			kssound7 = {
				type = 'input',
				name = 'KS Sound 7',
				desc = 'Choose a sound file',
				usage = "End the name of a sound file",
				get = function()
					return dgks.db.profile.kssound[7]
				end,
				set = function(info, v)
					dgks.db.profile.kssound[7] = v
				end
			}
		}
	}
	return soundfilesetup
end

local function giveOutput()
	local output = {
		name = "Combat Message Output",
		type = "group",
		args = {
			desc = {
				type = "description",
				name = "You can select where you want dG Killshot Combat messages displayed from this screen.",
				order = 0
			},
			sink = dgks:GetSinkAce3OptionsDataTable(),
		}
	}
	-- hacks borrowed from Witch Hunt
	output.args.sink.order = 1
	output.args.sink.inline = true
	output.args.sink.name = ""
	return output
end

local defaults = {
	profile = {
		maxkillingstreak = 0,
		maxdeathstreak = 0,
		ksemote = "has killed $v! Streak of $s!",
		kstext = "$k killed $v!",
		soundpack = "male", -- need this to check for available packs and create a drag down option
		soundpath = "Interface\\AddOns\\dgks\\sounds\\male\\",
		doemote = true,
		docombattext = true,
		dobroadcasts = true,
		doguild = false,
		doraid = true,
		dosound = true,
		dozonechange = true,
		ksrank = {0, 2, 4, 6, 8, 10, 12},
		kssound = {"ownage.ogg", "killingspree.ogg", "rampage.ogg", "dominating.ogg", "unstoppable.ogg", "godlike.ogg", "whickedsick.ogg"},
		kssoundM = {"doublekill.ogg", "multikill.ogg", "megakill.ogg", "ultrakill.ogg", "monsterkill.ogg", "ludicrouskill.ogg", "holyshit.ogg"},
		kstextM = {"DOUBLEKILL!", "MULTIKILL!", "MEGAKILL!", "ULTRAKILL!!!", "MONSTERKILL!!!", "LUDICROUSKILL!!!", "H O L Y  S H I T!!!"},
		killlog = {},
		--Currently unused might be readded for dueling and ranged slot kills
		--kssoundH = "humiliation.wav";	
		sink20Sticky = true,
		sink20OutputSink = Default,
		sink20ScrollArea = Outgoing,
	},
}

function dgks:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("dgksDB", defaults, "Default")
	
	self:SetSinkStorage(self.db.profile)
	
	local acreg = LibStub("AceConfigRegistry-3.0")
	
	acreg:RegisterOptionsTable("dG KillShot", giveOptions)
	acreg:RegisterOptionsTable("dG KillShot General", giveGeneral)
	acreg:RegisterOptionsTable("dG KillShot Broadcasts", giveBroadcasts)
	acreg:RegisterOptionsTable("dG KillShot Profiles", giveProfiles)
	acreg:RegisterOptionsTable("dG KillShot Ranks", giveRanks)
	acreg:RegisterOptionsTable("dG KillShot File Setup", giveSoundFileSetup)
	acreg:RegisterOptionsTable("dG KillShot Output", giveOutput)	
	
	local acdia = LibStub("AceConfigDialog-3.0")
	
	acdia:AddToBlizOptions("dG KillShot", "dG KillShot")
	acdia:AddToBlizOptions("dG KillShot General", "General", "dG KillShot")
	acdia:AddToBlizOptions("dG KillShot Broadcasts", "Broadcasts", "dG KillShot")
	acdia:AddToBlizOptions("dG KillShot Profiles", "Profiles", "dG KillShot")
	acdia:AddToBlizOptions("dG KillShot Ranks", "Ranks", "dG KillShot")
	acdia:AddToBlizOptions("dG KillShot File Setup", "Sound File Setup", "dG KillShot")
	acdia:AddToBlizOptions("dG KillShot Output", "Combat Text Output", "dG KillShot")
	
	self:RegisterChatCommand("dgks", function() InterfaceOptionsFrame_OpenToCategory("dG KillShot") end)
	self:RegisterChatCommand("ks", function() InterfaceOptionsFrame_OpenToCategory("dG KillShot") end)
end

function dgks:dgks_SoundPack(sound)
	if not sound then
		sound = 1
	end

	local soundfile = self.db.profile.soundpath .. sound
	self:SoundEventHandler(soundfile)
end

function dgks:OnDisable()
    -- Called when the addon is disabled
end

function dgks:ZoneChangedHandler()
	if (dgks.db.profile.dozonechange) then
		killingstreak = 0;
		deathstreak = 0;
	end
end

function dgks:AddonMessageHandler(info, prefix, text, type, target)
	-- If broadcasts are enabled handle them
	if (dgks.db.profile.dobroadcasts) then
		-- Make sure the broadcast is not from ourself
		if not (target == myPlayerName) then
			if (prefix == "dgks_txt") then
				dgks:Print(text);
			elseif (prefix == "dgks_ScrollingTextEvent") then
				dgks:ScrollText(text);
			elseif (prefix == "dgks_KillSoundEvent") then
				dgks:dgks_SoundPack(dgks:GetKillshotSound(tonumber(text)))
			elseif (prefix == "dgks_GuildScrollingTextEvent") then
				if (dgks.db.profile.doguild) then
					if not (UnitInParty(target) or UnitInRaid(target)) then
						dgks:ScrollText(text)
					end
				end
		        elseif (prefix == "dgks_GuildKillSoundEvent") then
				if (dgks.db.profile.doguild) then
					if not (UnitInParty(target) or UnitInRaid(target)) then
						dgks:dgks_SoundPack(dgks:GetKillshotSound(tonumber(text)))
					end
				end
			elseif (prefix == "dgks_KilledSoundEvent") then
				dgks:dgks_SoundPack("humiliation.wav");
			elseif (prefix == "dgks_BGVersionCheckRequest" or prefix == "dgks_RaidVersionCheckRequest" or prefix == "dgks_GuildVersionCheckRequest") then
				dgks:dgks_SendVersionResponse(text);
			elseif (prefix == "dgks_VersionCheckResponse") then
				local startPos, endPos, respondee, text = string.find(text, "(%w+)[%s%p]*(.*)")
				dgks:Print(text);
			end
		end
	end
end


function dgks:CombatLogEventHandler(info, timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, param9, param10, param11, param12, param13)
	-- Cleanup any nil events so there is no chance of the if statements throwing errors
	if (event == nil) then return end
	if (event == "PARTY_KILL") then
		-- A party member has killed something, as far as I can tell this does not include party pets
		if (destFlags == nil) then return end
		if (bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER) then
				-- A player has died to someone in our party
				if (sourceFlags == nil) then return end
				if (bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then
					if (destName == nil) then return end
					-- Player has landed a killing blow
					self:Killshot(myPlayerName, destName, timestamp)
				end
		end
	elseif (event == "UNIT_DIED") then
		if (destName == nil) then return end
		if (destName == myPlayerName) then
			-- Player has died
			self:PlayerDeath(lastDamageDealer)
		end
	elseif (string.find(event, "_DAMAGE")) then
		-- A damage event
		if (destName == nil) then return end
		if (destName == myPlayerName) then 
			-- Player has been damaged get there name in case of Player death
			lastDamageDealer = sourceName
		end
	
	end

	-- *** Alternate detection method to fix pet kills, does not funciton well ***--
	-- Make sure this is a _DAMAGE event
	--if (string.find(event, "_DAMAGE")) then
	--	-- Check for overkill param
	--	if ((param10 ~= 0 and param13 == nil) or (param13 ~= 0 and param13 ~= nil)) then
	--		-- See if we are pitching or catchin
	--		if (bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then
	--			-- We are pitching lets make sure a player is catching
	--			if (bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER) then
	--				-- We have a killshot
	--				self:Killshot(myPlayerName, destName, timestamp)
	--			end
	--		elseif (destName == myPlayerName and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER) then
	--			-- FIXME This will not detect players name if killed by a players pet
	--			-- We are catching lets see if a player is pitching
	--			if (bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER) then
	--				-- We have been ganked
	--				self:PlayerDeath(sourceName)
	--			end
	--		end
	--		-- Doesn't involve us
	--	end
	--*** *** --
	-- FIXME Add some sort of check incase overkill is 0 and a player dies
end

function dgks:Killshot(killer, victim, timestamp)
	-- Increment killingstreak and add to max if its a new record
	killingstreak = killingstreak + 1
	if ( killingstreak > dgks.db.profile.maxkillingstreak ) then 
		dgks.db.profile.maxkillingstreak = killingstreak
	end
	deathstreak = 0

	if (dgks.db.profile.doemote) then
		emotestring=string.gsub(string.gsub(dgks.db.profile.ksemote, "$v", victim), "$s", killingstreak)
		SendChatMessage(emotestring, "EMOTE")
	end

	killshottext = string.gsub(string.gsub(dgks.db.profile.kstext, "$k", killer), "$v", victim)
	dgks:ScrollText(killshottext)
	SendAddonMessage("dgks_ScrollingTextEvent", killshottext, dgks:GetMessageGroup());
	if (dgks.db.profile.doguild) then SendAddonMessage("dgks_GuildScrollingTextEvent", killshottext, "GUILD") end
	-- Check for multikill, kill must be no more than 10 seconds from last kill
	if((lastkill + 10) > timestamp) then
		-- Ladies and Gentlemen we have a multikill
		multikill = multikill + 1;
		-- This most like will never be used except in test mode, but lets prevent the error anyways
		if (multikill > table.maxn(self.db.profile.kstextM)) then multikill = table.maxn(self.db.profile.kstextM); end;
		dgks:ScrollText(killer .. " got a " .. self.db.profile.kstextM[multikill] .. "!");
		--If broadcasts are enabled
		if (dgks.db.profile.dobroadcasts) then
			SendAddonMessage("dgks_ScrollingTextEvent", killer .. " got a " .. self.db.profile.kstextM[multikill] .. "!", dgks:GetMessageGroup());
			SendAddonMessage("dgks_KillSoundEvent", killingstreak, dgks:GetMessageGroup());
			if (dgks.db.profile.doguild) then
				SendAddonMessage("dgks_GuildScrollingTextEvent", killer .. " got a " .. self.db.profile.kstextM[multikill] .. "!", "GUILD")
				SendAddonMessage("dgks_GuildKillSoundEvent", killingstreak, "GUILD");
			end
		end
		dgks:dgks_SoundPack(self.db.profile.kssoundM[multikill]);
	else 
		multikill = 0
		if (dgks.db.profile.dobroadcasts) then
			SendAddonMessage("dgks_KillSoundEvent", killingstreak, dgks:GetMessageGroup())
			if (dgks.db.profile.doguild) then SendAddonMessage("dgks_GuildKillSoundEvent", killingstreak, "GUILD") end
			dgks:dgks_SoundPack(dgks:GetKillshotSound(killingstreak))
		end
	end
	lastkill = timestamp
end

function dgks:PlayerDeath(mykiller)
	killingstreak = 0;
	deathstreak = deathstreak + 1;
	if (deathstreak > dgks.db.profile.maxdeathstreak) then dgks.db.profile.maxdeathstreak = deathstreak end
	if (mykiller == nil) then mykiller = "Unknown Entity" end
        tinsert(dgks.db.profile.killlog, 1, "[" .. date() .. "]" .. " You were killed by " .. mykiller .. ".")
         if (dgks.db.profile.killlog[26]) then tremove(dgks.db.profile.killlog,26) end
end

function dgks:GetKillshotSound(killingstreak)
	for x = 7, 1, -1 do
		if (dgks.db.profile.ksrank[x] > -1) and (killingstreak >= dgks.db.profile.ksrank[x]) then return dgks.db.profile.kssound[x]; end
	end  
    --If we get here the user has messed up their config we could build some sort of safety someday but for now we will just default to kssound 1
	return self.db.profile.kssound[1]
end

function dgks:ScrollText(msg)
	if (dgks.db.profile.docombattext) then
		dgks.Pour(dgks, msg, 1.0, 0.1, 0.1)
		tinsert(dgks.db.profile.killlog, 1, "[" .. date() .. "] " .. msg)
		if (dgks.db.profile.killlog[21]) then tremove(dgks.db.profile.killlog,21) end
	end
end

function dgks:dgks_SendVersionResponse(requester)
    SendAddonMessage("dgks_VersionCheckResponse", requester .. ":" .. myPlayerName .. " is on version " .. version , "WHISPER", requester);
end

function dgks:CheckBGVersions()
    SendAddonMessage("dgks_BGVersionCheckRequest", myPlayerName, "BATTLEGROUND");
    dgks:Print(myPlayerName .. " is on version " .. version);
end

function dgks:CheckGuildVersions()
    SendAddonMessage("dgks_GuildVersionCheckRequest", myPlayerName, "GUILD");
    dgks:Print(myPlayerName .. " is on version " .. version);
end

function dgks:CheckRaidVersions()
    SendAddonMessage("dgks_RaidVersionCheckRequest", myPlayerName, "RAID");
    dgks:Print(myPlayerName .. " is on version " .. version);
end

function dgks:getSoundPack()
    return self.db.profile.soundpack;
end

function dgks:setSoundPack(info, newsoundset)
	local soundPaths = {
		male = "Interface\\AddOns\\dgks\\sounds\\male\\",
		female = "Interface\\AddOns\\dgks\\sounds\\female\\",
		sexy = "Interface\\AddOns\\dgks\\sounds\\sexy\\",
		baby = "Interface\\AddOns\\dgks\\sounds\\baby\\"
	}

	local soundpath = soundPaths[newsoundset]
	if soundpath then
		self.db.profile.soundpack = newsoundset
		self.db.profile.soundpath = soundpath
	else
		message("Error: That is not a valid option")
	end
end

function dgks:GetMessageGroup()
    local targetGroup = "RAID";
    local zone = GetZoneText();
    if ((zone == "Dalaran Arena") or (zone ==  "Nagrand Arena") or (zone == "Blade's Edge Arena") or (zone == "The Ring of Valor") or (zone == "Ruins of Lordaeron") or (zone == "Warsong Gulch") or (zone == "Eye of the Storm") or (zone == "Arathi Basin") or (zone == "Alterac Valley") or (zone == "Strand of the Ancients")) then
        targetGroup = "BATTLEGROUND";
    end
    return targetGroup;
end

function dgks:getKillLog()
	local plog = ""
	table.foreach(dgks.db.profile.killlog, function(k,v) plog = plog .. v .. "\n" end)
	return plog
end

function dgks:OnEnable()
	self:RegisterEvent("CHAT_MSG_ADDON", "AddonMessageHandler")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatLogEventHandler")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ZoneChangedHandler")
	self:RegisterEvent("SoundEvent", "SoundEventHandler")
end
