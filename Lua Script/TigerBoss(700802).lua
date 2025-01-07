local BOSS_ID = 700802
local RAVAGE = 24213
local LYNX_RUSH = 43153
local LYNX_FURRY = 43290
local PHASE_1 = 85
local PHASE_2 = 60
local PHASE_3 = 45
local PHASE_4 = 10

local teleportX, teleportY, teleportZ, teleportOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

local function CastRavage(eventId, delay, calls, creature)
    creature:CastSpell(creature:GetVictim(), RAVAGE, true)
end

local function CastLynxRush(eventId, delay, calls, creature)
    creature:CastSpell(creature:GetVictim(), LYNX_RUSH, true)
end

local function CastLynxFurry(eventId, delay, calls, creature)
    creature:CastSpell(creature:GetVictim(), LYNX_FURRY, true)
end

local function Phase4(event, delay, repeats, creature)
    if creature:GetHealthPct() <= PHASE_4 then
        creature:SendUnitYell("I WILL NOT DIE!", 0)
        creature:RegisterEvent(CastLynxFurry, 7000, 0)
        creature:RemoveEventById(event)
    end
end

local function Phase3(event, delay, repeats, creature)
    if creature:GetHealthPct() <= PHASE_3 then
        creature:SendUnitYell("RAHH!", 0)
        creature:RegisterEvent(CastLynxFurry, 10000, 0)
        creature:RemoveEventById(event)
        creature:RegisterEvent(Phase4, 1000, 0)
    end
end

local function Phase2(event, delay, repeats, creature)
    if creature:GetHealthPct() <= PHASE_2 then
        creature:SendUnitYell("Feel My Claws!", 0)
        creature:RegisterEvent(CastLynxRush, 8000, 0)
        creature:RemoveEventById(event)
        creature:RegisterEvent(Phase3, 1000, 0)
    end
end

local function OnCombatStart(event, creature, target)
    creature:SendUnitYell("You are unwise to enter my lair!", 0)
    creature:RegisterEvent(CastRavage, 6000, 0)
    creature:RegisterEvent(Phase2, 1000, 0)
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
    creature:SetMaxHealth(877964)
    creature:SetHealth(877964)
end

RegisterCreatureEvent(BOSS_ID, 1, OnCombatStart)
RegisterCreatureEvent(BOSS_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(BOSS_ID, 4, OnDeath)
RegisterCreatureEvent(BOSS_ID, 5, OnSpawn)
