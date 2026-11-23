#!/bin/bash
set -euo pipefail
EXIT_CODE=0

tools/deploy.sh ci_test
mkdir ci_test/config

#test config
cp tools/ci/ci_config.txt ci_test/config/config.txt

cd ci_test
ln -s $HOME/libmariadb/libmariadb.so libmariadb.so
# On Linux, DreamDaemon 516 can hang for several minutes after "Shutdown complete",
# even though the world is already closed and the result is written to clean_run.lk (515 exited at once).
# Run it in the background and kill it if it has not exited SHUTDOWN_GRACE seconds after the world shut down.
SHUTDOWN_GRACE=15
DreamDaemon nsv13.dmb -close -trusted -verbose -params "log-directory=ci" > dd_output.log 2>&1 &
DD_PID=$!
tail -n +1 -f dd_output.log --pid=$DD_PID &
TAIL_PID=$!

while kill -0 $DD_PID 2>/dev/null; do
	if grep -q "Shutdown complete" dd_output.log; then
		for _ in $(seq 1 $SHUTDOWN_GRACE); do
			kill -0 $DD_PID 2>/dev/null || break
			sleep 1
		done
		if kill -0 $DD_PID 2>/dev/null; then
			echo "DreamDaemon did not exit ${SHUTDOWN_GRACE}s after the world shut down, killing it."
			kill $DD_PID 2>/dev/null || true
			sleep 2
			kill -9 $DD_PID 2>/dev/null || true
		fi
		break
	fi
	sleep 1
done

wait $DD_PID || EXIT_CODE=$?
wait $TAIL_PID 2>/dev/null || true

cd ..
cat ci_test/data/logs/ci/clean_run.lk
