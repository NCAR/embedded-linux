#!/bin/bash

script=`basename $0`

install=false

while [ $# -gt 0 ]; do
    case $1 in
        -i)
            install="true"
            ;;
    esac
    shift
done

rroot=unknown
rf=repo_scripts/repo_funcs.sh
[ -f $rf ] || rf=/net/www/docs/software/rpms/scripts/repo_funcs.sh
if [ -f $rf ]; then
    source $rf
    rroot=`get_eol_repo_root`
else
    [ -d /net/www/docs/software/rpms ] && rroot=/net/www/docs/software/rpms
fi

# Change topdir for a machine specific build. Use $TOPDIR if it exists.
topdir=${TOPDIR:-$(rpmbuild --eval %_topdir)_$(hostname)}

# echo "topdir=$topdir"
[ -d $topdir/SOURCES ] || mkdir -p $topdir/SOURCES
[ -d $topdir/BUILD ] || mkdir -p $topdir/BUILD
[ -d $topdir/SRPMS ] || mkdir -p $topdir/SRPMS
[ -d $topdir/RPMS ] || mkdir -p $topdir/RPMS

log=`mktemp /tmp/${script}_XXXXXX.log`
tmpspec=`mktemp /tmp/${script}_XXXXXX.spec`
awkcom=`mktemp /tmp/${script}_XXXXXX.awk`
trap "{ rm -f $log $tmpspec $awkcom; }" EXIT

set -o pipefail

pkg=armel-images

# In the RPM changelog, copy most recent commit subject lines
# since this tag (max of 100).
sincetag=v1.0

# to get the most recent tag of the form: vN
# sincetag=$(git tag -l --sort=version:refname "[vV][0-9]*" | tail -n 1)

if ! gitdesc=$(git describe --match "v[0-9]*"); then
    echo "git describe failed, looking for a tag of the form v[0-9]*"
    exit 1
fi
# example output of git describe: v2.0-14-gabcdef123
gitdesc=${gitdesc/#v}       # remove leading v
version=${gitdesc%%-*}       # 2.0

release=${gitdesc#*-}       # 14-gabcdef123
release=${release%-*}       # 14
[ $gitdesc == "$release" ] && release=0 # no dash

# get the author of the last commit. Will be set as the Packager in the RPM.
author=$(git log -n 1 --format="%an <%aE>" .)

# run git describe on each hash to create a version
cat <<-\EOD > $awkcom
    /^[0-9a-f]{7}/ {
    cmd = "git describe --match '[vV][0-9]*' " $0 " 2>/dev/null"
    res = (cmd | getline version)
    close(cmd)
    if (res == 0) {
        version = ""
    }
    }
    /^\*/ { print $0,version }
    /^-/ { print $0 }
    /^$/ { print $0 }
EOD

# create change log from git log messages since the tag $sincetag.
# Put SHA hash by itself on first line. Above awk script then
# converts it to the output of git describe, and appends it to "*" line.
# Truncate subject line at 60 characters 
# git convention is that the subject line is supposed to be 50 or shorter
git log --max-count=100 --date-order --format="%H%n* %cd %aN%n- %s%n" --date=local ${sincetag}.. | sed -r 's/[0-9]+:[0-9]+:[0-9]+ //' | sed -r 's/(^- .{,60}).*/\1/' | awk --re-interval -f $awkcom | cat ${pkg}.spec - > $tmpspec

# use transform to add package-version path in front of file names
tar czf $topdir/SOURCES/${pkg}-${version}.tar.gz \
    --transform="s,^\(.\),$pkg-$version/\1," \
        redboot-* titan_deb8_root*.img viper_deb8_root*.img || exit $?

rpmbuild -bb \
    --define "gitversion $version" --define "releasenum $release" \
    --define "packager $author" \
    --define "_topdir $topdir" \
    --define "debug_package %{nil}" \
    $tmpspec 2>&1 | tee -a $log  || exit $?

echo "RPMS:"
egrep "^Wrote:" $log
rpms=`egrep '^Wrote:' $log | egrep RPMS/ | awk '{print $2}'`
echo "rpms=$rpms"

if $install && [ -d $rroot ]; then
echo "Moving rpms to $rroot"
copy_rpms_to_eol_repo $rpms
else
echo "-i or -r options not specified. RPMS will not be installed"
fi

# print out warnings: and the following file list
sed -n '
/^warning:/{
: next
p
n
/^ /b next
}
' $log
