/root/scripts/gensql.sh -n restore /srv/backup/ norecovery>/srv/backup/restorenew.sql       # Generating restore and set recovery scripts for new added databases after last full backup in full backup paths
/root/scripts/gensql.sh -n setrecovery /srv/backup/ recovery >/srv/backup/setrecoverynew.sql
/root/scripts/backupall.sh -fein /srv/backup/                                           # Full backup of new added databases in full backup paths (databases without any differential backup)
cat /srv/backup/restorenew.sql>>/srv/backup/restoreall.sql				# join scripts into full backup paths
cat /srv/backup/setrecoverynew.sql>>/srv/backup/setrecovery.sql

/root/scripts/backupall.sh -e /srv/backup/diff/ 					    # 	Differential backup for all databases into differential backups path
/root/scripts/gensql.sh restore /srv/backup/diff/ norecovery >/srv/backup/diff/restoreall.sql 		# generating restore script for 
/root/scripts/gensql.sh setrecovery /srv/backup/diff/ recovery >/srv/backup/diff/setrecovery.sql 	# generating setrecovery script for
