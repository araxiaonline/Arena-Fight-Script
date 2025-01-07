local AIO = AIO or require("AIO")

local FighterGuildHandlers = AIO.AddHandlers("FighterGuildServer", {})

-- Define bosses directly (with difficulty levels, points, and spawn info)
local bosses = {
    -- Custom Bosses
    {id = 700800, name = "Arian - The Demon", level = 80, points = 25, difficulty = "Easy"},
    {id = 700801, name = "Lord Cyran", level = 80, points = 75, difficulty = "Challenging"},
    {id = 700802, name = "Tiger Boss", level = 80, points = 25, difficulty = "Easy"},
    {id = 700803, name = "Spellmaster", level = 80, points = 75, difficulty = "Challenging"},
    {id = 700804, name = "Bogdan - The Shadow Lord", level = 80, points = 75, difficulty = "Challenging"},
    {id = 700805, name = "Cow Lord", level = 80, points = 25, difficulty = "Easy"},
    {id = 700806, name = "Diablo", level = 80, points = 250, difficulty = "Hard"},
    {id = 700807, name = "Naroxius Death Guard", level = 80, points = 75, difficulty = "Challenging"},
    {id = 700817, name = "Gioran the Corrupted Paladin", level = 80, points = 75, difficulty = "Challenging"},

    -- Vanilla Bosses
    {id = 11519, name = "Bazzalan", level = 80, points = 25, difficulty = "Easy"},
    {id = 3654, name = "Mutanus the Devourer", level = 80, points = 25, difficulty = "Easy"},
    {id = 12201, name = "Princess Theradras", level = 80, points = 25, difficulty = "Easy"},
    {id = 15990, name = "Kel'Thuzad", level = 83, points = 250, difficulty = "Hard"},
    {id = 16028, name = "Patchwerk", level = 83, points = 250, difficulty = "Hard"},
    {id = 15299, name = "Viscidus", level = 80, points = 75, difficulty = "Challenging"},
    {id = 16060, name = "Gothik the Harvester", level = 83, points = 75, difficulty = "Challenging"},
    {id = 12264, name = "Shazzrah", level = 80, points = 250, difficulty = "Hard"},
    {id = 12056, name = "Baron Geddon", level = 80, points = 75, difficulty = "Challenging"},
    {id = 12017, name = "Broodlord Lashlayer", level = 80, points = 75, difficulty = "Challenging"},
    {id = 12018, name = "Majordomo Executus", level = 80, points = 75, difficulty = "Challenging"},
    {id = 11501, name = "King Gordok", level = 80, points = 250, difficulty = "Challenging"},

    -- BC Bosses
    {id = 21215, name = "Leotheras the Blind", level = 80, points = 250, difficulty = "Hard"},
    {id = 24723, name = "Selin Fireheart", level = 80, points = 25, difficulty = "Easy"},
    {id = 17308, name = "Omor the Unscarred", level = 80, points = 25, difficulty = "Easy"},
    {id = 17797, name = "Hydromancer Thespia", level = 80, points = 25, difficulty = "Easy"},
    {id = 16809, name = "Warbringer O'mrogg", level = 80, points = 25, difficulty = "Easy"},
    {id = 16807, name = "Grand Warlock Nethekurse", level = 80, points = 75, difficulty = "Challenging"},
    {id = 17977, name = "Warp Splinter", level = 80, points = 75, difficulty = "Challenging"},
    {id = 24239, name = "Hex Lord Malacrass", level = 80, points = 75, difficulty = "Challenging"},
    {id = 18805, name = "High Astromancer Solarian", level = 80, points = 75, difficulty = "Challenging"},
    {id = 22871, name = "Teron Gorefiend", level = 80, points = 250, difficulty = "Hard"},
    {id = 17888, name = "Kaz'rogal", level = 80, points = 250, difficulty = "Hard"},
    {id = 31395, name = "Illidan Stormrage", level = 80, points = 250, difficulty = "Hard"},

    -- WOTLK Bosses
    {id = 27447, name = "Varos Cloudstrider", level = 81, points = 75, difficulty = "Challenging"},
    {id = 36497, name = "Bronjahm", level = 82, points = 75, difficulty = "Challenging"},
    {id = 29309, name = "Elder Nadox", level = 80, points = 25, difficulty = "Easy"},
    {id = 26630, name = "Trollgore", level = 82, points = 75, difficulty = "Challenging"},
    {id = 29310, name = "Jedoga Shadowseeker", level = 82, points = 75, difficulty = "Challenging"},
    {id = 26529, name = "Meathook", level = 82, points = 75, difficulty = "Challenging"},
    {id = 32845, name = "Hodir", level = 83, points = 250, difficulty = "Hard"},
    {id = 32906, name = "Freya", level = 83, points = 250, difficulty = "Hard"},
    {id = 29304, name = "Slad'ran", level = 80, points = 25, difficulty = "Easy"},
    {id = 29305, name = "Moorabi", level = 80, points = 25, difficulty = "Easy"},
    {id = 38433, name = "Toravon the Ice Watcher", level = 83, points = 250, difficulty = "Hard"},
    {id = 700809, name = "The Lich King", level = 83, points = 250, difficulty = "Hard"},

    -- CATA Bosses
    {id = 700808, name = "Al'Akir", level = 84, points = 250, difficulty = "Hard"},
    {id = 700810, name = "Cho'gall", level = 80, points = 250, difficulty = "Hard"},
    {id = 700811, name = "Forgemaster Throngus", level = 82, points = 25, difficulty = "Easy"},
    {id = 700812, name = "Ozruk", level = 80, points = 75, difficulty = "Challenging"},
    {id = 700813, name = "Argaloth", level = 80, points = 250, difficulty = "Hard"},
    {id = 700814, name = "Setesh", level = 80, points = 25, difficulty = "Easy"},
    {id = 700815, name = "Therazane", level = 80, points = 75, difficulty = "Challenging"},

    --MOP BOSSES
    {id = 700816, name = "Elegon", level = 80, points = 250, difficulty = "Hard"},
    {id = 700818, name = "Amber-Shaper Un'Sok", level = 83, points = 250, difficulty = "Hard"},
    {id = 700819, name = "Imperial Vizier Zor'lok", level = 82, points = 250, difficulty = "Hard"},
    {id = 700820, name = "Garrosh Hellscream", level = 85, points = 250, difficulty = "Hard"},
    {id = 700821, name = "Thok the Bloodthirsty", level = 83, points = 75, difficulty = "Challenging"},
    {id = 700822, name = "General Pa'valak", level = 82, points = 75, difficulty = "Easy"},      
    {id = 700823, name = "Gekkan", level = 84, points = 75, difficulty = "Easy"}, 

    -- WoD Bosses
    {id = 700824, name = "Blackhand", level = 85, points = 75, difficulty = "Challenging"},
    {id = 700825, name = "Kargath Bladefist", level = 85, points = 250, difficulty = "Hard"},
    {id = 700826, name = "High Sage Viryx", level = 83, points = 75, difficulty = "Easy"},
    {id = 700827, name = "The Butcher", level = 85, points = 75, difficulty = "Challenging"},
    {id = 700828, name = "Brackenspore", level = 83, points = 250, difficulty = "Hard"},
    {id = 700829, name = "Mannoroth", level = 85, points = 250, difficulty = "Hard"},
    {id = 700830, name = "Lady Temptessa", level = 85, points = 75, difficulty = "Easy"},

    -- Legion Bosses
    {id = 700831, name = "Kil'Jaeden", level = 85, points = 250, difficulty = "Hard"},
    {id = 700832, name = "Gul'dan", level = 85, points = 250, difficulty = "Hard"},
    {id = 700833, name = "Tichondrius", level = 85, points = 250, difficulty = "Hard"},
    {id = 700834, name = "Xavius", level = 85, points = 250, difficulty = "Hard"},
    {id = 700835, name = "Varimathras", level = 85, points = 75, difficulty = "Challenging"},
    {id = 700836, name = "Imonar the Soulhunter", level = 85, points = 75, difficulty = "Challenging"},
}

