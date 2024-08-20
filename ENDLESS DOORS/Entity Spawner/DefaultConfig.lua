return {
	Entity = {
		HeightOffset = 0,
		SmoothTransition = true,
	},
	Lights = {
		Flicker = {
			Enabled = true,
			Duration = 1
		},
		Shatter = true
	},
	CameraShake = {
		Enabled = true,
		Range = 100,
		Values = {1.5, 20, 0.1, 1},
	},
	Movement = {
		Speed = 100,
		Delay = 2,
		Reversed = false
	},
	Rebounding = {
		Enabled = false,
		Type = "Ambush",
		Min = 1,
		Max = 1,
		Delay = 2
	},
	Damage = {
		Enabled = true,
		Range = 50,
		Amount = 125
	},
	Death = {
		Hints = {}
	},
	Crucifixion = {
		Enabled = true,
		Repent = "None",
		Resist = false
	},
	Visualization = {
		Enabled = false,
	}
}
