-- Imonar Arena Boss Script by Manmadedrummer for Araxia Online

local IMONAR_NPC_ID = 700836

local PHASE_ONE = 1
local PHASE_TWO = 2
local PHASE_THREE = 3

local SPELL_INTERVAL_PHASE_1_2 = 3000
local SPELL_INTERVAL_PHASE_3 = 2000
local HEALTH_ON_SPAWN = 2032543
local PHASE_THREE_HEALTH_THRESHOLD = 33

local SPELL_SHOCK_LANCE = 49840
local SPELL_ELECTRIFY = 43730
local SPELL_SLUMBER_GAS = 9256
local SPELL_PULSE_GRENADE = 62645
local SPELL_INFERNAL_ROCKETS = 66542
local SPELL_SEVER = 72261
local SPELL_CHARGED_BLAST = 65279
local SPELL_SHRAPNEL_BLAST = 38753
local SPELL_SEARED_SKIN = 23461
local SPELL_STASIS_TRAP = 36527
local SPELL_BLASTWIRE = 43444
local SPELL_GATHERING_POWER = 42381

local currentPhase = PHASE_ONE

local function CastRandomSpellInPhase(eventId, delay, repeats, creature)
    local spellTable = {}
    if currentPhase == PHASE_ONE then
        spellTable = { SPELL_SHOCK_LANCE, SPELL_ELECTRIFY, SPELL_SLUMBER_GAS, SPELL_PULSE_GRENADE, SPELL_INFERNAL_ROCKETS }
    elseif currentPhase == PHASE_TWO then
        spellTable = { SPELL_SEVER, SPELL_CHARGED_BLAST, SPELL_SHRAPNEL_BLAST, SPELL_INFERNAL_ROCKETS }
    elseif currentPhase == PHASE_THREE then
        spellTable = { SPELL_SHOCK_LANCE, SPELL_ELECTRIFY, SPELL_PULSE_GRENADE, SPELL_SHRAPNEL_BLAST, SPELL_SLUMBER_GAS, SPELL_INFERNAL_ROCKETS, SPELL_SEARED_SKIN, SPELL_STASIS_TRAP, SPELL_BLASTWIRE, SPELL_GATHERING_POWER }
    end
    local spellToCast = spellTable[math.random(1, #spellTable)]
    creature:CastSpell(creature:GetVictim(), spellToCast, false)
end

local function Phase1(creature)
    creature:RemoveEvents()
    creature:RegisterEvent(CastRandomSpellInPhase, SPELL_INTERVAL_PHASE_1_2, 0)
end

local function Phase2(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("Keep up, if you can.", 0)
    creature:RegisterEvent(CastRandomSpellInPhase, SPELL_INTERVAL_PHASE_1_2, 0)
end

local function Phase3(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("My victory is absolute. The power of Nightmare grows!", 0)
    creature:RegisterEvent(CastRandomSpellInPhase, SPELL_INTERVAL_PHASE_3, 0)
end

local function OnEnterCombat(event, creature, target)
    creature:SendUnitYell("You'll go no further, mortal scum. There's a bounty on your heads, and I mean to collect.", 0)
    currentPhase = PHASE_ONE
    Phase1(creature)
end

local function OnHealthChange(event, creature, healthPct)
    healthPct = creature:GetHealthPct()
    if currentPhase ~= PHASE_THREE and healthPct <= PHASE_THREE_HEALTH_THRESHOLD then
        currentPhase = PHASE_THREE
        Phase3(creature)
    elseif currentPhase == PHASE_ONE and healthPct <= 66 then
        currentPhase = PHASE_TWO
        Phase2(creature)
    elseif currentPhase == PHASE_TWO and healthPct <= 33 then
        currentPhase = PHASE_ONE
        Phase1(creature)
    end
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("I regret... taking... this job...", 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, 2204.453125, -4794.402344, 64.998360, 1.033404)
    end
end

local function OnKillPlayer(event, creature, victim)
    creature:SendUnitYell("I get paid double if you scream.", 0)
end

local function OnSpawn(event, creature)
    creature:SetMaxHealth(HEALTH_ON_SPAWN)
    creature:SetHealth(HEALTH_ON_SPAWN)
end

RegisterCreatureEvent(IMONAR_NPC_ID, 5, OnSpawn)
RegisterCreatureEvent(IMONAR_NPC_ID, 1, OnEnterCombat)
RegisterCreatureEvent(IMONAR_NPC_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(IMONAR_NPC_ID, 4, OnDeath)
RegisterCreatureEvent(IMONAR_NPC_ID, 3, OnKillPlayer)
RegisterCreatureEvent(IMONAR_NPC_ID, 9, OnHealthChange) -- OnHealthChange event might be defined as 9 in your version of Eluna
