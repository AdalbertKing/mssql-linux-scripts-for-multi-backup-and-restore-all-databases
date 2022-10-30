/root/scripts/gensql.sh -n restore /srv/backup/ norecovery>/srv/backup/restorenew.sql
/root/scripts/gensql.sh -n setrecovery /srv/backup/ recovery >/srv/backup/setrecoverynew.sql
/root/scripts/backupall.sh -fein /srv/backup/
cat /srv/backup/restorenew.sql>>/srv/backup/restoreall.sql
cat /srv/backup/setrecoverynew.sql>>/srv/backup/setrecovery.sql

/root/scripts/backupall.sh -e /srv/backup/diff/ 
/root/scripts/gensql.sh restore /srv/backup/diff/ norecovery >/srv/backup/diff/restoreall.sql
/root/scripts/gensql.sh setrecovery /srv/backup/diff/ recovery >/srv/backup/diff/setrecovery.sql 
