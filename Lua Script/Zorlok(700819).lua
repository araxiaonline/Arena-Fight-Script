--Zor'Lok Boss script made by Manmadedrummer for Araxia Online

local BOSS_ZORLOK = 700819
local MAX_HEALTH = 2057000

local SPELL_INHALE = 29158
local SPELL_EXHALE = 60960
local SPELL_PHEROMONES_OF_ZEAL = 61463
local SPELL_ATTENUATION = 75418
local SPELL_FORCE_AND_VERVE = 59971

local SPELL_INHALE_PHEROMONES = 15716
local SPELL_ECHOES_OF_POWER = 58832
local SPELL_SONG_OF_THE_EMPRESS = 57061
local SPELL_ECHO_OF_ATTENUATION = 68835
local SPELL_ECHO_OF_FORCE_AND_VERVE = 53071

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404
local TELEPORT_MAP_ID = 1

local QUOTES = {
    "And so it falls to us, Her chosen voice.",
    "Behold the voice of Her divine wrath.",
    "Her happiness is our reward, her sorrow our failure.",
    "Never to question, nor to contemplate; we simply act.",
    "Ours is but to serve in Her divine name.",
    "Ours is but to serve; yours is but to die.",
    "We fight, toil, and serve so that Her vision for us is made reality."
}

local DEATH_QUOTE = "We will not give in to the despair of the dark void. If Her will for us is to perish, then it shall be so."

local SPELL_INTERVAL_PHASE1 = 7000
local SPELL_INTERVAL_PHASE2 = 5000

local phaseTwoStarted = false

local function PhaseOneSpells(event, delay, pCall, creature)
    local phase1Spells = {SPELL_INHALE, SPELL_EXHALE, SPELL_PHEROMONES_OF_ZEAL, SPELL_ATTENUATION, SPELL_FORCE_AND_VERVE}
    creature:CastSpell(creature:GetVictim(), phase1Spells[math.random(#phase1Spells)], true)
end

local function PhaseTwoSpells(event, delay, pCall, creature)
    local phase2Spells = {
        SPELL_INHALE, SPELL_EXHALE, SPELL_PHEROMONES_OF_ZEAL, SPELL_ATTENUATION, SPELL_FORCE_AND_VERVE,
        SPELL_INHALE_PHEROMONES, SPELL_ECHOES_OF_POWER, SPELL_SONG_OF_THE_EMPRESS, SPELL_ECHO_OF_ATTENUATION, SPELL_ECHO_OF_FORCE_AND_VERVE
    }
    creature:CastSpell(creature:GetVictim(), phase2Spells[math.random(#phase2Spells)], true)
end

local function OnDamageTaken(event, creature, attacker, damage)
    if not phaseTwoStarted and creature:GetHealthPct() <= 80 then
        phaseTwoStarted = true
        creature:SendUnitYell("Witness true power!", 0)
        creature:RemoveEvents()
        creature:RegisterEvent(PhaseTwoSpells, SPELL_INTERVAL_PHASE2, 0)
    end
end

local function TeleportNearbyPlayers(creature)
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(TELEPORT_MAP_ID, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

local function OnSpawn(event, creature)
    creature:SetMaxHealth(MAX_HEALTH)
    creature:SetHealth(MAX_HEALTH)
end

local function OnEnterCombat(event, creature, target)
    creature:SendUnitYell(QUOTES[math.random(#QUOTES)], 0)
    phaseTwoStarted = false
    creature:RegisterEvent(PhaseOneSpells, SPELL_INTERVAL_PHASE1, 0)
end

local function OnDied(event, creature, killer)
    creature:SendUnitYell(DEATH_QUOTE, 0)
    TeleportNearbyPlayers(creature)
    creature:RemoveEvents()
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

RegisterCreatureEvent(BOSS_ZORLOK, 1, OnEnterCombat)
RegisterCreatureEvent(BOSS_ZORLOK, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_ZORLOK, 4, OnDied)
RegisterCreatureEvent(BOSS_ZORLOK, 5, OnSpawn)
RegisterCreatureEvent(BOSS_ZORLOK, 9, OnDamageTaken)