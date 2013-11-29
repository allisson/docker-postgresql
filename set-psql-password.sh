/usr/bin/supervisord &
sleep 10
su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'postgres'\" -d template1"
