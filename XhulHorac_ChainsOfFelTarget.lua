-- Author: Hunter Sadler (Auro)
-- Date: 08/29/2015
-- Version: 2.0
-- Name: XhulHorac_ChainsOfFelTarget

-- This WeakAura tracks the current ChainsOfFel Target while its being casted.
-- It finds someone in the raid who is targetting the caster, and reports back the casters target
-- Since the WeakAura reacts immediatley it often reports the tank, however the tank cannot receive ChainsOfFel
-- It continues to query for the casters target until it finds someone who is not a Tank (Actual Target)
-- If however the raid member being used to query the casters target swaps to a different target in the time frame this may report bad information
-- Generally this reports within 500ms, most often way sooner, the chances of this happening are very slim, but none the less could occur.

-- Trigger (Event [COMBAT_LOG_EVENT_UNFILTERED])
function(_, _, msg, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellID, spellName)
    if (msg == "SPELL_CAST_START" and spellName == "Chains of Fel") then
        -- Reset Variables
        --   This would be better in init, but for some reason init is looping on pull
        auroBM_ChainsRaidCount = GetNumGroupMembers();
        auroBM_ChainsTanks = {};
        auroBM_ChainsOfFelTarget = nil;
        auroBM_ChainsTargetIndex = nil;
        auroBM_ChainsInfoSourceIndex = nil;
        auroBM_ChainsTargetRole = nil;
        -- Reset Finished
        for i = 1, auroBM_ChainsRaidCount do
            -- Find someone targeting Vanguard
            if (GetUnitName("raid" .. i .. "target", false) == "Vanguard Akkelion") then
                -- Return Index
                auroBM_ChainsTargetIndex = i;
                return true
            end
        end
        print("BUTWHY");
        return true;

    elseif (msg == "SPELL_CAST_START" and spellName == "Empowered Chains of Fel") then
        -- Reset
        auroBM_ChainsRaidCount = GetNumGroupMembers();
        auroBM_ChainsTanks = {};
        auroBM_ChainsOfFelTarget = nil;
        auroBM_ChainsTargetIndex = nil;
        auroBM_ChainsInfoSourceIndex = nil;
        auroBM_ChainsTargetRole = nil;
        -- Reset End
        for i = 1, auroBM_ChainsRaidCount do
            -- Find someone targeting Xhul
            if (GetUnitName("raid" .. i .. "target", false) == "Xhul'horac") then
                auroBM_ChainsTargetIndex = i;
                return true
            end
        end
        print("BUTWHYY");
        return true;
    end
end

-- Untrigger
-- Hide in 3 seconds

-- Custom Text [Every Frame]
function()
    -- Check if target has already been set
    if (auroBM_ChainsOfFelTarget == nil and auroBM_ChainsTargetIndex ~= nil) then
        -- Verify it is not going to a tank (they cannot get fel chains)
        auroBM_ChainsInfoSourceIndex = UnitInRaid("raid" .. auroBM_ChainsTargetIndex .. "targettarget");
        _, _, _, _, _, _, _, _, _, _, _,auroBM_ChainsTargetRole = GetRaidRosterInfo(auroBM_ChainsInfoSourceIndex);
        -- print(auroBM_ChainsTargetRole);
        if (auroBM_ChainsTargetRole ~= "TANK") then
            -- Set target, as long as its not a tank
            auroBM_ChainsOfFelTarget = GetUnitName("raid" .. auroBM_ChainsTargetIndex .. "targettarget", false);
        end
        -- print(auroBM_ChainsOfFelTarget);
    end
    -- Print Target
    local auroBM_ChainsPrintMe = auroBM_ChainsOfFelTarget or "?";
    return string.format("%s", auroBM_ChainsPrintMe);
end

-- init
-- CURRENTLY unused
-- I believe its looping because lag is created and the print at the top is looped
-- Clear variables
print("Chains Of Fel Addon Started");

auroBM_ChainsRaidCount = GetNumGroupMembers();
auroBM_ChainsTanks = {};
auroBM_ChainsOfFelTarget = nil;
auroBM_ChainsTargetIndex = nil;
auroBM_ChainsInfoSourceIndex = nil;
auroBM_ChainsTargetRole = nil;

