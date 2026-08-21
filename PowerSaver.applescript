on run
	set scriptPath to (POSIX path of (path to home folder)) & ".powersaver/powersave.sh"
	try
		set output to do shell script "/bin/zsh " & quoted form of scriptPath
		display notification output with title "🔋 PowerSaver" subtitle "Battery optimized"
	on error errMsg
		display notification errMsg with title "🔋 PowerSaver" subtitle "Something went wrong"
	end try
end run
