Summary: Filesystem and RedBoot images for Eurotech armel systems, served by bootp/tftpboot
Name: armel-images
Version: %{gitversion}
Release: %{releasenum}
License: GPL
Group: System Environment/Daemons
Url: http://github.com/ncareol/embedded-armel
Packager: %{packager}
Vendor: UCAR
BuildArch: noarch
Requires: xinetd tftp-server ael-local-dpkgs >= 1.0-29
Source: %{name}-%{version}.tar.gz

%define _binaries_in_noarch_packages_terminate_build 0

%description
RedBoot and Debian Linux JFFS2 filesystem images for armel systems,
and a tftpboot server configuration so that the images can be
downloaded via bootp with RedBoot.  Contains images for Eurotech
Viper and Titan.  The redboot images are the boot ROM images,
provided by Eurotech/Arcom.  The others were assembled from Debian 8
packages for armel, and kernels built from customized linux kernel source.
Note from the description of the tftp-server package:
    "TFTP provides very little security, and should not be
    enabled unless it is expressly needed."
So, only install this package on lab servers that are used to
install Linux on the armel systems.

%prep
%setup

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/var/lib/tftpboot
mv redboot-* titan_deb8_root*.img titan_fis_rb_*.img viper_deb8_root*.img \
       $RPM_BUILD_ROOT/var/lib/tftpboot

%clean
rm -rf $RPM_BUILD_ROOT

%triggerin -- xinetd
# %triggerin script is run when a given target package is installed or
# upgraded, or when this package is installed or upgraded and the target
# is already installed.

if which systemctl > /dev/null 2>&1; then
    systemctl -q is-enabled xinetd.service || systemctl enable xinetd.service
else
    chkconfig --level 5 xinetd || chkconfig --level 2345 xinetd on
fi

exit 0

%triggerin -- setup

# /etc/hosts.allow
cf=/etc/hosts.allow
if ! egrep "^ALL[[:space:]]*:" $cf | fgrep -q 192.168.; then
    if egrep -q "^ALL[[:space:]]*:" $cf; then
        sed -i -r 's/^ALL[[:space:]]*:.*$/&, 192.168./' $cf
    else
        echo "ALL : LOCAL, .ucar.edu, 128.117., 127.0.0.1, 192.168." >> $cf
    fi
fi 

exit 0

%triggerin -- tftp-server

cf=/etc/xinetd.d/tftp

restartxinetd=false
if ! [ -f $cf ]; then

cat << EOD > $cf
# default: off
# description: The tftp server serves files using the trivial file transfer \
#       protocol.  The tftp protocol is often used to boot diskless \
#       workstations, download configuration files to network-aware printers, \
#       and to start the installation process for some operating systems.
service tftp
{
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -s /var/lib/tftpboot
        disable    = no
        only_from = 192.168.0.0/16
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
}
EOD
    restartxinetd=true
fi

if [ -f $cf ]; then
    if which systemctl > /dev/null 2>&1; then
        systemctl -q is-enabled xinetd.service || systemctl enable xinetd.service
    else
        chkconfig --level 5 xinetd || chkconfig --level 2345 xinetd on
    fi

    # enable tftp in xinetd
    disabled=`awk '/disable/{print $3}' $cf`

    if [ "$disabled" != no ]; then
        sed -ri 's/disable[[:space:]]+=[[:space:]]*.*/disable    = no/' /etc/xinetd.d/tftp
        restartxinetd=true
    fi

    if fgrep -q only_from $cf; then
        if ! fgrep only_from $cf | fgrep -q 192.168.0.0/16; then
            echo "Warning: /etc/xinet.d/tftp has an \"only_from\" statement that does not include 192.168.0.0/16"
        fi
    else
        sed -r -i '/disable[[:space:]]+=/a \
            only_from = 192.168.0.0/16' $cf
        restartxinetd=true
    fi

    # Make sure -s /var/lib/tftpboot is in server_args
    if fgrep -q server_args $cf; then
        if ! fgrep server_args $cf | fgrep -q /var/lib/tftpboot; then
            if fgrep -q -- -s $cf; then
                echo "Updating server_args in $cf"
                sed -i -r '/server_args/s,-s[[:space:]]+[^[:space:]]+,-s /var/lib/tftpboot,' $cf
            else
                sed -i 's,server_args.*,&1 -s /var/lib/tftpboot,' $cf
            fi
        fi
    else
        sed -r -i '/disable[[:space:]]+=/a \
            server_args = -s /var/lib/tftpboot' $cf
        restartxinetd=true
    fi

    if which systemctl > /dev/null 2>&1; then
        if $restartxinetd; then
            pkill -HUP xinetd || systemctl restart xinetd.service
        else
            systemctl is-active xinetd.service || systemctl start xinetd.service
        fi
    else
        if $restartxinetd; then
            pkill -HUP xinetd || /etc/init.d/xinetd start
        else
            pgrep xinetd > /dev/null || /etc/init.d/xinetd start
        fi
    fi
else
    if which systemctl > /dev/null 2>&1; then
        systemctl -q is-enabled tftp.socket || echo "tftp.socket is not enabled. To enable/start: sudo systemctl enable tftp.socket; sudo systemctl start tftp.socket"
        # systemctl -q is-enabled tftp.socket || systemctl enable tftp.socket
        # systemctl -q is-active tftp.socket || systemctl start tftp.socket
    fi
fi

exit 0

%files
/var/lib/tftpboot/redboot-*
/var/lib/tftpboot/titan_deb8_root_*.img
/var/lib/tftpboot/titan_fis_rb_*.img
/var/lib/tftpboot/viper_deb8_root_*.img

%changelog
