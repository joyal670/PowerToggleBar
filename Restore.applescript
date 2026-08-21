on run
	set scriptPath to (POSIX path of (path to home folder)) & ".powersaver/restore.sh"
	try
		set output to do shell script "/bin/zsh " & quoted form of scriptPath
		display notification output with title "☀️ Restore" subtitle "Back to normal"
	on error errMsg
		display notification errMsg with title "☀️ Restore" subtitle "Something went wrong"
	end try
end run
