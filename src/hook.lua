-- Disable the Custom Third Person POV when a cutscene is about to play
HookFunction("LoadCutscene", function()
	SIMPLE_CUSTOM_THIRD_PERSON.GetSingleton():SetEnabled(false)
end)
