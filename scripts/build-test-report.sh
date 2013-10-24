# run:
# sh scripts/build-test-report.sh

# I/O redirection
rm -f build-test-report.log
exec 1> build-test-report.log 2>&1

# env settings
export LC_CTYPE="C"
export PATH=/afs/cern.ch/user/m/mad/madx/madX:$PATH

# setup
thedate=`date "+%Y-%m-%d"`
olddate=`date -d "-50 days" "+%Y-%m-%d"`

clean_tmp ()
{
	rm -f *.tmp
}

clean_exit ()
{
	clean_tmp
	exit
}

# check for finished jobs [lxplus | macosx | windows]
build_test_check ()
{
	for arch in "$@" ; do
		if [ ! -s build-test-$arch.run ] || [ "`cat build-test-$arch.run`" != "finished" ] ; then
			clean_exit
		fi
	done
}

# look for failed tests [lxplus | macosx | windows]
build_test_report ()
{
	for arch in "$@" ; do
		if [ ! -s build-test-$arch.out ] ; then
			echo "ERROR: report build-test-$arch.out not found (or empty) for platform $arch"
		else
			rm -f tests/reports/${olddate}_build-test-$arch.out
			cp -f build-test-$arch.out tests/reports/${thedate}_build-test-$arch.out
			[ "$?" != "0" ] && echo "ERROR: backup of build-test-$arch.out failed (check cp)"

			perl -ne '/: FAIL|ERROR: / && print' build-test-$arch.out > $arch-failed.tmp
			[ "$?" != "0" ] && echo "ERROR: unable to search for failures or errors (check perl)"

			if [ -s $arch-failed.tmp ] ; then
				perl -ne '/: FAIL|ERROR: / && print ; /-> (madx-\S+)/ && print "\n$1:\n"' build-test-$arch.out >> tests-failed.tmp
				[ "$?" != "0" ] && echo "ERROR: unable to build report summary (check perl)"
			fi
		fi
	done
}

# send reports summary by email if needed [lxplus | macosx | windows]
build_test_send ()
{
	if [ -s tests-failed.tmp ] ; then
		echo "===== Tests Failed ====="                > build-test-report.out
		date                                          >> build-test-report.out
		echo "For details, see report files:"         >> build-test-report.out
		for arch in "$@" ; do
			echo "http://cern.ch/madx/madX/tests/reports/${thedate}_build-test-$arch.out" >> build-test-report.out
		done
		echo "http://cern.ch/madx/madX/tests/reports" >> build-test-report.out
		cat tests-failed.tmp                          >> build-test-report.out
		sync
		cat -v build-test-report.out | mail -s "MAD-X builds and tests report" mad-src@cern.ch
		[ "$?" != "0" ] && echo "ERROR: unable to email report summary (check mail)"
	fi
}

# tag reports as processed [lxplus | macosx | windows]
build_test_proc ()
{
	for arch in "$@" ; do
		echo "processed `date`" > build-test-$arch.run
	done
}

# cleaning
clean_tmp

# retrieve remote reports
scp -q "mad@macserv15865.cern.ch:Projects/madX/build-test-macosx.*" .
[ "$?" != "0" ] && echo "ERROR: unable to retrieve macosx report (check scp)"

# check if all reports are finished
build_test_check  lxplus macosx

# build the final report
build_test_report lxplus macosx

# send the final report
build_test_send   lxplus macosx

# mark all reports as processed
build_test_proc   lxplus macosx

# update status of remote reports
scp -q build-test-macosx.run "mad@macserv15865.cern.ch:Projects/madX"
[ "$?" != "0" ] && echo "ERROR: unable to update macosx report (check scp)"

# synchronize files
sync

# report errors if any
if [ -s build-test-report.log ] ; then
	cat -v build-test-report.log | mail -s "MAD-X builds and tests errors" mad@cern.ch
	[ "$?" != "0" ] && echo "ERROR: unable to email report errors (check mail)"
fi

clean_exit
