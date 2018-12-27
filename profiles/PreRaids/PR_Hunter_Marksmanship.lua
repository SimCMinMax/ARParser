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
Spell.Hunter.Marksmanship = {
  SummonPet                             = Spell(),
  HuntersMarkDebuff                     = Spell(185365),
  HuntersMark                           = Spell(),
  DoubleTap                             = Spell(),
  TrueshotBuff                          = Spell(193526),
  Trueshot                              = Spell(193526),
  AimedShot                             = Spell(19434),
  UnerringVisionBuff                    = Spell(),
  UnerringVision                        = Spell(),
  CallingtheShots                       = Spell(),
  SurgingShots                          = Spell(),
  Streamline                            = Spell(),
  FocusedFire                           = Spell(),
  RapidFire                             = Spell(),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  CarefulAim                            = Spell(),
  ExplosiveShot                         = Spell(212431),
  Barrage                               = Spell(120360),
  AMurderofCrows                        = Spell(131894),
  SerpentSting                          = Spell(271788),
  SerpentStingDebuff                    = Spell(271788),
  ArcaneShot                            = Spell(185358),
  MasterMarksmanBuff                    = Spell(),
  PreciseShotsBuff                      = Spell(),
  IntheRhythm                           = Spell(),
  PiercingShot                          = Spell(198670),
  SteadyShot                            = Spell(),
  TrickShotsBuff                        = Spell(),
  Multishot                             = Spell(2643)
};
local S = Spell.Hunter.Marksmanship;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Marksmanship = {
  ProlongedPower                   = Item(142117)
};
local I = Item.Hunter.Marksmanship;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Hunter.Commons,
  Marksmanship = HR.GUISettings.APL.Hunter.Marksmanship
};


local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

S.SerpentSting:RegisterInFlight()

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function TargetDebuffRemainsP (Spell, AnyCaster, Offset)
  if Spell == S.Vulnerability and (S.Windburst:InFlight() or S.MarkedShot:InFlight() or Player:PrevGCDP(1, S.Windburst, true)) then
    return 7;
  else
    return DebuffRemainsP(Spell);
  end
end

