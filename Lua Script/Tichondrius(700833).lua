-- Tichonddrius Arena Boss script by Manmadedrummer for Araxia Online

local Tichondrius = 700833
local SightlessEye = 21346
local Banshee = 29646

local PHASE_ONE = 1
local PHASE_TWO = 2
local currentPhase = PHASE_ONE

local healthOnSpawn = 1293469

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local spellsPhaseOne = {
    65810, -- Carrion Plague
    67943, -- Seeker Swarm
    71124, -- Brand of Argus
    67760, -- Flames of Argus
    20810, -- Vampiric Aura
    48266, -- Feast of Blood
    19644, -- Tainted Blood
    39048  -- Echoes of the Void
}

local spellsPhaseTwo = {
    500078, -- Illusionary Night
    48319, -- Carrion Nightmare
    50452  -- Phantasmal Bloodfang
}

local function CastRandomSpellPhaseOne(event, delay, calls, creature)
    local spellId = spellsPhaseOne[math.random(#spellsPhaseOne)]
    creature:CastSpell(creature:GetVictim(), spellId, true)
end

local function CastRandomSpellPhaseTwo(event, delay, calls, creature)
    local spellId = spellsPhaseTwo[math.random(#spellsPhaseTwo)]
    creature:CastSpell(creature:GetVictim(), spellId, true)
end

local function PhaseTransition(event, delay, calls, creature)
    if currentPhase == PHASE_ONE then
        creature:RemoveEvents()
        creature:RegisterEvent(CastRandomSpellPhaseTwo, 3000, 0)
        creature:SendUnitYell("This nightmare is just beginning for you!", 0)
        creature:SpawnCreature(SightlessEye, creature:GetX() + 2, creature:GetY(), creature:GetZ(), creature:GetO(), 2, 60000)
        creature:SpawnCreature(SightlessEye, creature:GetX() - 2, creature:GetY(), creature:GetZ(), creature:GetO(), 2, 60000)
        currentPhase = PHASE_TWO
        creature:RegisterEvent(PhaseTransition, 30000, 1)
    elseif currentPhase == PHASE_TWO then
        creature:RemoveEvents()
        creature:RegisterEvent(CastRandomSpellPhaseOne, 5000, 0)
        creature:SpawnCreature(Banshee, creature:GetX(), creature:GetY(), creature:GetZ(), creature:GetO(), 2, 60000)
        creature:SendUnitYell("Never trust a mortal to do a demon's work!", 0)
        currentPhase = PHASE_ONE
        creature:RegisterEvent(PhaseTransition, 90000, 1)
    end
end

local function OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Witness your end!", 0)
    currentPhase = PHASE_ONE
    creature:RegisterEvent(CastRandomSpellPhaseOne, 5000, 0)
    creature:RegisterEvent(PhaseTransition, 90000, 1)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDied(event, creature, killer)
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
    creature:RemoveEvents()
end

local function OnSpawn(event, creature)
    currentPhase = PHASE_ONE
    creature:SetMaxHealth(healthOnSpawn)
    creature:SetHealth(healthOnSpawn)
end

RegisterCreatureEvent(Tichondrius, 1, OnEnterCombat)
RegisterCreatureEvent(Tichondrius, 2, OnLeaveCombat)
RegisterCreatureEvent(Tichondrius, 4, OnDied)
RegisterCreatureEvent(Tichondrius, 5, OnSpawn)
