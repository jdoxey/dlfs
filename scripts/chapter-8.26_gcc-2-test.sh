log() {
	echo ""
	echo "*** $1 ***"
}


log "8.26. GCC-11.2.0 (test)"

cd /sources/gcc-11.2.0/build

ulimit -s 32768

chown -Rv tester . 
su tester -c "PATH=$PATH make -k check"

../contrib/test_summary | grep -A7 Summ
