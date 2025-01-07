-- Lord of Terror (Diablo Inspired) for AzerothCore by Manmadedrummer

local ENEMY_ID = 700806
local SPELL_SHADOW_FLAME = 22993
local SPELL_TERROR_ROAR = 39048
local SPELL_GROUND_STOMP = 7139
local SPELL_SUMMON_IMP = 12922
local SPELL_FIRE_WALL = 43114
local SPELL_LIGHTNING_BREATH = 59963
local SPELL_ENRAGE = 72148
local SPELL_APOCALYPSE = 53210

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function CastShadowFlame(eventId, delay, repeats, creature)
    creature:CastSpell(creature:GetVictim(), SPELL_SHADOW_FLAME, true)
end

local function CastTerrorRoar(eventId, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, SPELL_TERROR_ROAR, true)
    end
end

local function CastGroundStomp(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_GROUND_STOMP, true)
end

local function SummonImps(creature)
    for i = 1, 3 do
        local x, y, z = creature:GetLocation()
        creature:SpawnCreature(SPELL_SUMMON_IMP, x + math.random(-5, 5), y + math.random(-5, 5), z, 0, 3, 60000)
    end
end

local function CastFireWall(eventId, delay, repeats, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_FIRE_WALL, true)
    end
end

local function CastLightningBreath(eventId, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, SPELL_LIGHTNING_BREATH, true)
    end
end

local function CastApocalypse(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_APOCALYPSE, true)
end

local function Phase1(creature)
    creature:RegisterEvent(CastShadowFlame, 8000, 0)
    creature:RegisterEvent(CastTerrorRoar, 15000, 0)
    creature:RegisterEvent(CastGroundStomp, 20000, 0)
end

local function Phase2(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("You cannot escape the flames of Hell!", 0)
    SummonImps(creature)
    creature:RegisterEvent(CastFireWall, 10000, 0)
    creature:RegisterEvent(CastLightningBreath, 12000, 0)
    creature:RegisterEvent(CastGroundStomp, 20000, 0)
    Phase1(creature)
end

local function Phase3(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("Feel my wrath! The end is near!", 0)
    creature:CastSpell(creature, SPELL_ENRAGE, true)
    creature:RegisterEvent(CastApocalypse, 15000, 0)
    creature:RegisterEvent(CastFireWall, 10000, 0)
    creature:RegisterEvent(CastLightningBreath, 12000, 0)
    Phase1(creature)
end

local function OnCombat(event, creature, target)
    creature:SendUnitYell("I am the Lord of Terror! You dare challenge me?", 0)
    Phase1(creature)
    creature:RegisterEvent(function(eventId, delay, repeats, creature)
        if creature:GetHealthPct() < 50 then
            Phase2(creature)
        elseif creature:GetHealthPct() < 20 then
            Phase3(creature)
        end
    end, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnKilledTarget(event, creature, victim)
    creature:SendUnitYell("Another soul claimed by the Lord of Terror!", 0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("No! This is not... the end...", 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(ENEMY_ID, 1, OnCombat)
RegisterCreatureEvent(ENEMY_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(ENEMY_ID, 3, OnKilledTarget)
RegisterCreatureEvent(ENEMY_ID, 4, OnDeath)
