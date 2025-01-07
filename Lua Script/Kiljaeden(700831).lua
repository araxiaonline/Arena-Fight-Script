-- Kil'Jaeden Arena Boss script by Manmadedrummer for Araxia Online

local KILJAEDEN_NPC_ID = 700831
local PHASE_ONE = 1
local PHASE_TWO = 2
local PHASE_THREE = 3
local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404
local currentPhase = PHASE_ONE

local function CastRandomSpell(event, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if not target then return end
    local spellList = {
        58461, 27579, -- Felclaws
        30533,       -- Rupturing Singularity
        45915,       -- Armageddon
        39048, 71106, -- Sorrowful Wail
        29964,       -- Bursting Dreadflame
        64698,       -- Focused Dreadflame
        75362,       -- Focused Dreadburst
        61463,       -- Soul Anguish
        70184,       -- Darkness Of A Thousand Souls
        37798        -- Demonic Obelisk
    }
    local spell = spellList[math.random(#spellList)]
    creature:CastSpell(target, spell, true)
end

local function CastDemonicObelisk(event, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if not target then return end
    creature:CastSpell(target, 37798, true)
end

local function Kiljaeden_Say(event, delay, repeats, creature)
    local quotes = {
        "A meaningless struggle! Azeroth shall fall to the Burning Legion!",
        "A vessel for my fury!",
        "An inevitable fate!",
        "Confront your own darkness!",
        "Consume them all!",
        "Fall before your master!",
        "Give in to your fears! Your desires!",
        "Still you resist! Then let me repay your arrogance!",
        "This battle shall be your last!",
        "Your souls will soon know oblivion!",
    }
    local randomQuote = quotes[math.random(#quotes)]
    creature:SendUnitYell(randomQuote, 0)
end

local function OnEnterCombat(event, creature, target)
    currentPhase = PHASE_ONE
    creature:RegisterEvent(Kiljaeden_Say, 15000, 0)
    creature:RegisterEvent(CastRandomSpell, 8000, 0)
end

local function CheckHealth(event, creature)
    local healthPct = creature:GetHealthPct()
    if healthPct <= 80 and currentPhase == PHASE_ONE then
        currentPhase = PHASE_TWO
        creature:RemoveEvents()
        creature:RegisterEvent(Kiljaeden_Say, 15000, 0)
        creature:RegisterEvent(CastRandomSpell, 5000, 0)
        creature:SendUnitYell("You cannot resist your own nature!", 0)
    elseif healthPct <= 40 and currentPhase == PHASE_TWO then
        currentPhase = PHASE_THREE
        creature:RemoveEvents()
        creature:RegisterEvent(Kiljaeden_Say, 15000, 0)
        creature:RegisterEvent(CastDemonicObelisk, 1000, 1)
        creature:RegisterEvent(CastRandomSpell, 2000, 0)
        creature:SendUnitYell("Your souls will soon know oblivion!", 0)
    end
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDied(event, creature, killer)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, teleportX, teleportY, teleportZ, teleportOrientation)
    end
end

local function OnSpawn(event, creature)
    currentPhase = PHASE_ONE
    creature:SetMaxHealth(3563541)
    creature:SetHealth(3563541)
end

RegisterCreatureEvent(KILJAEDEN_NPC_ID, 1, OnEnterCombat)
RegisterCreatureEvent(KILJAEDEN_NPC_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(KILJAEDEN_NPC_ID, 4, OnDied)
RegisterCreatureEvent(KILJAEDEN_NPC_ID, 5, OnSpawn)
RegisterCreatureEvent(KILJAEDEN_NPC_ID, 7, CheckHealth)
