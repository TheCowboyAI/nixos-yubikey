source jkey
eventlog="yubikey.eventlog.$(date '+%Y%m%d-%H%M%S').json"
echo "Logging has begun on $eventlog"
echo "Logging has begun" >> $eventlog
