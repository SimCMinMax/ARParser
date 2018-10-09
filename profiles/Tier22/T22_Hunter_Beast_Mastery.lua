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
if not Spell.Hunter then Spell.Hunter = {} end
Spell.Hunter.BeastMastery = {
  SummonPet                             = Spell(),
  AspectoftheWildBuff                   = Spell(193530),
  AspectoftheWild                       = Spell(193530),
  Berserking                            = Spell(26297),
  BestialWrath                          = Spell(19574),
  BloodFury                             = Spell(20572),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  BestialWrathBuff                      = Spell(19574),
  BarbedShot                            = Spell(),
  FrenzyBuff                            = Spell(),
  AMurderofCrows                        = Spell(131894),
  SpittingCobra                         = Spell(),
  Stampede                              = Spell(201430),
  Multishot                             = Spell(2643),
  BeastCleaveBuff                       = Spell(118455, "pet"),
  ChimaeraShot                          = Spell(53209),
  KillCommand                           = Spell(34026),
  DireBeast                             = Spell(120679),
  Barrage                               = Spell(120360),
  CobraShot                             = Spell(193455),
  ArcaneTorrent                         = Spell(50613)
};
local S = Spell.Hunter.BeastMastery;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.BeastMastery = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Hunter.BeastMastery;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Hunter.Commons,
  BeastMastery = HR.GUISettings.APL.Hunter.BeastMastery
};

-- Variables

local EnemyRanges = {40}
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

--- ======= ACTION LISTS =======
local function APL()
  local Precombat
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- summon_pet
    if S.SummonPet:IsCastableP() then
      if HR.Cast(S.SummonPet) then return "summon_pet 1471"; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 1474"; end
    end
    -- aspect_of_the_wild
    if S.AspectoftheWild:IsCastableP() and Player:BuffDownP(S.AspectoftheWildBuff) then
      if HR.Cast(S.AspectoftheWild) then return "aspect_of_the_wild 1476"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_shot
    -- use_items
    -- berserking,if=cooldown.bestial_wrath.remains>30
    if S.Berserking:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 1483"; end
    end
    -- blood_fury,if=cooldown.bestial_wrath.remains>30
    if S.BloodFury:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 1487"; end
    end
    -- ancestral_call,if=cooldown.bestial_wrath.remains>30
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 1491"; end
    end
    -- fireblood,if=cooldown.bestial_wrath.remains>30
    if S.Fireblood:IsCastableP() and HR.CDsON() and (S.BestialWrath:CooldownRemainsP() > 30) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 1495"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 1499"; end
    end
    -- potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.BestialWrathBuff) and Player:BuffP(S.AspectoftheWildBuff)) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 1501"; end
    end
    -- barbed_shot,if=full_recharge_time<gcd.max|pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
    if S.BarbedShot:IsCastableP() and (S.BarbedShot:FullRechargeTimeP() < Player:GCD() or Pet:BuffP(S.FrenzyBuff) and Pet:BuffRemainsP(S.FrenzyBuff) <= Player:GCD()) then
      if HR.Cast(S.BarbedShot) then return "barbed_shot 1507"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return "a_murder_of_crows 1517"; end
    end
    -- spitting_cobra
    if S.SpittingCobra:IsCastableP() then
      if HR.Cast(S.SpittingCobra) then return "spitting_cobra 1519"; end
    end
    -- stampede,if=buff.bestial_wrath.up|cooldown.bestial_wrath.remains<gcd|target.time_to_die<15
    if S.Stampede:IsCastableP() and (Player:BuffP(S.BestialWrathBuff) or S.BestialWrath:CooldownRemainsP() < Player:GCD() or Target:TimeToDie() < 15) then
      if HR.Cast(S.Stampede) then return "stampede 1521"; end
    end
    -- aspect_of_the_wild
    if S.AspectoftheWild:IsCastableP() then
      if HR.Cast(S.AspectoftheWild) then return "aspect_of_the_wild 1527"; end
    end
    -- bestial_wrath,if=!buff.bestial_wrath.up
    if S.BestialWrath:IsCastableP() and (not Player:BuffP(S.BestialWrathBuff)) then
      if HR.Cast(S.BestialWrath) then return "bestial_wrath 1529"; end
    end
    -- multishot,if=spell_targets>2&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 2 and (Pet:BuffRemainsP(S.BeastCleaveBuff) < Player:GCD() or Pet:BuffDownP(S.BeastCleaveBuff))) then
      if HR.Cast(S.Multishot) then return "multishot 1533"; end
    end
    -- chimaera_shot
    if S.ChimaeraShot:IsCastableP() then
      if HR.Cast(S.ChimaeraShot) then return "chimaera_shot 1545"; end
    end
    -- kill_command
    if S.KillCommand:IsCastableP() then
      if HR.Cast(S.KillCommand) then return "kill_command 1547"; end
    end
    -- dire_beast
    if S.DireBeast:IsCastableP() then
      if HR.Cast(S.DireBeast) then return "dire_beast 1549"; end
    end
    -- barbed_shot,if=pet.cat.buff.frenzy.down&charges_fractional>1.8|target.time_to_die<9
    if S.BarbedShot:IsCastableP() and (Pet:BuffDownP(S.FrenzyBuff) and S.BarbedShot:ChargesFractionalP() > 1.8 or Target:TimeToDie() < 9) then
      if HR.Cast(S.BarbedShot) then return "barbed_shot 1551"; end
    end
    -- barrage,if=active_enemies>1
    if S.Barrage:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.Barrage) then return "barrage 1559"; end
    end
    -- multishot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
    if S.Multishot:IsCastableP() and (Cache.EnemiesCount[40] > 1 and (Pet:BuffRemainsP(S.BeastCleaveBuff) < Player:GCD() or Pet:BuffDownP(S.BeastCleaveBuff))) then
      if HR.Cast(S.Multishot) then return "multishot 1567"; end
    end
    -- cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost|cooldown.kill_command.remains>1+gcd)&cooldown.kill_command.remains>1
    if S.CobraShot:IsCastableP() and ((Cache.EnemiesCount[40] < 2 or S.KillCommand:CooldownRemainsP() > Player:FocusTimeToMaxPredicted()) and (Player:Focus() - S.CobraShot:Cost() + Player:FocusRegen() * (S.KillCommand:CooldownRemainsP() - 1) > S.KillCommand:Cost() or S.KillCommand:CooldownRemainsP() > 1 + Player:GCD()) and S.KillCommand:CooldownRemainsP() > 1) then
      if HR.Cast(S.CobraShot) then return "cobra_shot 1579"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 1603"; end
    end
  end
end

HR.SetAPL(253, APL)
