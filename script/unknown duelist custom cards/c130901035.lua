--Network Ramsom
local s,id=GetID()
function s.initial_effect(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={SET_CYNET}
function s.cfilter(c)
	return ((c:IsMonster() and c:IsRace(RACE_CYBERSE)) or (c:IsSpellTrap() and c:IsSetCard(SET_CYNET))) and c:IsFaceup()
end
function s.cfilter2(c)
	return (c:IsMonster() and c:IsType(TYPE_EFFECT) and c:IsRace(RACE_CYBERSE) and not c:IsCode(id)) and c:IsAbleToRemove()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return(((loc==LOCATION_HAND or loc==LOCATION_GRAVE) and re:IsActiveType(TYPE_MONSTER) and rp==1-tp)
		or (rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsStatus(STATUS_ACT_FROM_HAND))
		or (rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetActivateLocation()==LOCATION_GRAVE))
		and Duel.IsChainDisablable(ev) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_DECK,0,1,e:GetHandler()) and Duel.GetTurnPlayer()==tp
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
			--Skip your next Battle Phase
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SKIP_BP)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			if Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() then
				e1:SetLabel(Duel.GetTurnCount())
				e1:SetCondition(function(e) return Duel.GetTurnCount()~=e:GetLabel() end)
				e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,2)
			else
				e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,1)
			end
			Duel.RegisterEffect(e1,tp)
			Duel.SetLP(1-tp,Duel.GetLP(1-tp)*2)
		end
		local c=e:GetHandler()
		--Cannot activate monsters effects from the hand
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetValue(s.aclimit)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		--Cannot Special Summon, except Cyberse monsters
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetTargetRange(1,0)
		e3:SetTarget(function(e,c) return not c:IsRace(RACE_CYBERSE) end)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_SUMMON)
		Duel.RegisterEffect(e4,tp)
	end
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return (rc and rc:IsLocation(LOCATION_HAND|LOCATION_GRAVE) and re:IsMonsterEffect())
		or (re:GetActivateLocation()==LOCATION_HAND and re:IsSpellTrapEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE))
		or (re:GetActivateLocation()==LOCATION_GRAVE and re:IsSpellTrapEffect())
end