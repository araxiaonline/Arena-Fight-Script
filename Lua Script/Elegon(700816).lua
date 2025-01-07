-- Elegon boss made for Azerothcore Araxia Online by Manmadedrummer

local BOSS_ELEGON = 700816
local NPC_COSMIC_SPARK = 17283
local SPELL_CELESTIAL_BREATH = 61079
local SPELL_DESTABILIZING_ENERGIES = 57058
local SPELL_GRASPING_ENERGY_TENDRILS = 57604
local SPELL_RADIATING_ENERGIES = 72039
local SPELL_ENERGY_CASCADE = 58531
local SUMMON_SPARK_5_TIMER = 30000
local SUMMON_SPARK_3_TIMER = 45000
local PHASE_2_HEALTH = 50
local spawnedCreatures = {}

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local SPELLS = {
    SPELL_CELESTIAL_BREATH,
    SPELL_DESTABILIZING_ENERGIES,
    SPELL_GRASPING_ENERGY_TENDRILS,
    SPELL_RADIATING_ENERGIES,
    SPELL_ENERGY_CASCADE
}

local function CastRandomSpell(creature)
    local randomSpell = SPELLS[math.random(1, #SPELLS)]
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, randomSpell, true)
    end
end

local function RandomSpellCasting(eventId, delay, calls, creature)
    CastRandomSpell(creature)
    creature:RegisterEvent(RandomSpellCasting, math.random(5000, 15000), 1)
end

local function Summon5CosmicSparks(eventId, delay, calls, creature)
    for i = 1, 5 do
        local x, y, z, o = creature:GetLocation()
        creature:SpawnCreature(NPC_COSMIC_SPARK, x + math.random(-5, 5), y + math.random(-5, 5), z, o, 3, 60000)
    end
end

local function Summon3CosmicSparks(eventId, delay, calls, creature)
    for i = 1, 3 do
        local x, y, z, o = creature:GetLocation()
        creature:SpawnCreature(NPC_COSMIC_SPARK, x + math.random(-5, 5), y + math.random(-5, 5), z, o, 3, 60000)
    end
end

local function CheckHealth(eventId, delay, calls, creature)
    local healthPct = creature:GetHealthPct()
    if healthPct <= PHASE_2_HEALTH then
        creature:RemoveEventById(eventId)
        creature:RegisterEvent(Summon5CosmicSparks, SUMMON_SPARK_5_TIMER, 0)
        creature:RegisterEvent(Summon3CosmicSparks, SUMMON_SPARK_3_TIMER, 0)
    end
end

local function OnEnterCombat(event, creature, target)
    creature:SetMaxHealth(876581)
    creature:SetHealth(876581)
    creature:RegisterEvent(RandomSpellCasting, math.random(5000, 15000), 0)
    creature:RegisterEvent(CheckHealth, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("Existence ends... I become nothing...", 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(BOSS_ELEGON, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_ELEGON, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_ELEGON, 4, OnDeath)
