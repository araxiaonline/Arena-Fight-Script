-- Therazane for AzerothCore Araxia Online by Manmadedrummer

local BOSS_THERAZANE = 700815
local SPELL_GROUND_SLAM = 62625
local SPELL_UNSTABLE_EARTH_NOVA = 68902
local SPELL_EARTHQUAKE = 64697
local SPELL_ROCK_SHOWER = 60923
local SPELL_STOMP = 71115
local SPELL_GROUND_SPIKE = 59750
local SPELL_ROCK_RUMBLE = 38777
local SPELL_ROCK_SHARDS = 60884
local SPELL_CAST_INTERVAL = math.random(5000, 10000)

local function CastRandomSpell(creature)
    local spells = {
        SPELL_GROUND_SLAM,
        SPELL_UNSTABLE_EARTH_NOVA,
        SPELL_EARTHQUAKE,
        SPELL_ROCK_SHOWER,
        SPELL_STOMP,
        SPELL_GROUND_SPIKE,
        SPELL_ROCK_RUMBLE,
        SPELL_ROCK_SHARDS
    }
    local randomSpell = spells[math.random(1, #spells)]
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, randomSpell, true)
    end
end

local function RandomSpellCasting(eventId, delay, calls, creature)
    CastRandomSpell(creature)
end

local function OnEnterCombat(event, creature, target)
    creature:SetMaxHealth(630000)
    creature:SetHealth(630000)
    creature:SendUnitYell("You will crumble beneath me!", 0)
    creature:RegisterEvent(RandomSpellCasting, SPELL_CAST_INTERVAL, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:SendUnitYell("You cannot escape my wrath!", 0)
    creature:DespawnOrUnsummon(0)
end

local function OnKilledTarget(event, creature, victim)
    creature:SendUnitYell("Another victim crushed!", 0)
end

local function OnDeath(event, creature, killer)
    creature:RemoveEvents()
    creature:SendUnitYell("Defeated... but never destroyed...", 0)
    creature:DespawnOrUnsummon(0)

    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, 2204.453125, -4794.402344, 64.998360, 1.033404)
    end
end

RegisterCreatureEvent(BOSS_THERAZANE, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_THERAZANE, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_THERAZANE, 3, OnKilledTarget)
RegisterCreatureEvent(BOSS_THERAZANE, 4, OnDeath)