-- Arena coordinates
local mapId = 1
local playerSpawnX, playerSpawnY, playerSpawnZ, playerOrientation = 2172.05, -4789.88, 55, 1.32696
local bossSpawnX, bossSpawnY, bossSpawnZ, bossOrientation = 2176, -4766, 55, 1.3
local rewardX, rewardY, rewardZ, rewardOrientation = 2204.453125, -4794.402344, 64.998360, 1.033404

-- Queue and arena state variables
local arenaOccupied = false
local queue = {}

-- Function to add player to the queue
local function AddToQueue(player, bossId)
    table.insert(queue, {player = player, bossId = bossId})
    local position = #queue
    player:SendBroadcastMessage("Arena is currently occupied. You are #" .. position .. " in the queue for boss ID: " .. bossId)
end

-- Function to start the next player in the queue
local function StartNextInQueue()
    if #queue > 0 then
        local nextInQueue = table.remove(queue, 1)
        FighterGuildHandlers.StartFight(nextInQueue.player, nextInQueue.bossId)
    end
end

-- Modified StartFight function to check for arena status
function FighterGuildHandlers.StartFight(player, bossId)
    if arenaOccupied then
        -- Arena is occupied, add player to the queue
        AddToQueue(player, bossId)
        return
    end

    -- Arena is free, start fight immediately
    player:Teleport(mapId, playerSpawnX, playerSpawnY, playerSpawnZ, playerOrientation)
    arenaOccupied = true

    local bossInfo
    for _, boss in ipairs(bosses) do
        if boss.id == bossId then
            bossInfo = boss
            break
        end
    end

    -- Spawn the boss at the designated location
    if bossInfo then
        local spawnedBoss = player:SpawnCreature(bossInfo.id, bossSpawnX, bossSpawnY, bossSpawnZ, bossOrientation, 6, 10000)
        if spawnedBoss then
            spawnedBoss:SetLevel(bossInfo.level or 80)
            player:SendBroadcastMessage("Boss spawned successfully: " .. bossInfo.name)
        else
            player:SendBroadcastMessage("Failed to spawn boss. NPC ID: " .. bossInfo.id)
        end
    else
        player:SendBroadcastMessage("Invalid boss selected.")
    end
