--Decode Talker Overclock Sovereign
local s,id=GetID()
function s.initial_effect(c)
	--Link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,4,nil,s.matcheck)
	--Must first be Link Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(aux.lnklimit)
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
	e2:SetCondition(function(e) return e:GetHandler():GetLinkedGroupCount()>0 end)
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
	e4:SetCondition(function(e) return e:GetHandler():GetLinkedGroupCount()>0 end)
	e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e4:SetValue(s.matlimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e7)
	--Increase its own ATK
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetCode(EFFECT_UPDATE_ATTACK)
	e8:SetRange(LOCATION_MZONE)
	e8:SetValue(s.atkval)
	c:RegisterEffect(e8)
	--Negate activated effect
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e9:SetCode(EVENT_CHAIN_SOLVING)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCondition(s.negcon)
	e9:SetOperation(s.negop)
	c:RegisterEffect(e9)
end
s.listed_series={SET_CODE_TALKER}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_CYBERSE,lc,sumtype,tp) and c:IsType(TYPE_LINK,lc,sumtype,tp)
end
function s.matcheck(g,lnkc,sumtype,sp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_CODE_TALKER,lnkc,sumtype,sp)
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.matlimit(e,c)
	if not c then return false end
	return c:GetOwner()~=e:GetHandlerPlayer()
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_LINK)*500
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsMonster() and c:IsType(TYPE_LINK) and c:IsRace(RACE_CYBERSE)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainDisablable(ev) and e:GetHandler():GetFlagEffect(id)==0
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if Duel.GetFlagEffectLabel(tp,id)==cid or not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then return end
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1,cid)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		local lk=tc:GetFirst():GetLink()
		local rc=re:GetHandler()
		if #tc>0 and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
			local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
			if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local sg=dg:Select(tp,1,lk,nil)
				Duel.HintSelection(sg)
				Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end