--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item
-- HeroRotation
local HR     = HeroRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Druid then Spell.Druid = {} end
Spell.Druid.Guardian = {
  BearForm                              = Spell(5487),
  RageoftheSleeperBuff                  = Spell(),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  RageoftheSleeper                      = Spell(200851),
  RendandTear                           = Spell(),
  ThrashBearDebuff                      = Spell(192090),
  Barkskin                              = Spell(22812),
  Brambles                              = Spell(203953),
  SurvivaloftheFittest                  = Spell(),
  ProcSephuz                            = Spell(),
  ThrashBear                            = Spell(77758),
  Maul                                  = Spell(6807),
  Pulverize                             = Spell(80313),
  Moonfire                              = Spell(8921),
  GalacticGuardian                      = Spell(203964),
  MoonfireDebuff                        = Spell(164812),
  IncarnationBuff                       = Spell(102558),
  JaggedClaws                           = Spell(),
  SouloftheForest                       = Spell(158477),
  Mangle                                = Spell(33917),
  GalacticGuardianBuff                  = Spell(213708),
  SwipeBear                             = Spell(213771)
};
local S = Spell.Druid.Guardian;

-- Items
if not Item.Druid then Item.Druid = {} end
Item.Druid.Guardian = {
  LadyandtheChild                  = Item(144295),
  FuryofNature                     = Item(),
  ProlongedPower                   = Item(142117),
  LuffaWrappings                   = Item(137056)
};
local I = Item.Druid.Guardian;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Druid.Commons,
  Guardian = HR.GUISettings.APL.Druid.Guardian
};

-- Variables
local VarLatcOrFonEquipped = 0;