end

-- Function to handle boss defeat and reward arena points
local function OnBossDefeated(event, creature, killer)
    if killer:IsPlayer() then
        local player = killer
        local bossName = creature:GetName()

        -- Find the boss info by its name
        local bossInfo
        for _, boss in ipairs(bosses) do
            if boss.name == bossName then
                bossInfo = boss
                break
            end
        end

        -- Teleport the player back to the reward location
        if bossInfo then
            player:Teleport(mapId, rewardX, rewardY, rewardZ, rewardOrientation)
            player:SendBroadcastMessage("Teleporting to reward location...")
            
            -- Announce the winner
            creature:SendUnitYell("And our winner is " .. player:GetName() .. "! They have beaten " .. bossName .. ". Look at all that carnage!", 0)

            -- Award arena points
            local points = bossInfo.points or 0
            player:ModifyArenaPoints(points)
            player:SendBroadcastMessage("You earned " .. points .. " Arena Points for defeating " .. bossName .. "!")
        else
            player:SendBroadcastMessage("Could not find boss information after defeat.")
        end

        -- Free the arena and advance the queue after delay
        arenaOccupied = false
        CreateLuaEvent(StartNextInQueue, 15000, 1)  -- 15-second delay before the next player
    end
end

-- Register the death event for all bosses
for _, boss in ipairs(bosses) do
    RegisterCreatureEvent(boss.id, 4, OnBossDefeated)
end

-- NPC Interaction Logic: Show the AIO Boss Selection Frame
local function ArenaMaster_OnGossipHello(event, player, creature)
    AIO.Handle(player, "FighterGuildClient", "ShowBossSelectionFrame")
    player:GossipComplete()
end

-- Register the NPC gossip event (NPC ID: 18268)
RegisterCreatureGossipEvent(18268, 1, ArenaMaster_OnGossipHello)
