--Blue-Flames Demonic King
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterSummonCode(130901024),1,1,Synchro.NonTunerEx(s.sfilter),2,2)
	c:EnableReviveLimit()
	--splimit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetCost(s.spcost)
	c:RegisterEffect(e0)
	--Unnafected by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--Cannot release
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)
	--Cannot be material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e4:SetValue(s.matlimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e5)
	--act limit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetTargetRange(0,1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.actcon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	--Can attack all monsters
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_ATTACK_ALL)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	--Piercing
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e8)
end
s.material={130901024}
s.listed_names={130901024}
s.listed_series={0xf10}
function s.sfilter(c,val,scard,sumtype,tp)
	return c:IsSetCard(0xf10,scard,sumtype,tp) and c:IsOriginalLevel(8,scard,sumtype,tp)
end
function s.splimitfilter1(c)
	return c:IsSpell() and c:IsType(TYPE_FIELD) and c:IsSetCard(0xf10)
end
function s.splimitfilter2(c)
	return c:IsMonster() and c:IsSetCard(0xf10)
end
function s.splimitfilter3(c)
	return c:IsSpell() and c:IsSetCard(0xf10)
end
function s.spcost(e,c,tp,st)
	if (st&SUMMON_TYPE_SYNCHRO)~=SUMMON_TYPE_SYNCHRO then return true end
	return Duel.IsExistingMatchingCard(s.splimitfilter1,tp,LOCATION_ONFIELD,0,1,nil) and
		Duel.IsExistingMatchingCard(s.splimitfilter2,tp,LOCATION_GRAVE,0,1,nil) and
		Duel.IsExistingMatchingCard(s.splimitfilter3,tp,LOCATION_GRAVE,0,1,nil)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner() and not te:GetOwner():IsSetCard(0xf10)
end
function s.matlimit(e,c)
	if not c then return false end
	return c:GetOwner()~=e:GetHandlerPlayer()
end
function s.actcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end