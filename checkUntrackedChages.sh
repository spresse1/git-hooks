# This script checks for untracked files in the repo.  It will not block
# commit, but is intended to assist forgetful developers in making complete
# commits

FCOUNT=`git ls-files --other --exclude-standard | wc -l`

if [ "${FCOUNT}" != "0" ]
then
	echo "The following files are untracked as of this commit."
	git ls-files --other --exclude-standard
	read -p "Is the above correct? [Y/n]" ANS
	if [[ "${ANS}"  != "" && "${ANS}" != "y" && "${ANS}" != "Y" ]]
	then
		exit 1
	fi
fi

#Next, modified, but unchecked files.
FILES=`git ls-files -m`
IFS=$'\n' read -d '' -r -a LINES <<< "$FILES"
echo $LINES
# read output of command (lists modified and not added files)
for LINE in $LINES
do
	echo "File ${LINE} has untracked changes."
	read -p "Abort commit? [y/N/(d)iff]" STR
	while [[ "$STR" != "" && "$STR" != "n" && "$STR" != "N" ]];
	do
		if [[ "$STR" = "y" || "$STR" = "Y" ]]
		then
			exit 1
		fi
		if [[ "$STR" = "d" || "$STR" = "D" ]]
		then
			git diff "$LINE"
		fi

		read -p "Abort commit? [y/N/(d)iff]" STR
	done
done
