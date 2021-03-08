use base "opensusebasetest";
use strict;
use warnings;
use testapi;

my %expected_install_inf = (
    'Cmdline'         => 'splash=silent vga=791 video=1024x768 plymouth.ignore-serial-consoles console=ttyS0 console=tty',
    'Hostname'        => undef,
    'SetHostname'     => 1,
    'SetHostnameUsed' => 0
);

my %expected_sysconfig = (
    'network' => (
        'dhcp' => (
            'DHCLIENT_SET_HOSTNAME' => 'yes'
        )
    )
);

sub check_changes_by_linuxrc {
    my %install_inf = (
        'Cmdline'         => script_output('grep "^Cmdline:" /etc/install.inf')                           =~ s/Cmdline: //r,
        'Hostname'        => script_output('grep "^Hostname:" /etc/install.inf', proceed_on_failure => 1) =~ s/Hostname: //r,
        'SetHostname'     => script_output('grep "^SetHostname:" /etc/install.inf')                       =~ s/SetHostname: //r,
        'SetHostnameUsed' => script_output('grep "^SetHostnameUsed:" /etc/install.inf')                   =~ s/SetHostnameUsed: //r
    );

    my %sysconfig = (
        'network' => (
            'dhcp' = (
                'DHCLIENT_SET_HOSTNAME' => script_output('grep "^DHCLIENT_SET_HOSTNAME=" /etc/sysconfig/network/dhcp') =~ s/DHCLIENT_SET_HOSTNAME="(\w*)"/\1/r
            )
        )
    );

    die "Parameter `hostname` not used in cmdline, but `/etc/install.inf::SetHostnameUsed` is set to $install_inf{'SetHostnameUsed'}" if ($install_inf{'SetHostnameUsed'} != 0);
    die "By default hostname by DHCP should be enabled, but `/etc/install.inf::SetHostname` is set to $install_inf{'SetHostname'}" if ($install_inf{'SetHostname'} != 1);
    die "By default linuxrc should not specify a static hostname, but `/etc/install.inf::Hostname` is set to $install_inf{'Hostname'}" if ($install_inf{'Hostname'});

    return %install_inf;
}

sub run {
    assert_screen 'startshell', 150;
    assert_script_run 'cat /etc/proc/cmdline';
    my %install_inf = check_changes_by_linuxrc(%expected_install_inf);
}

1;