local EnemyRanges = {8, 40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function Swipe()
  if Player:Buff(S.CatForm) then
    return S.SwipeCat;
  else
    return S.SwipeBear;
  end
end

local function Thrash()
  if Player:Buff(S.CatForm) then
    return S.ThrashCat;
  else
    return S.ThrashBear;
  end
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Cooldowns
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- variable,name=latc_or_fon_equipped,value=equipped.lady_and_the_child|equipped.fury_of_nature
    if (true) then
      VarLatcOrFonEquipped = num(I.LadyandtheChild:IsEquipped() or I.FuryofNature:IsEquipped())
    end
    -- bear_form
    if S.BearForm:IsCastableP() then
      if HR.Cast(S.BearForm) then return ""; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
  end
  Cooldowns = function()
    -- potion,if=buff.rage_of_the_sleeper.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.RageoftheSleeperBuff)) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- rage_of_the_sleeper,if=(talent.rend_and_tear.enabled&dot.thrash_bear.stack=dot.thrash_bear.max_stacks)|!talent.rend_and_tear.enabled
    if S.RageoftheSleeper:IsCastableP() and ((S.RendandTear:IsAvailable() and Target:DebuffStackP(S.ThrashBearDebuff) == dot.thrash_bear.max_stacks) or not S.RendandTear:IsAvailable()) then
      if HR.Cast(S.RageoftheSleeper) then return ""; end
    end
    -- barkskin,if=talent.brambles.enabled&(buff.rage_of_the_sleeper.up|talent.survival_of_the_fittest.enabled)
    if S.Barkskin:IsCastableP() and (S.Brambles:IsAvailable() and (Player:BuffP(S.RageoftheSleeperBuff) or S.SurvivaloftheFittest:IsAvailable())) then
      if HR.Cast(S.Barkskin) then return ""; end
    end
    -- proc_sephuz,if=cooldown.thrash_bear.remains=0
    if S.ProcSephuz:IsCastableP() and (S.ThrashBear:CooldownRemainsP() == 0) then
      if HR.Cast(S.ProcSephuz) then return ""; end
    end
    -- use_items,if=cooldown.rage_of_the_sleeper.remains>12|buff.rage_of_the_sleeper.up|target.time_to_die<22
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- maul,if=active_enemies<6&(rage.deficit<8|cooldown.thrash_bear.remains>gcd&rage.deficit<20)
    if S.Maul:IsCastableP() and (Cache.EnemiesCount[40] < 6 and (Player:RageDeficit() < 8 or S.ThrashBear:CooldownRemainsP() > Player:GCD() and Player:RageDeficit() < 20)) then
      if HR.Cast(S.Maul) then return ""; end
    end
    -- pulverize,if=cooldown.thrash_bear.remains<2&dot.thrash_bear.stack=dot.thrash_bear.max_stacks
    if S.Pulverize:IsCastableP() and (S.ThrashBear:CooldownRemainsP() < 2 and Target:DebuffStackP(S.ThrashBearDebuff) == dot.thrash_bear.max_stacks) then
      if HR.Cast(S.Pulverize) then return ""; end
    end
    -- moonfire,if=!talent.galactic_guardian.enabled&(!dot.moonfire.ticking|(buff.incarnation.up&dot.moonfire.refreshable))&active_enemies=1
    if S.Moonfire:IsCastableP() and (not S.GalacticGuardian:IsAvailable() and (not Target:DebuffP(S.MoonfireDebuff) or (Player:BuffP(S.IncarnationBuff) and Target:DebuffRefreshableCP(S.MoonfireDebuff))) and Cache.EnemiesCount[40] == 1) then
      if HR.Cast(S.Moonfire) then return ""; end
    end
    -- thrash_bear,if=((buff.incarnation.up&(dot.thrash_bear.refreshable|(equipped.luffa_wrappings|artifact.jagged_claws.rank>4)))|dot.thrash_bear.stack<dot.thrash_bear.max_stacks|(equipped.luffa_wrappings&artifact.jagged_claws.rank>5))&!talent.soul_of_the_forest.enabled|active_enemies>1
    if S.ThrashBear:IsCastableP() and (((Player:BuffP(S.IncarnationBuff) and (Target:DebuffRefreshableCP(S.ThrashBearDebuff) or (I.LuffaWrappings:IsEquipped() or S.JaggedClaws:ArtifactRank() > 4))) or Target:DebuffStackP(S.ThrashBearDebuff) < dot.thrash_bear.max_stacks or (I.LuffaWrappings:IsEquipped() and S.JaggedClaws:ArtifactRank() > 5)) and not S.SouloftheForest:IsAvailable() or Cache.EnemiesCount[8] > 1) then
      if HR.Cast(S.ThrashBear) then return ""; end
    end
    -- mangle,if=active_enemies<4
    if S.Mangle:IsCastableP() and (Cache.EnemiesCount[40] < 4) then
      if HR.Cast(S.Mangle) then return ""; end
    end
    -- thrash_bear
    if S.ThrashBear:IsCastableP() then
      if HR.Cast(S.ThrashBear) then return ""; end
    end
    -- moonfire,target_if=buff.galactic_guardian.up&(((!variable.latc_or_fon_equipped&active_enemies<4)|(variable.latc_or_fon_equipped&active_enemies<5))|dot.moonfire.refreshable&(!variable.latc_or_fon_equipped&active_enemies<5)|(variable.latc_or_fon_equipped&active_enemies<6))
    if S.Moonfire:IsCastableP() and (Player:BuffP(S.GalacticGuardianBuff) and (((not bool(VarLatcOrFonEquipped) and Cache.EnemiesCount[40] < 4) or (bool(VarLatcOrFonEquipped) and Cache.EnemiesCount[40] < 5)) or Target:DebuffRefreshableCP(S.MoonfireDebuff) and (not bool(VarLatcOrFonEquipped) and Cache.EnemiesCount[40] < 5) or (bool(VarLatcOrFonEquipped) and Cache.EnemiesCount[40] < 6))) then
      if HR.Cast(S.Moonfire) then return ""; end
    end
    -- moonfire,target_if=dot.moonfire.refreshable&!talent.galactic_guardian.enabled
    if S.Moonfire:IsCastableP() and (Target:DebuffRefreshableCP(S.MoonfireDebuff) and not S.GalacticGuardian:IsAvailable()) then
      if HR.Cast(S.Moonfire) then return ""; end
    end
    -- maul,if=active_enemies<6&(cooldown.rage_of_the_sleeper.remains>10|buff.rage_of_the_sleeper.up)
    if S.Maul:IsCastableP() and (Cache.EnemiesCount[40] < 6 and (S.RageoftheSleeper:CooldownRemainsP() > 10 or Player:BuffP(S.RageoftheSleeperBuff))) then
      if HR.Cast(S.Maul) then return ""; end
    end
    -- moonfire,target_if=dot.moonfire.refreshable&active_enemies<3
    if S.Moonfire:IsCastableP() and (Target:DebuffRefreshableCP(S.MoonfireDebuff) and Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.Moonfire) then return ""; end
    end
    -- swipe_bear
    if S.SwipeBear:IsCastableP() then
      if HR.Cast(S.SwipeBear) then return ""; end
    end
  end
end

HR.SetAPL(104, APL)
