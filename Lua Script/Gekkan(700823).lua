-- Gekkan boss script made by Manmadedrummer for Araxia Online

local BOSS_GEKKAN = 700823
local MAX_HEALTH = 1151695
local SPELL_INSPIRING_CRY = 64062
local SPELL_IRON_PROTECTOR = 41431
local SPELL_SHANK = 15617
local SPELL_CLEANSING_FLAME = 18432
local SPELL_FIRE_BOLT = 71130
local SPELL_HEX = 67534
local SPELL_DARK_BOLT = 72504
local SPELL_ENRAGE = 72148
local SPELL_CAST_INTERVAL = 3000

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function CastRandomSpell(creature)
    local spells = {
        SPELL_IRON_PROTECTOR,
        SPELL_SHANK,
        SPELL_CLEANSING_FLAME,
        SPELL_FIRE_BOLT,
        SPELL_HEX,
        SPELL_DARK_BOLT
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

local function CheckHealthForEnrage(eventId, delay, calls, creature)
    if creature:GetHealthPct() <= 10 then
        creature:RemoveEvents()
        creature:CastSpell(creature, SPELL_ENRAGE, true)
    end
end

local function OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Slay them!", 0)
    creature:RegisterEvent(RandomSpellCasting, SPELL_CAST_INTERVAL, 0)
    creature:RegisterEvent(CheckHealthForEnrage, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:RemoveEvents()
    creature:SendUnitYell("Such a waste...", 0)
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

local function OnSpawn(event, creature)
    creature:SetMaxHealth(MAX_HEALTH)
    creature:SetHealth(MAX_HEALTH)
end

RegisterCreatureEvent(BOSS_GEKKAN, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_GEKKAN, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_GEKKAN, 4, OnDeath)
RegisterCreatureEvent(BOSS_GEKKAN, 5, OnSpawn)
