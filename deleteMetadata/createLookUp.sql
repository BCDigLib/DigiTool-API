select hc.PID || '|' || hm.mid 
from D31_REP00.HDECONTROL hc
,D31_REP00.HDEPIDMID hp
,D31_REP00.HDEMETADATA hm
where hc.pid = hp.pid
and hp.mid = hm.mid
and hm.MDID = '9'
-- 9  = MARC
-- 20 = MODS
and hc.OWNER = 'BCD01'
-- logic to create set goes here