local function TargetDebuffP (Spell, AnyCaster, Offset)
  if Spell == S.Vulnerability then
    return DebuffP(Spell) or S.Windburst:InFlight() or S.MarkedShot:InFlight() or Player:PrevGCDP(1, S.Windburst, true);
  elseif Spell == S.HuntersMark then
    return DebuffP(Spell) or S.ArcaneShot:InFlight(S.MarkingTargets) or S.MultiShot:InFlight(S.MarkingTargets) or S.Sidewinders:InFlight(S.MarkingTargets);
  else
    return DebuffP(Spell);
  end
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Cds, St, Trickshots
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- summon_pet,if=active_enemies<3
    if S.SummonPet:IsCastableP() and (Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.SummonPet) then return "summon_pet 3"; end
    end
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 12"; end
    end
    -- hunters_mark
    if S.HuntersMark:IsCastableP() and Player:DebuffDownP(S.HuntersMarkDebuff) then
      if HR.Cast(S.HuntersMark) then return "hunters_mark 14"; end
    end
    -- double_tap,precast_time=10
    if S.DoubleTap:IsCastableP() then
      if HR.Cast(S.DoubleTap) then return "double_tap 18"; end
    end
    -- trueshot,precast_time=1.5,if=active_enemies>2
    if S.Trueshot:IsCastableP() and Player:BuffDownP(S.TrueshotBuff) and (Cache.EnemiesCount[40] > 2) then
      if HR.Cast(S.Trueshot) then return "trueshot 20"; end
    end
    -- aimed_shot,if=active_enemies<3
    if S.AimedShot:IsCastableP() and (Cache.EnemiesCount[40] < 3) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 38"; end
    end
  end
  Cds = function()
    -- hunters_mark,if=debuff.hunters_mark.down
    if S.HuntersMark:IsCastableP() and (Target:DebuffDownP(S.HuntersMarkDebuff)) then
      if HR.Cast(S.HuntersMark) then return "hunters_mark 46"; end
    end
    -- double_tap,if=target.time_to_die<15|cooldown.aimed_shot.remains<gcd&(buff.trueshot.up&(buff.unerring_vision.stack>7|!azerite.unerring_vision.enabled)|!talent.calling_the_shots.enabled)&(!azerite.surging_shots.enabled&!talent.streamline.enabled&!azerite.focused_fire.enabled)
    if S.DoubleTap:IsCastableP() and (Target:TimeToDie() < 15 or S.AimedShot:CooldownRemainsP() < Player:GCD() and (Player:BuffP(S.TrueshotBuff) and (Player:BuffStackP(S.UnerringVisionBuff) > 7 or not S.UnerringVision:AzeriteEnabled()) or not S.CallingtheShots:IsAvailable()) and (not S.SurgingShots:AzeriteEnabled() and not S.Streamline:IsAvailable() and not S.FocusedFire:AzeriteEnabled())) then
      if HR.Cast(S.DoubleTap) then return "double_tap 50"; end
    end
    -- double_tap,if=cooldown.rapid_fire.remains<gcd&(buff.trueshot.up&(buff.unerring_vision.stack>7|!azerite.unerring_vision.enabled)|!talent.calling_the_shots.enabled)&(azerite.surging_shots.enabled|talent.streamline.enabled|azerite.focused_fire.enabled)
    if S.DoubleTap:IsCastableP() and (S.RapidFire:CooldownRemainsP() < Player:GCD() and (Player:BuffP(S.TrueshotBuff) and (Player:BuffStackP(S.UnerringVisionBuff) > 7 or not S.UnerringVision:AzeriteEnabled()) or not S.CallingtheShots:IsAvailable()) and (S.SurgingShots:AzeriteEnabled() or S.Streamline:IsAvailable() or S.FocusedFire:AzeriteEnabled())) then
      if HR.Cast(S.DoubleTap) then return "double_tap 68"; end
    end
    -- berserking,if=cooldown.trueshot.remains>60
    if S.Berserking:IsCastableP() and HR.CDsON() and (S.Trueshot:CooldownRemainsP() > 60) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 86"; end
    end
    -- blood_fury,if=cooldown.trueshot.remains>30
    if S.BloodFury:IsCastableP() and HR.CDsON() and (S.Trueshot:CooldownRemainsP() > 30) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 90"; end
    end
    -- ancestral_call,if=cooldown.trueshot.remains>30
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (S.Trueshot:CooldownRemainsP() > 30) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 94"; end
    end
    -- fireblood,if=cooldown.trueshot.remains>30
    if S.Fireblood:IsCastableP() and HR.CDsON() and (S.Trueshot:CooldownRemainsP() > 30) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 98"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 102"; end
    end
    -- potion,if=buff.trueshot.react&buff.bloodlust.react|buff.trueshot.up&target.health.pct<20&talent.careful_aim.enabled|target.time_to_die<25
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (bool(Player:BuffStackP(S.TrueshotBuff)) and Player:HasHeroism() or Player:BuffP(S.TrueshotBuff) and Target:HealthPercentage() < 20 and S.CarefulAim:IsAvailable() or Target:TimeToDie() < 25) then
      if HR.CastSuggested(I.ProlongedPower) then return "prolonged_power 104"; end
    end
    -- trueshot,if=cooldown.rapid_fire.remains&target.time_to_die>cooldown.trueshot.duration_guess+duration|(target.health.pct<20|!talent.careful_aim.enabled)|target.time_to_die<15
    if S.Trueshot:IsCastableP() and (bool(S.RapidFire:CooldownRemainsP()) and Target:TimeToDie() > cooldown.trueshot.duration_guess + S.TrueshotBuff:BaseDuration() or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable()) or Target:TimeToDie() < 15) then
      if HR.Cast(S.Trueshot) then return "trueshot 112"; end
    end
  end
  St = function()
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return "explosive_shot 126"; end
    end
    -- barrage,if=active_enemies>1
    if S.Barrage:IsCastableP() and (Cache.EnemiesCount[40] > 1) then
      if HR.Cast(S.Barrage) then return "barrage 128"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return "a_murder_of_crows 136"; end
    end
    -- serpent_sting,if=refreshable&!action.serpent_sting.in_flight
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not S.SerpentSting:InFlight()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 138"; end
    end
    -- arcane_shot,if=buff.master_marksman.up&focus+cast_regen<focus.max
    if S.ArcaneShot:IsCastableP() and (Player:BuffP(S.MasterMarksmanBuff) and Player:Focus() + Player:FocusCastRegen(S.ArcaneShot:ExecuteTime()) < Player:FocusMax()) then
      if HR.Cast(S.ArcaneShot) then return "arcane_shot 152"; end
    end
    -- aimed_shot,if=buff.precise_shots.down|cooldown.aimed_shot.full_recharge_time<action.aimed_shot.cast_time|buff.bloodlust.up&buff.trueshot.up
    if S.AimedShot:IsCastableP() and (Player:BuffDownP(S.PreciseShotsBuff) or S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime() or Player:HasHeroism() and Player:BuffP(S.TrueshotBuff)) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 162"; end
    end
    -- rapid_fire,if=focus+cast_regen<focus.max|azerite.focused_fire.enabled|azerite.in_the_rhythm.rank>1|azerite.surging_shots.enabled|talent.streamline.enabled|buff.trueshot.up
    if S.RapidFire:IsCastableP() and (Player:Focus() + Player:FocusCastRegen(S.RapidFire:ExecuteTime()) < Player:FocusMax() or S.FocusedFire:AzeriteEnabled() or S.IntheRhythm:AzeriteRank() > 1 or S.SurgingShots:AzeriteEnabled() or S.Streamline:IsAvailable() or Player:BuffP(S.TrueshotBuff)) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 174"; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return "piercing_shot 192"; end
    end
    -- arcane_shot,if=focus>60|buff.precise_shots.up
    if S.ArcaneShot:IsCastableP() and (Player:Focus() > 60 or Player:BuffP(S.PreciseShotsBuff)) then
      if HR.Cast(S.ArcaneShot) then return "arcane_shot 194"; end
    end
    -- steady_shot
    if S.SteadyShot:IsCastableP() then
      if HR.Cast(S.SteadyShot) then return "steady_shot 198"; end
    end
  end
  Trickshots = function()
    -- barrage
    if S.Barrage:IsCastableP() then
      if HR.Cast(S.Barrage) then return "barrage 200"; end
    end
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return "explosive_shot 202"; end
    end
    -- rapid_fire,if=buff.trick_shots.up&(azerite.focused_fire.enabled|azerite.in_the_rhythm.rank>1|azerite.surging_shots.enabled|talent.streamline.enabled)
    if S.RapidFire:IsCastableP() and (Player:BuffP(S.TrickShotsBuff) and (S.FocusedFire:AzeriteEnabled() or S.IntheRhythm:AzeriteRank() > 1 or S.SurgingShots:AzeriteEnabled() or S.Streamline:IsAvailable())) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 204"; end
    end
    -- aimed_shot,if=buff.trick_shots.up&(buff.precise_shots.down|cooldown.aimed_shot.full_recharge_time<action.aimed_shot.cast_time)
    if S.AimedShot:IsCastableP() and (Player:BuffP(S.TrickShotsBuff) and (Player:BuffDownP(S.PreciseShotsBuff) or S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime())) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 216"; end
    end
    -- rapid_fire,if=buff.trick_shots.up
    if S.RapidFire:IsCastableP() and (Player:BuffP(S.TrickShotsBuff)) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 228"; end
    end
    -- multishot,if=buff.trick_shots.down|buff.precise_shots.up|focus>70
    if S.Multishot:IsCastableP() and (Player:BuffDownP(S.TrickShotsBuff) or Player:BuffP(S.PreciseShotsBuff) or Player:Focus() > 70) then
      if HR.Cast(S.Multishot) then return "multishot 232"; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return "piercing_shot 238"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows) then return "a_murder_of_crows 240"; end
    end
    -- serpent_sting,if=refreshable&!action.serpent_sting.in_flight
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not S.SerpentSting:InFlight()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 242"; end
    end
    -- steady_shot
    if S.SteadyShot:IsCastableP() then
      if HR.Cast(S.SteadyShot) then return "steady_shot 256"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_shot
    -- use_items,if=buff.trueshot.up|!talent.calling_the_shots.enabled|target.time_to_die<20
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=st,if=active_enemies<3
    if (Cache.EnemiesCount[40] < 3) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=trickshots,if=active_enemies>2
    if (Cache.EnemiesCount[40] > 2) then
      local ShouldReturn = Trickshots(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(254, APL)
