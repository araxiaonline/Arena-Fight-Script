-- Setesh boss made for Azerothcore Araxia Online by Manmadedrummer

local BOSS_SETESH = 700814
local NPC_VOID_CALLER = 18368
local NPC_VOID_SENTINEL = 18870
local SPELL_CHAOS_BOLT = 71108
local SPELL_CHAOS_BLAST = 37675
local SPELL_SEED_OF_CHAOS = 70388
local SPELL_SHADOW_NOVA = 71106
local CHAOS_BOLT_TIMER = 15000
local CHAOS_BLAST_TIMER = 20000
local SEED_OF_CHAOS_TIMER = 25000
local VOID_CALLER_SPAWN_TIMER = 45000
local VOID_SENTINEL_SPAWN_TIMER = 55000
local SETESH_HEALTH = 151695

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function SummonVoidCaller(eventId, delay, calls, creature)
    local x, y, z, o = creature:GetLocation()
    creature:SpawnCreature(NPC_VOID_CALLER, x + math.random(-5, 5), y + math.random(-5, 5), z, o, 3, 60000)
end

local function SummonVoidSentinel(eventId, delay, calls, creature)
    local x, y, z, o = creature:GetLocation()
    creature:SpawnCreature(NPC_VOID_SENTINEL, x + math.random(-5, 5), y + math.random(-5, 5), z, o, 3, 60000)
end

local function CastChaosBolt(eventId, delay, calls, creature)
    local target = creature:GetAITarget(0, true)
    if target then
        creature:CastSpell(target, SPELL_CHAOS_BOLT, true)
    end
end

local function CastChaosBlast(eventId, delay, calls, creature)
    local target = creature:GetAITarget(0, true)
    if target then
        creature:CastSpell(target, SPELL_CHAOS_BLAST, true)
    end
end

local function CastSeedOfChaos(eventId, delay, calls, creature)
    local target = creature:GetAITarget(0, true)
    if target then
        creature:CastSpell(target, SPELL_SEED_OF_CHAOS, true)
    end
end

local function CastShadowNova(eventId, delay, calls, creature)
    creature:CastSpell(creature, SPELL_SHADOW_NOVA, true)
end

local function OnEnterCombat(event, creature, target)
    creature:SendUnitYell("The chaos will consume you all!", 0)
    creature:SetMaxHealth(SETESH_HEALTH)
    creature:SetHealth(SETESH_HEALTH)
    creature:RegisterEvent(CastChaosBolt, CHAOS_BOLT_TIMER, 0)
    creature:RegisterEvent(CastChaosBlast, CHAOS_BLAST_TIMER, 0)
    creature:RegisterEvent(CastSeedOfChaos, SEED_OF_CHAOS_TIMER, 0)
    creature:RegisterEvent(CastShadowNova, 30000, 0)
    creature:RegisterEvent(SummonVoidCaller, VOID_CALLER_SPAWN_TIMER, 0)
    creature:RegisterEvent(SummonVoidSentinel, VOID_SENTINEL_SPAWN_TIMER, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

RegisterCreatureEvent(BOSS_SETESH, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_SETESH, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_SETESH, 4, OnDeath)