for k,v in ipairs(auroBM_ChainsTanks) do
    auroBM_ChainsTanks[k] = nil;
end

-- Fill tanks into table
for i = 1, AuroBM_ChainsRaidCount do
    local name, _, _, _, _, _, _, _, _, _, z, role = GetRaidRosterInfo(i);
    print(name .. ' - ' .. role .. ' - ' .. z);
    if (role == "TANK") then
        table.insert(AuroBM_ChainsTanks, name);
        print(name);
    end
end

-- Hide
-- CURRENTLY unused
-- If I could get init to work, then I could reset on hide here, and remove redudent reset from Trigger
-- Clear variables
auroBM_ChainsRaidCount = GetNumGroupMembers();
auroBM_ChainsOfFelTarget = nil;
auroBM_ChainsTargetIndex = nil;
auroBM_ChainsInfoSourceIndex = nil;
auroBM_ChainsTargetRole = nil;

print("All Clear!");

-- WeakAura string
d80RxaqivuIwKc6sQOK(KsinkfXPuGzrvClkyxOcddjQJPIQLrvINPeyAkjCnLeTnKi9nkk14OOKZPeQEhQ09Oi)tji5Guu1cjPEOQyIOI6IuuzJuL6JkrnskkYjvrwjrVufLQzIQkUjfANiHFsvsdvjuwkQkpvrnvvPRIQQ2Qsi(QsqmwuvjolQQuVvji1DvrjSxv1FPQgmCyclwjYJvsnzf6Yi2mj5ZiPrRcNMsRgvvsVgvKztIBJQSBu(TsnCfPLtLNRstNuxhP2oseFNIcgVssNxffRxjOEpffA(QOuUpff1(L)N)F)Z8(ZJ)5X)7Fw1MPNTlm5tXc8YFE9wz7(VFko)tbL)u4LV3ukLs5v6fZEXxXkxWkmBk1S9Yk(QmSYf8PybFVxHzr5fywlyXPuk7Lv6fZALl48VkdRKs)6)8O9ovrCMxYQ6)8zD9FEn9vV59swv)NvrZwRTB2KbjdHqWGHWZbznNcwvbTWrLOdhIBqO4iIXZewIqyHlrNmecbRQWebTBR2O)ZHWYUEvL3eLxHJkrhmzkWSkbbBmiODB1g9Foew29v4Os0NyJKvdD2mfywLbb9bHLmecHqiesgcHqiecgmeweIZQ6mbRoyVb2whOUTmQb9oicAbJtHj6dYzcRfm2whOs0bveLW6dHLDhKmecHqiee0UTAJ(phcl7EIPApVPDRjNyJKvdMc8Nz1Ny8jSJtg6e2XHbo4iiODB1g9Foew29v4Os0NyJKvdCWryOw4Os0AHJkrpCa3KHqiecHGVNGVNGVNGVNGVNGVNGVNGVNGVNGVNGVhbTBR2O)ZHWYUVchvIMVTcjykSmrZNWoY3(QjUtmv7jcA3wTr)NdHLDpXuTN30U1KtSrYQd4MmecHqieM6Sm9ebTBR2O)ZHWYUVchvIMVTcza3KHqiecHqYqiecHqWQkmrq72Qn6)CiSS7RWrLO5BRqcD2mfg(AEko7dhe0hewYqiecHqiecbdgcZeDqlCujApbXnOSzudIBWQVb2whebTGXPKHqiecHqieccA3wTr)NdHLD9QkVjkVchvIoykSmrZFMvtHGhzYqNWoomWbhbbTBR2O)ZHWYUVchvI(eBKSAGdocd1chvIwlCuj6HEcQekxYaUHqYqiecHqGWgtgcHqiecjdHqiecHPoltprq72Qn6)CiSSRxv5nr5v4Os0d4MmecHqiesgcHaHnMmecHKHqiyWqyXCwMo8kCuj6KHqiOSxluccA3wTr)NdHLDxmNLPnscMccA3wTr)NdHLD9QkVjkVchvIoSDHHlud5Mmecbhrt7yHR2zzu5q12XtONm8SEh6jiODB1g9Foew2DXCwM2iza3KHqiKKWgtMmzYKjtMmzYKjtMmzYKjtMmzYKjtMmzYKjtMmzYKjtM8p7iuTB27zMs(ZAYQ6)SLz1(R38MQq0KXpfN)NfR12n7(F)ZQSm794)(Nh3(RPV6nV)s)510x9M3F2GHWJcr4cuIWzflPqUjf0UTAJ(phcl7YNWo(SPz6GPWYenf08w2TPNAKWBjI7oza3KcA3wTr)NdHLD9QkVjkVchvIoykWSkCtkODB1g9Foew29v4Os0NyJKvdMcmRc3KcA3wTr)NdHLDpXuTN30U1KtSrYQbtbMvHBsbTBR2O)ZHWYUVchvIMVTcjykWSkCtMCQZY0tgAEfLWJcr4olhoGBYKjtMmzYKjtMm5x)NTmR()(Nh3(RPV6nV)s)510x9M3F2GHWJcr4cuIWzflPqUjN6Sm9KHphcl7g8QQG3eLG5hh3SWSw40KXHd4MmPG2TvB0)5qyzx(e2XNnnthmfwMOPGM3YUn9uJeElrC3jd4Muq72Qn6)CiSS7RGXPBWuWmAM5Muq72Qn6)CiSSRxv5nr5v4Os0btbMvHBsbTBR2O)ZHWYUVchvI(eBKSAWuGzv4Muq72Qn6)CiSS7jMQ98M2TMCInswnykWSkCtkODB1g9Foew29v4Os08TvibtbMvHBYKQ2UaN8qjbllyNkSU7ebTBR2O)ZHWYUVcgNUdcJ7KHqiiODB1g9Foew29vW40DHMtNfbtbMvHBscBmzsdgcEBvucAbJt3GLP3bTyjfssvBxWgmfo3tW80UTAJ(phcl7YNWo(SPz6W4ozieck71cLatWJ4j47j47j47j47j47j47j47j47j47jSWEcUTcjykSmrZNWoY3(QjUtmv7j2bCtgcHWuNLPNWe8ibo4iSObdHfnWbhb3wHe4GJWIgmew0ahCew4bCtgcHGvvyIBRqcMmfg(AEko7dhe0hewYqiecHqqlwsHWHLDjo9eZt72Qn6)CiSS7RGXPRNatWJmGBYqiecHqyQZY0tycEKbCtgcHaHnMKWg)6V(plghTA7Mju81olvQe39)(1)z(v6R2Q6m)5hZrXR547pRDwQujU)7FEK2j02n7pVG)8A6REZZ)Wos(ZAlpY4FwFMPK)8A6REZ7pVM(Q3881Nzk5ptOect)NVtjkkui4r(Zphcl7g2QcEtu(Z0xIpnZQ)Q)ZekHW0)5NnVLe6a)SP(NjucHPV)5hVAuT5F95hVUSV5weZrXRp)PW7t8ZR54ZCC(ptZiucHP)ZAlpY4FM(s8Vtjkkui4r(Q)ZRPV6nV)SkA2ATDZM47j47jW7s1tW3t46wVm)pXzpHRBnfcEepbFpbFpHrYvVm)pXzpHrYvtHGhXtW3tW3t4oLOOCIZEc3Peffke8idsgcHGvvycVl1GjtHHZlM54h(X)X8ZV(ZVMNV3HbbBmCNsuuOqWJemzkm85qyz3WwvWBIYWbb9bHLmecHqiesgcHqiecgme4mzjAQjdHqiecHPoltp56wVm)pX5bCtgcHqiectDwMEY1TMcbpYaUjdHqiecbdgctDwMEYi5QxM)N48aUjdHqiecbdgctDwMEYi5QPqWJmGBYqiecHqyQZY0tUtjkkN48aUjdHqiecHPoltp5oLOOqHGhza3KHqiecHGbdbotwIMAWCSXKHqiecHqYqiecHqWGHaFKlrhweHZkwsHCtgcHqiecgmecH3d7nyg20kJHLiHLiAnXfSSGLz1EclrRdQ2UWDZJeCeXDZcwMvhS3GYEp1YOg2SWuAfLKHqiecHGG2TvB0)5qyzx(e2XNnnthmfwMOPGM3YUn9uJeElrC3jd4MmecHqiee0UTAJ(phcl7(kyC6gmfmJMzUjdHqiecbbTBR2O)ZHWYUEvL3eLxHJkrhmfywfUjdHqiecbbTBR2O)ZHWYUVchvI(eBKSAWuGzv4MmecHqiee0UTAJ(phcl7EIPApVPDRjNyJKvdMcmRc3KHqiecHGG2TvB0)5qyz3xHJkrZ3wHemfywfUjdHqiecbdgc8rUeDWBlZEpiJjdHqiecHKHqiecHGQTlydMcN7jiODB1g9Foew2LpHD8ztZ0HXDYqiecHqiecbdgcEBzJH7MhzZibTWrLOTmQHfrWOslCJjdHqiecHqieSQctwMO5pZQPqWJmzOtyhhg4GJGnWbhHHAHJkrp0tqLq5sgemzkmCremQ0c3yW8CItef7MnCqqFqyjdHqiecHqiecHqWGHaFenTJfoXgjRMmecHqiecHqiecbbTBR2O)ZHWYUVchvI(eBKSAWuWYnziecHqiecHqiecoIM2XcAhnjziecHqiecHaHnMmecHqieiSXKHqiecHqYqiecHqyQZY0tgQM)VleZe)E4aUjdHqiecbhrt7ybTJMWnziecHqiKmecbIYLyvfMW7snyYuy48Izo(HF8Fm)8R)8R557DyqWgd3Peffke8ibtMcdnhVPBZaXrgdphcl7g2QcEtugoiOpiSKHqiecHqYqiecHqWGHaNjlrtnziecHqim1zz6jx36L5)jopGBYqiecHqyQZY0tUU1ui4rgWnziecHqiyWqyQZY0tgjx9Y8)eNhWnziecHqiyWqyQZY0tgjxnfcEKbCtgcHqiectDwMEYDkrr5eNhWnziecHqim1zz6j3Peffke8id4MmecHqiemyiWzYs0udMJnMmecHqiesgcHqiecgme4JCj6KHqiecHGG2TvB0)5qyzx(e2XNnnthmfwMOPGM3YUn9uJeElrC3jd4MmecHqiee0UTAJ(phcl7(kyC6gmfmJMzUjdHqiecbbTBR2O)ZHWYUEvL3eLxHJkrhmfywfUjdHqiecbbTBR2O)ZHWYUVchvI(eBKSAWuGzv4MmecHqiee0UTAJ(phcl7EIPApVPDRjNyJKvdMcmRc3KHqiecHGG2TvB0)5qyz3xHJkrZ3wHemfywfUjdHqiecbdgc8rUeDWCSXKHqiecHqYqiecHqq12fSbtHZ9ee0UTAJ(phcl7YNWo(SPz6W4oziecHqiecHGbdbVTSXWDZJSzKGw4Os0wg1a)YbTsYqiecHqiecbRQWKLjA(ZSAke8itg6e2XHbo4iydCWryOw4Os0d9eujuUKbbtMcd5xoOvw0JTtSE4GG(GWsgcHqiecHqiecHGG2TvB0)5qyz3xHJkrFInswnyky5gcHqiKmecHqiecHqiecbhrt7ybTJMKmecHqiecHqGWgtgcHqiece2yYqiecHqiziecHqim1zz6jdvZ)3fIzIFZVhoGBYqiecHqWr00owq7OjCtgcHaHnMKWgtMmzYKjtMmzYKjtMmzYKjtMmzYKjtMmzYKjtMmzYKjtMmzYKjtMmzYV(pBgSJ6JV3RCXpNYlUzD(kwCk7LvSskDbE5RYWkmR)mJM3RZsLkXD)uC(F(GyPEO)EVIvs5fqPuMYMnLp)8Z9Yc8cL)QmScZ(pRSfJ)3)8cVzK)SzIOOOY6iHhRwmsu(Ze26nnttC2X)85MfLP8FM(s8jS1BAMM4SJF1)5rRkv210k6Z8F)Z8Ov02)7x)1)z3wH8F)Z8Ov02)7x)1)zTqHW0)3)mpAfT9)(1F9F2jwt(V)zE0kA7)9R)6)m9L4VWBg5R(R)Z2X)8ZHWYUHTQG3eLWKfIWXSmQd(6)89p7fooNdkZHz)NPKpfNVcVC(x))a
