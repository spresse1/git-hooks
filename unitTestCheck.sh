#! /bin/bash

# This script is intended to check for and run unit tests for files in a 
# repository.  It does this by looking for a makefile in the root directory,
# then running "make test".  It then checks the error code returned by the
# test - if nonzero, the tests did not pass, a failure is generated and the
# commit aborted.
# pass --ignore failure to ignore failures and let the action continue.  This
# is useful if running this as a pre-commit (ie: client side) test, where the
# user may be making intermediate commits before making additional changes."""

PASS=0

while [ $1 ];
do
	if [ "$1" =  "--pass" ]
	then
		PASS=1
	fi
	shift
done

COMMIT=`git rev-parse --verify HEAD`
if [ $? -ne 0 ]
then
	echo "Failed to find revision identifier for HEAD! Failing."
	exit 1
fi


TEMPDIR=`mktemp -d`
if [ $? -ne 0 ]
then
	echo "Failed to create temporary directory. Failing."
	exit 1
fi

echo "Testing commit ${COMMIT} in ${TEMPDIR}".

git checkout-index --prefix="$TEMPDIR/" -af
if [ $? -ne 0 ]
then
	echo "Copying 'pure' repo to tempdir failed.  Exiting."
	exit 1
fi

make test
EXITSTAT=$?

if [ $EXITSTAT -ne 0 ]
then
	echo "Unit test failure!  See above for logs. Status: ${EXITSTAT}"
	#PASS==0 indicates flag was not passed, therefore should actually bomb
	if [ $PASS -ne 0 ]
	then
		exit $EXITSTAT
	fi
else
	echo "Unit tests passed.  Congratulations!"
fi

rm -rf "${TEMPDIR}"
