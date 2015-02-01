LIBS=${PERL5LIB}:/var/www/lib/perl

.PHONY: test
test: lib/CS7099Lib/Lab01.pm
	clear
	PERL5LIB=${LIBS} prove -rb ./t

#.PHONY: onetest
#onetest: lib/CS7099Lib/Lab01.pm
#	clear
#	PERL5LIB=${LIBS} HARNESS_OPTIONS=c perl -MTest::Harness -e 'runtests "${TEST}"'

# vim: ts=4 sw=4 noexpandtab
