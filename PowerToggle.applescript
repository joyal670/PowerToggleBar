on run
	set scriptPath to (POSIX path of (path to home folder)) & ".powersaver/toggle.sh"
	try
		set output to do shell script "/bin/zsh " & quoted form of scriptPath
		display notification output with title "⚡ Power Toggle"
	on error errMsg
		display notification errMsg with title "⚡ Power Toggle" subtitle "Something went wrong"
	end try
end run
