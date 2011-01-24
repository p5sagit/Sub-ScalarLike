package Sub::ScalarLike;

use strict;
use warnings FATAL => 'all';
use Variable::Magic qw(wizard cast dispell);

my $wiz = wizard
  data => sub { +{ guard => 0, pkg => $_[1] } },
  fetch => sub {
    my ($var, $data, $name) = @_;

    return if $data->{guard};
    local $data->{guard} = 1;

    my $pkg = $data->{pkg};

    return if $pkg->can($name);

    return if $name =~ /^__/; # __PACKAGE__ et. al.

    my $fqn = join '::', $pkg, $name;

    my $sub = sub () :lvalue { $pkg->_SCOPE->{$name} };

    { no strict 'refs'; *$fqn = $sub }

    return
  };

sub setup_for {
  my ($pkg) = @_;
  {
   no strict 'refs';
   cast %{"${pkg}::"}, $wiz, $pkg;
  }
}

sub teardown_for {
  my ($pkg) = @_;
  {
   no strict 'refs';
   dispell %{"${pkg}::"}, $wiz;
  }
}

1;
