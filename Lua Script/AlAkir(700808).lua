-- Al'Akir Script for AzerothCore Araxia Online by Manmadedrummer

local BOSS_AL_AKIR = 700808
local SPELL_WIND_BURST = 63557
local SPELL_SQUALL_LINE = 500076
local SPELL_ICE_STORM = 71118
local SPELL_LIGHTNING_STRIKE = 52944
local SPELL_ELECTROCUTE = 71934
local SPELL_SUMMON_STORMLING = 33689
local SPELL_FEEDBACK = 44335
local SPELL_EYE_OF_THE_STORM = 52970
local STAGE_TWO_HEALTH = 80
local STAGE_THREE_HEALTH = 25
local phase = 1

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function CastWindBurst(eventId, delay, calls, creature)
    creature:CastSpell(creature:GetVictim(), SPELL_WIND_BURST, true)
end

local function CastSquallLine(eventId, delay, calls, creature)
    creature:CastSpell(creature:GetVictim(), SPELL_SQUALL_LINE, true)
end

local function CastIceStorm(eventId, delay, calls, creature)
    local targets = creature:GetAITargets(10)
    for _, target in ipairs(targets) do
        creature:CastSpell(target, SPELL_ICE_STORM, true)
    end
end

local function CastLightningStrike(eventId, delay, calls, creature)
    creature:CastSpell(creature:GetVictim(), SPELL_LIGHTNING_STRIKE, true)
end

local function SummonStormling(eventId, delay, calls, creature)
    creature:CastSpell(creature, SPELL_SUMMON_STORMLING, true)
end

local function ApplyFeedback(eventId, delay, calls, creature)
    creature:CastSpell(creature, SPELL_FEEDBACK, true)
end

local function StartPhaseOne(creature)
    creature:RegisterEvent(CastWindBurst, 20000, 0)
    creature:RegisterEvent(CastSquallLine, 30000, 0)
    creature:RegisterEvent(CastIceStorm, 15000, 0)
    creature:RegisterEvent(CastLightningStrike, 12000, 0)
end

local function StartPhaseTwo(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("The storm intensifies!", 0)
    creature:RegisterEvent(SummonStormling, 20000, 0)
    creature:RegisterEvent(ApplyFeedback, 20000, 0)
end

local function StartPhaseThree(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("The eye of the storm approaches!", 0)
    creature:CastSpell(creature, SPELL_EYE_OF_THE_STORM, true)
    creature:RegisterEvent(CastWindBurst, 20000, 0)
    creature:RegisterEvent(CastLightningStrike, 12000, 0)
end

local function CheckHealth(eventId, delay, calls, creature)
    local healthPct = creature:GetHealthPct()
    if phase == 1 and healthPct <= STAGE_TWO_HEALTH then
        phase = 2
        StartPhaseTwo(creature)
    elseif phase == 2 and healthPct <= STAGE_THREE_HEALTH then
        phase = 3
        StartPhaseThree(creature)
    end
end

local function OnEnterCombat(event, creature, target)
    phase = 1
    creature:SendUnitYell("You will be swept away by the storm!", 0)
    StartPhaseOne(creature)
    creature:RegisterEvent(CheckHealth, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)  -- Immediately despawn the boss upon leaving combat
end

local function OnSpawn(event, creature)
    creature:SetMaxHealth(1952720)
    creature:SetHealth(1952720)
end

local function OnDied(event, creature, killer)
    creature:RemoveEvents()
    creature:SendUnitYell("My storm... has been silenced...", 0)
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, 2204.453125, -4794.402344, 64.998360, 1.033404)
    end
end

RegisterCreatureEvent(BOSS_AL_AKIR, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_AL_AKIR, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_AL_AKIR, 4, OnDied)
RegisterCreatureEvent(BOSS_AL_AKIR, 5, OnSpawn)
