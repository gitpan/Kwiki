use inc::Module::Install;

name('Kwiki');
author('Brian Ingerson <ingy@cpan.org>');
abstract('Kwiki Wiki Framework');
license('perl');
version_from('lib/Kwiki.pm');

requires(qw(
    perl 5.6.1
    Spoon 0.18
    Storable 0
));

install_script('kwiki');

check_nmake();

&WriteAll();
