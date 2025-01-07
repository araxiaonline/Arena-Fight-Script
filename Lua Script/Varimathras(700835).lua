-- Varimathras Arena Boss script by Manmadedrummer for Araxia Online

local VARIMATHRAS_NPC_ID = 700835

local PHASE_ONE = 1
local SPELL_INTERVAL_PHASE_1 = 2000 -- 2 seconds
local AURA_CHANGE_INTERVAL = 20000 -- 20 seconds
local HEALTH_ON_SPAWN = 984400

-- NPC and Spell IDs
local SPELL_MISERY = 59856
local SPELL_ALONE_IN_THE_DARKNESS = 71106
local SPELL_SHADOW_STRIKE = 40685
local SPELL_DARK_FISSURE = 59127
local SPELL_MARKED_PREY = 67882
local SPELL_NECROTIC_EMBRACE = 72492
local SPELL_ECHOES_OF_DOOM = 71124

-- Aura IDs
local AURA_FLAMES = 22436
local AURA_FROST = 71052
local AURA_FEL = 75887
local AURA_SHADOWS = 69491
local AURA_NECROTIC = 55593

local auraCycle = {AURA_FLAMES, AURA_FROST, AURA_FEL, AURA_SHADOWS, AURA_NECROTIC}
local currentAuraIndex = 1

local function CastRandomSpell(event, delay, calls, creature)
    local spellTable = {
        SPELL_MISERY,
        SPELL_ALONE_IN_THE_DARKNESS,
        SPELL_SHADOW_STRIKE,
        SPELL_DARK_FISSURE,
        SPELL_MARKED_PREY,
        SPELL_NECROTIC_EMBRACE,
        SPELL_ECHOES_OF_DOOM,
    }
    local spellToCast = spellTable[math.random(1, #spellTable)]
    creature:CastSpell(creature:GetVictim(), spellToCast, false)
end

local function ChangeAura(event, delay, calls, creature)
    if currentAuraIndex > #auraCycle then
        currentAuraIndex = 1
        -- Shuffle the aura cycle
        for i = #auraCycle, 2, -1 do
            local j = math.random(1, i)
            auraCycle[i], auraCycle[j] = auraCycle[j], auraCycle[i]
        end
    end
    local auraToApply = auraCycle[currentAuraIndex]
    currentAuraIndex = currentAuraIndex + 1

    creature:RemoveAllAuras()
    creature:AddAura(auraToApply, creature)
    
    -- Different quotes for different auras
    local auraQuotes = {
        [AURA_FLAMES] = "Time to die!",
        [AURA_FROST] = "You think you can match the might of a dreadlord?!",
        [AURA_FEL] = "None can oppose me.",
        [AURA_SHADOWS] = "Don't waste my time.",
        [AURA_NECROTIC] = "I'm always on the winning side."
    }
    if auraQuotes[auraToApply] then
        creature:SendUnitYell(auraQuotes[auraToApply], 0)
    end
end

local function OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Vanquish the weak!", 0)
    creature:RegisterEvent(CastRandomSpell, SPELL_INTERVAL_PHASE_1, 0)
    creature:RegisterEvent(ChangeAura, AURA_CHANGE_INTERVAL, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("For Sylvanas!", 0)
    creature:RemoveEvents()
    local players = creature:GetPlayersInRange(10)
    for _, player in ipairs(players) do
        player:Teleport(1, 2204.453125, -4794.402344, 64.998360, 1.033404)
    end
end

local function OnSpawn(event, creature)
    creature:SetMaxHealth(HEALTH_ON_SPAWN)
    creature:SetHealth(HEALTH_ON_SPAWN)
end

RegisterCreatureEvent(VARIMATHRAS_NPC_ID, 5, OnSpawn)
RegisterCreatureEvent(VARIMATHRAS_NPC_ID, 1, OnEnterCombat)
RegisterCreatureEvent(VARIMATHRAS_NPC_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(VARIMATHRAS_NPC_ID, 4, OnDeath)

