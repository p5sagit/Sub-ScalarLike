use strict;
use warnings FATAL => 'all';
use Sub::ScalarLike ();
use Test::More;

BEGIN {
  package Spoon;

  my %scope; sub _SCOPE { \%scope }

  BEGIN { Sub::ScalarLike::setup_for(__PACKAGE__) }

  sub froom {
    foo = bar + baz;
  }

  BEGIN { Sub::ScalarLike::teardown_for(__PACKAGE__) }
}

ok(Spoon->can($_), "sub for $_ created") for qw(foo bar baz);

Spoon->_SCOPE->{bar} = 1;
Spoon->_SCOPE->{baz} = 2;

Spoon::froom();

cmp_ok(Spoon->_SCOPE->{foo}, '==', 3, 'bareword assign also works');

done_testing;
