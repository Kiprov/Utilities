--!strict

export type BeginningMusFormat = {
	Popup: number,
	Popup2: number,
	Begin: number,
	Name: string
}

export type Minutes3Format = {
	StartAfter: number,
	Name: string
}

export type ExpiringFormat = {
	StartAfter: number,
	Name: string
}

export type ExpiredFormat = string

export type FinalFormat = {
	Time: number,
	Name: string
}

return {
	Beginning = {
		{
			Popup = 1.5,
			Popup2 = 13+1.5,
			Begin = 28.75,
			Name = "beginning_wevegothostiles"
		},
		{
			Popup = 0.526,
			Popup2 = 13+.526,
			Begin = 25.789,
			Name = "beginning_trickymazeforlostworld"
		},
		{
			Popup = 0,
			Popup2 = 26.572-13.299,
			Begin = 39.831-13.299,
			Name = "beginning_willtosurvive"
		},
	} :: {BeginningMusFormat},
	Minutes3 = {
		{
			StartAfter = 30.236,
			Name = "minutes3_surfacetension1"
		},
		{
			StartAfter = 17.973,
			Name = "minutes3_cyborgmetalflesh"
		},
	} :: {Minutes3Format},
	Expiring = {
		{
			StartAfter = 14.546,
			Name = "expiring_franticandedgy"
		},
		{
			StartAfter = 3.636,
			Name = "expiring_franticandedgydrums"
		},
		{
			StartAfter = 14.667,
			Name = "expiring_gremlins"
		},
	} :: {ExpiringFormat},
	Expired = {
		"expired_origamicastlerockremix",
		"expired_bossfight",
		"expired_dawnofthemachines",
		"expired_selfdestruct",
		"expired_veryintense"
	} :: {ExpiredFormat},
	Final = {
		{
			Time = 274.286,
			Name = "endMus_wevegothostilesremix"
		},
		{
			Time = 239.04,
			Name = "endMus_roarofthejungledragon"
		},
		{
			Time = 219.759,
			Name = "endMus_attackformation"
		},
		{
			Time = 179,
			Name = "endMus_warwithoutreason"
		},
		{
			Time = 169.411,
			Name = "endMus_order"
		},
		{
			Time = 165.994,
			Name = "endMus_infinity"
		},
		{
			Time = 150.06,
			Name = "endMus_timeoutExtended"
		},
		{
			Time = 139.425,
			Name = "endMus_sevenFive"
		},
		{
			Time = 136.102,
			Name = "endMus_metalscifiuniverse"
		},
		{
			Time = 123.743,
			Name = "endMus_timeout"
		},
		{
			Time = 115.2,
			Name = "endMus_timeoutNoFrontend"
		},
		{
			Time = 111.818,
			Name = "endMus_compassremix"
		},
		{
			Time = 80.84,
			Name = "endMus_chordstackingtest"
		}
	} :: {FinalFormat}
}
