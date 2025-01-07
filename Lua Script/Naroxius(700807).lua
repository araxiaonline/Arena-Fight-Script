-- Original script of Naroxius Death Guard by Kreegoth https://www.mmopro.org/archive/index.php/t-586.html
-- Coverted by Manmadedrummer for Azerothcore Araxia Online
local ENEMY_ID = 700807

local SPELL_DEATHSTRIKE = 71489
local SPELL_ASUNDER = 28733
local SPELL_DIRENOVA = 38739
local SPELL_DOOMSLICE = 40481
local SPELL_HARBINGER = 36836
local SPELL_DEFENSIVE = 33479
local SPELL_BLAST = 32907
local SPELL_DISORIENT = 19369
local SPELL_SHELTER = 36481
local SPELL_FRAILTY = 19372
local SPELL_FINAL_PHASE = 33130

local function CastDeathstrike(eventId, delay, repeats, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_DEATHSTRIKE, true)
    end
end

local function CastAsunder(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_ASUNDER, true)
end

local function CastDirenova(eventId, delay, repeats, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_DIRENOVA, true)
    end
end

local function CastDoomslice(eventId, delay, repeats, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_DOOMSLICE, true)
    end
end

local function CastHarbinger(eventId, delay, repeats, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_HARBINGER, true)
    end
end

local function CastDefensive(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_DEFENSIVE, true)
end

local function CastBlast(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_BLAST, true)
end

local function CastDisorient(eventId, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, SPELL_DISORIENT, true)
    end
end

local function CastShelter(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_SHELTER, true)
end

local function CastFrailty(eventId, delay, repeats, creature)
    local target = creature:GetAITarget(0)
    if target then
        creature:CastSpell(target, SPELL_FRAILTY, true)
    end
end

local function Phase1(creature)
    creature:RegisterEvent(CastDeathstrike, 8000, 0)
    creature:RegisterEvent(CastAsunder, 15000, 0)
    creature:RegisterEvent(CastDirenova, 20000, 0)
end

local function Phase2(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("Your corpses will be a feast for those that hunger!", 0)
    creature:RegisterEvent(CastDoomslice, 5000, 0)
    creature:RegisterEvent(CastHarbinger, 15000, 0)
    creature:RegisterEvent(CastDefensive, 17000, 0)
    Phase1(creature)
end

local function Phase3(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("Feel my wrath! The end is near!", 0)
    creature:RegisterEvent(CastBlast, 20000, 0)
    creature:RegisterEvent(CastDisorient, 15000, 0)
    creature:RegisterEvent(CastShelter, 50000, 0)
    creature:RegisterEvent(CastFrailty, 35000, 0)
    Phase1(creature)
end

local function Phase4(creature)
    creature:RemoveEvents()
    creature:SendUnitYell("Fools! Your defeat is inevitable!", 0)
    creature:CastSpell(creature, SPELL_FINAL_PHASE, true)
    Phase1(creature)
end

local function OnCombat(event, creature, target)
    creature:SendUnitYell("The blood of men who have failed in this task, it stains the earth here...", 0)
    Phase1(creature)
    creature:RegisterEvent(function(eventId, delay, repeats, creature)
        if creature:GetHealthPct() < 76 then
            Phase2(creature)
        elseif creature:GetHealthPct() < 49 then
            Phase3(creature)
        elseif creature:GetHealthPct() < 20 then
            Phase4(creature)
        end
    end, 1000, 0)
end

local function OnLeaveCombat(event, creature)
    creature:RemoveEvents()
    creature:DespawnOrUnsummon(0)
end

local function OnKilledTarget(event, creature, victim)
    creature:SendUnitYell("Another soul claimed by Naroxius Death Guard!", 0)
end

local function OnDeath(event, creature, killer)
    creature:SendUnitYell("You have defeated me... For now... we shall meet again", 0)
    creature:RemoveEvents()
end

RegisterCreatureEvent(ENEMY_ID, 1, OnCombat)
RegisterCreatureEvent(ENEMY_ID, 2, OnLeaveCombat)
RegisterCreatureEvent(ENEMY_ID, 3, OnKilledTarget)
RegisterCreatureEvent(ENEMY_ID, 4, OnDeath)
