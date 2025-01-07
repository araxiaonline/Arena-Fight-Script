--Ozruk boss made for Azerothcore Araxia Online Manmadedrummer
local BOSS_OZRUK = 700812  -- Ozruk's NPC ID
local STAGE_TWO_HEALTH = 25  -- Transition to Phase 2 at 25% health
local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404  -- Teleport location for players

local SPELL_GROUND_SLAM = 62625
local SPELL_RUPTURE = 15583
local SPELL_ELEMENTIUM_BULWARK = 3651
local SPELL_SPIKE_SHIELD = 70435
local SPELL_SHATTER = 62388
local SPELL_PARALYZE = 48278

local QUOTE_AGGRO = "None may pass into the World's Heart!"
local QUOTE_SPIKE_SHIELD = "Break yourselves upon my body. Feel the strength of the earth!"
local QUOTE_KILL = "The cycle is complete."
local QUOTE_DEATH = "A protector has fallen. The World's Heart lies exposed!"

local function CastGroundSlam(eventId, delay, repeats, creature)
    creature:CastSpell(creature:GetVictim(), SPELL_GROUND_SLAM, true)
end

local function CastRupture(eventId, delay, repeats, creature)
    creature:CastSpell(creature:GetVictim(), SPELL_RUPTURE, true)
end

local function CastElementiumBulwark(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_ELEMENTIUM_BULWARK, true)
    creature:SendUnitYell(QUOTE_SPIKE_SHIELD, 0)
end

local function CastSpikeShield(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_SPIKE_SHIELD, true)
end

local function CastShatter(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_SHATTER, true)
end

local function CastParalyze(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_PARALYZE, true)
end

local function Phase1(creature)
    creature:RegisterEvent(CastGroundSlam, 10000, 0)
    creature:RegisterEvent(CastRupture, 20000, 0)
    creature:RegisterEvent(CastElementiumBulwark, 25000, 0)
end

local function Phase2(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("I will not be broken!", 0)
    creature:RegisterEvent(CastShatter, 12000, 0)
    creature:RegisterEvent(CastSpikeShield, 15000, 0)
    creature:RegisterEvent(CastParalyze, 30000, 0)
end

local function OnCombat(event, creature, target)
    creature:SetMaxHealth(766800)
    creature:SetHealth(766800)
    creature:SendUnitYell(QUOTE_AGGRO, 0)
    Phase1(creature)
    creature:RegisterEvent(function(eventId, delay, repeats, creature)
        if creature:GetHealthPct() < STAGE_TWO_HEALTH then
            Phase2(creature)
        end
    end, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnKilledTarget(event, creature, victim)
    creature:SendUnitYell(QUOTE_KILL, 0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell(QUOTE_DEATH, 0)
    creature:RemoveEvents()

    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        if player:IsPlayer() then
            player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
        end
    end
end

RegisterCreatureEvent(BOSS_OZRUK, 1, OnCombat)
RegisterCreatureEvent(BOSS_OZRUK, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_OZRUK, 3, OnKilledTarget)
RegisterCreatureEvent(BOSS_OZRUK, 4, OnDeath)
