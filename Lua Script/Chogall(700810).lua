-- Cho'gall Script for AzerothCore Araxia Online by Manmadedrummer

local BOSS_CHOGALL = 700810
local NPC_CORRUPTING_ADHERENT = 38394
local NPC_DARKENED_CREATION = 15802
local SPELL_TWISTED_DEVOTION = 58845
local SPELL_FURY_OF_CHOGALL = 50078
local SPELL_FLAME_ORDERS = 58936
local SPELL_SHADOW_ORDERS = 71106
local SPELL_CORRUPTION_OLD_GOD = 72319
local CONVERSION_TIMER = 30000
local FURY_TIMER = 15000
local FLAME_ORDERS_TIMER = 45000
local SHADOW_ORDERS_TIMER = 45000
local ADHERENT_TIMER = 40000
local RANDOM_QUOTE_TIMER = 45000
local STAGE_TWO_HEALTH = 25
local phase = 1
local spawnedCreatures = {}

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function CastTwistedDevotion(eventId, delay, calls, creature)
    local target = creature:GetAITarget(1)
    if target then
        creature:CastSpell(target, SPELL_TWISTED_DEVOTION, true)
    end
end

local function CastFuryOfChogall(eventId, delay, calls, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_FURY_OF_CHOGALL, true)
    end
end

local function CastFlameOrders(eventId, delay, calls, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_FLAME_ORDERS, true)
    end
end

local function CastShadowOrders(eventId, delay, calls, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_SHADOW_ORDERS, true)
    end
end

local function SummonCorruptingAdherent(eventId, delay, calls, creature)
    local x, y, z, o = creature:GetLocation()
    local adherent = creature:SpawnCreature(NPC_CORRUPTING_ADHERENT, x + math.random(-5, 5), y + math.random(-5, 5), z, o, 3, 60000)
    if adherent then
        table.insert(spawnedCreatures, adherent)
    end
end

local function SummonDarkenedCreation(eventId, delay, calls, creature)
    creature:SendUnitYell("Feel The Power of the Nexus!", 0)
    local x, y, z, o = creature:GetLocation()
    local tentacle = creature:SpawnCreature(NPC_DARKENED_CREATION, x + math.random(-5, 5), y + math.random(-5, 5), z, o, 3, 60000)
    if tentacle then
        table.insert(spawnedCreatures, tentacle)
    end
end

local function CastCorruptionOldGod(eventId, delay, calls, creature)
    creature:CastSpell(creature, SPELL_CORRUPTION_OLD_GOD, true)
end

local function PlayRandomVoiceLine(eventId, delay, calls, creature)
    local soundId = SOUND_RANDOM_QUOTES[math.random(#SOUND_RANDOM_QUOTES)]
    creature:SendUnitYell(soundId, 0)
end

local function StartPhaseOne(creature)
    creature:RegisterEvent(CastTwistedDevotion, CONVERSION_TIMER, 0)
    creature:RegisterEvent(CastFuryOfChogall, FURY_TIMER, 0)
    creature:RegisterEvent(CastFlameOrders, FLAME_ORDERS_TIMER, 0)
    creature:RegisterEvent(CastShadowOrders, SHADOW_ORDERS_TIMER, 0)
    creature:RegisterEvent(SummonCorruptingAdherent, ADHERENT_TIMER, 0)
    creature:RegisterEvent(PlayRandomVoiceLine, RANDOM_QUOTE_TIMER, 0)
end

local function CheckHealth(eventId, delay, calls, creature)
    if creature:GetHealthPct() <= STAGE_TWO_HEALTH and phase == 1 then
        phase = 2
        creature:RemoveEvents()
        creature:RegisterEvent(CastFuryOfChogall, FURY_TIMER, 0)
        creature:RegisterEvent(CastCorruptionOldGod, 2000, 0)
        creature:RegisterEvent(SummonDarkenedCreation, 15000, 0)
    end
end

local function OnEnterCombat(event, creature, target)
    phase = 1
    creature:SetMaxHealth(1087944)
    creature:SetHealth(1087944)
    StartPhaseOne(creature)
    creature:RegisterEvent(CheckHealth, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDied(event, creature, killer)
    creature:RemoveEvents()
    for _, spawnedCreature in ipairs(spawnedCreatures) do
        if spawnedCreature and spawnedCreature:IsAlive() then
            spawnedCreature:DespawnOrUnsummon()
        end
    end
    spawnedCreatures = {}
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(BOSS_CHOGALL, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_CHOGALL, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_CHOGALL, 4, OnDied)
