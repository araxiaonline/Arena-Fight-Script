-- Argaloth made for Azerothcore Araxia Online by Manmadedrummer

local BOSS_ARGALOTH = 700813
local HEALTH_PHASE_2 = 66
local HEALTH_PHASE_3 = 33
local BERSERK_TIMER = 300000
local SPELL_METEOR_SLASH = 45150
local SPELL_CONSUMING_DARKNESS = 68089
local SPELL_FEL_FIRESTORM = 500095
local SPELL_BERSERK = 68378
local METEOR_SLASH_TIMER = 15000
local CONSUMING_DARKNESS_TIMER = 20000
local FEL_FIRESTORM_TIMER = 60000
local phase = 1

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function CastMeteorSlash(eventId, delay, calls, creature)
    local targets = creature:GetAITargets(65)
    for _, target in ipairs(targets) do
        creature:CastSpell(target, SPELL_METEOR_SLASH, true)
    end
end

local function CastConsumingDarkness(eventId, delay, calls, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, SPELL_CONSUMING_DARKNESS, true)
    end
end

local function CastFelFirestorm(creature)
    creature:SendUnitYell("The flames of destruction will consume you!", 0)
    creature:CastSpell(creature, SPELL_FEL_FIRESTORM, true)
end

local function CastBerserk(eventId, delay, calls, creature)
    creature:CastSpell(creature, SPELL_BERSERK, true)
    creature:SendUnitYell("Your time has run out!", 0)
end

local function Phase1(creature)
    creature:RegisterEvent(CastMeteorSlash, METEOR_SLASH_TIMER, 0)
    creature:RegisterEvent(CastConsumingDarkness, CONSUMING_DARKNESS_TIMER, 0)
end

local function Phase2(event, delay, calls, creature)
    creature:RemoveEvents()
    CastFelFirestorm(creature)
    Phase1(creature)
end

local function Phase3(event, delay, calls, creature)
    creature:RemoveEvents()
    CastFelFirestorm(creature)
    Phase1(creature)
end

local function CheckHealth(eventId, delay, calls, creature)
    local healthPct = creature:GetHealthPct()
    if phase == 1 and healthPct <= HEALTH_PHASE_2 then
        phase = 2
        Phase2(eventId, delay, calls, creature)
    elseif phase == 2 and healthPct <= HEALTH_PHASE_3 then
        phase = 3
        Phase3(eventId, delay, calls, creature)
    end
end

local function OnEnterCombat(event, creature, target)
    phase = 1
    creature:SetMaxHealth(871750)
    creature:SetHealth(871750)
    Phase1(creature)
    creature:RegisterEvent(CheckHealth, 1000, 0)
    creature:RegisterEvent(CastBerserk, BERSERK_TIMER, 1)
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

local function OnSpawn(event, creature)
    creature:SetMaxHealth(871750)
    creature:SetHealth(871750)
end

RegisterCreatureEvent(BOSS_ARGALOTH, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_ARGALOTH, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_ARGALOTH, 4, OnDeath)
RegisterCreatureEvent(BOSS_ARGALOTH, 5, OnSpawn)
