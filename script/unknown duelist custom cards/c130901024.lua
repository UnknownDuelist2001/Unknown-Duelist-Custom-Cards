--Blue-Flames Demonic Controller: Hades
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(s.indes)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Provide an effect to a "Blue-Flames" Fusion, Synchro, Xyz or Link Monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.mtcon)
	e3:SetOperation(s.mtop)
	c:RegisterEffect(e3)
end
s.listed_names={130901030}
s.listed_series={0xf10}
s.counter_list={0xf10}
function s.indes(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.thfilter(c)
	return (c:IsSpell() and not (c:IsType(TYPE_FIELD) or c:IsType(TYPE_RITUAL))) and c:IsSetCard(0xf10) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local c=e:GetHandler()
	--Cannot attack, except with "Blue-Flames" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return not c:IsSetCard(0xf10) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r & (REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc:IsSetCard(0xf10) then return end
	--Banish 1 random card from your opponent's hand, face-down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCost(s.hdcost)
	e1:SetTarget(s.hdtg)
	e1:SetOperation(s.hdop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
end
function s.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0xf10,5,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0xf10,5,REASON_COST)
end
function s.hdfilter(c)
	return c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT)
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.hdfilter,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.hdfilter,tp,0,LOCATION_HAND,nil)
	if #g>0 then
		local sg=g:RandomSelect(tp,1)
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	end
end