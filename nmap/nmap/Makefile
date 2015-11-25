# Extract the version string from nmap.h.
export NMAP_VERSION := $(shell grep '^\#[ \t]*define[ \t]\+NMAP_VERSION' nmap.h | sed -e 's/.*"\(.*\)".*/\1/' -e 'q')
export NMAP_UPDATE_CHANNEL := $(shell grep '^\#[ \t]*define[ \t]\+NMAP_UPDATE_CHANNEL' nmap.h | sed -e 's/.*"\(.*\)".*/\1/' -e 'q')
NMAP_NAME= Nmap
NMAP_URL= http://nmap.org
NMAP_PLATFORM=x86_64-apple-darwin12.5.0
prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
sbindir = ${exec_prefix}/sbin
mandir = ${prefix}/share/man
top_srcdir = .
srcdir = .
nmapdatadir = ${prefix}/share/nmap
deskdir = $(prefix)/share/applications
NMAPDEVDIR=~/nmap-private-dev

export NBASEDIR=nbase
export NSOCKDIR=nsock
export LIBLUADIR = liblua
export LIBLINEARDIR = liblinear
export NDIR=$(shell pwd)
export LIBLUA_LIBS = $(top_srcdir)/liblua/liblua.a
export LIBLINEAR_LIBS = $(top_srcdir)/liblinear/liblinear.a
export NCATDIR=ncat
CC = gcc
CXX = g++
CCOPT = 
DBGFLAGS = 
STRIP = /usr/bin/strip
LIBPCAPDIR = libpcap
LIBPCREDIR = libpcre
export LIBDNETDIR = libdnet-stripped
ZENMAPDIR = zenmap
NDIFFDIR = ndiff
NPINGDIR = nping
PYTHON = /usr/bin/python
DEFS = -DHAVE_CONFIG_H -DNMAP_NAME=\"$(NMAP_NAME)\" -DNMAP_URL=\"$(NMAP_URL)\" -DNMAP_PLATFORM=\"$(NMAP_PLATFORM)\" -DNMAPDATADIR=\"$(nmapdatadir)\"
# With GCC, add extra security checks to source code.
# http://gcc.gnu.org/ml/gcc-patches/2004-09/msg02055.html
# Level 1 only makes changes that don't affect "conforming" programs,
# while level 2 enforces additional restrictions.
DEFS += -D_FORTIFY_SOURCE=2
# For mtrace debugging -- see MTRACE define in main.cc for instructions
# Should only be enabled during debugging and not in any real release.
# DEFS += -DMTRACE=1
CXXFLAGS = -no-cpp-precomp -g -O2 -Wall -fno-strict-aliasing $(DBGFLAGS) $(CCOPT)
CPPFLAGS = -I$(top_srcdir)/liblinear -I$(top_srcdir)/liblua -I$(top_srcdir)/libdnet-stripped/include -I$(top_srcdir)/libpcre  -I$(top_srcdir)/nbase -I$(top_srcdir)/nsock/include $(DEFS)
export CFLAGS = $(CXXFLAGS)
# CFLAGS = $(DEFS) $(INCLS)
STATIC =
LDFLAGS =  -Lnbase -Lnsock/src/ $(DBGFLAGS) $(STATIC)
LIBS =  -lnbase -lnsock libpcre/libpcre.a -lpcap $(OPENSSL_LIBS) libnetutil/libnetutil.a $(top_srcdir)/libdnet-stripped/src/.libs/libdnet.a $(top_srcdir)/liblua/liblua.a $(top_srcdir)/liblinear/liblinear.a -lm 
OPENSSL_LIBS = -lssl -lcrypto
# LIBS =  -lefence -lm 
# LIBS =  -lrmalloc -lm 
INSTALL = /usr/bin/install -c
# MAKEDEPEND = @MAKEDEPEND@
export RPMTDIR=$(HOME)/rpm
# Whether the user wants to install translated man pages. If "yes", then
# all translated man pages are installed, unless a subset is specified
# with the LINGUAS environment variable.
USE_NLS = yes
# A space-separated list of language codes supported (for man page
# installation). The user can install a subset of these with the LINGUAS
# environment variable or none of them with --disable-nls.
ALL_LINGUAS = de es fr hr hu it ja pl pt_BR pt_PT ro ru sk zh
# A space-separated list of language codes requested by the user.
LINGUAS ?= $(ALL_LINGUAS)


# DESTDIR is used by some package maintainers to install Nmap under
# its usual directory structure into a different tree.  See the 
# CHANGELOG for more info.
DESTDIR =

TARGET = nmap
INSTALLNSE=install-nse
BUILDZENMAP=build-zenmap
BUILDNDIFF=build-ndiff
BUILDNPING=build-nping
INSTALLZENMAP=install-zenmap
INSTALLNDIFF=install-ndiff
INSTALLNPING=install-nping
UNINSTALLZENMAP=uninstall-zenmap
UNINSTALLNPING=uninstall-nping

ifneq ($(top_srcdir)/liblua/liblua.a,)
NSE_SRC=nse_main.cc nse_utility.cc nse_nsock.cc nse_dnet.cc nse_fs.cc nse_nmaplib.cc nse_debug.cc nse_pcrelib.cc nse_binlib.cc nse_bit.cc
NSE_HDRS=nse_main.h nse_utility.h nse_nsock.h nse_dnet.h nse_fs.h nse_nmaplib.h nse_debug.h nse_pcrelib.h nse_binlib.h nse_bit.h
NSE_OBJS=nse_main.o nse_utility.o nse_nsock.o nse_dnet.o nse_fs.o nse_nmaplib.o nse_debug.o nse_pcrelib.o nse_binlib.o nse_bit.o
ifneq (-lssl -lcrypto,)
NSE_SRC+=nse_openssl.cc nse_ssl_cert.cc
NSE_HDRS+=nse_openssl.h nse_ssl_cert.h
NSE_OBJS+=nse_openssl.o nse_ssl_cert.o
endif
endif

export SRCS = charpool.cc FingerPrintResults.cc FPEngine.cc FPModel.cc idle_scan.cc MACLookup.cc main.cc nmap.cc nmap_dns.cc nmap_error.cc nmap_ftp.cc NmapOps.cc NmapOutputTable.cc nmap_tty.cc osscan2.cc osscan.cc output.cc payload.cc portlist.cc portreasons.cc protocols.cc scan_engine.cc service_scan.cc services.cc Target.cc TargetGroup.cc targets.cc tcpip.cc timing.cc traceroute.cc utils.cc xml.cc $(NSE_SRC)

export HDRS = charpool.h FingerPrintResults.h FPEngine.h global_structures.h idle_scan.h MACLookup.h nmap_amigaos.h nmap_dns.h nmap_error.h nmap.h nmap_ftp.h NmapOps.h NmapOutputTable.h nmap_tty.h nmap_winconfig.h osscan2.h osscan.h output.h payload.h portlist.h portreasons.h protocols.h scan_engine.h service_scan.h services.h TargetGroup.h Target.h targets.h tcpip.h timing.h traceroute.h utils.h xml.h $(NSE_HDRS)

OBJS = charpool.o FingerPrintResults.o FPEngine.o FPModel.o idle_scan.o MACLookup.o main.o nmap_dns.o nmap_error.o nmap.o nmap_ftp.o NmapOps.o NmapOutputTable.o nmap_tty.o osscan2.o osscan.o output.o payload.o portlist.o portreasons.o protocols.o scan_engine.o service_scan.o services.o TargetGroup.o Target.o targets.o tcpip.o timing.o traceroute.o utils.o xml.o $(NSE_OBJS)

# %.o : %.cc -- nope this is a GNU extension
.cc.o:
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# FPModel.cc contains large numeric tables that exceed the capacity of
# debugging output with GCC 4.6.0 on AIX, causing "Error: value of 121716 too
# large for field of 2 bytes". Disable debugging for this one file.
FPModel.o: CXXFLAGS += -g0

all: lua_build liblinear_build  pcre_build dnet_build nbase_build nsock_build ncat_build  netutil_build
	$(MAKE) $(TARGET) $(BUILDZENMAP) $(BUILDNDIFF) $(BUILDNPING)

$(TARGET): $(top_srcdir)/liblua/liblua.a $(top_srcdir)/liblinear/liblinear.a  libpcre/libpcre.a $(top_srcdir)/libdnet-stripped/src/.libs/libdnet.a $(NBASEDIR)/libnbase.a $(NSOCKDIR)/src/libnsock.a libnetutil/libnetutil.a $(OBJS)
	@echo Compiling nmap
	rm -f $@
	$(CXX) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

build-%: %/Makefile
	cd $* && $(MAKE)

pcre_build: $(LIBPCREDIR)/Makefile
	@echo Compiling libpcre; cd $(LIBPCREDIR) && $(MAKE)

dnet_build: $(LIBDNETDIR)/Makefile
	@echo Compiling libdnet; cd $(LIBDNETDIR) && $(MAKE)

pcap_build: $(LIBPCAPDIR)/Makefile
	@echo Compiling libpcap; cd $(LIBPCAPDIR) && $(MAKE)

nbase_build: $(NBASEDIR)/Makefile
	@echo Compiling libnbase;
	cd $(NBASEDIR) && $(MAKE)

nsock_build: $(NSOCKDIR)/src/Makefile nbase_build
	@echo Compiling libnsock;
	cd $(NSOCKDIR)/src && $(MAKE)

netutil_build: libnetutil/Makefile
	@echo Compiling libnetutil;
	cd libnetutil && $(MAKE)

ncat_build: $(NCATDIR)/Makefile nbase_build nsock_build $(NCATDIR)/ncat.h
	cd $(NCATDIR) && $(MAKE)

lua_build: $(LIBLUADIR)/Makefile
	@echo Compiling liblua; cd $(LIBLUADIR) && $(MAKE) liblua.a CC="$(CC)" MYCFLAGS="$(CFLAGS) -DLUA_USE_MACOSX"

liblinear_build: $(LIBLINEARDIR)/Makefile
# -Wno-uninitialized avoids the warning "'Gnorm1_init' may be used uninitialized in this function"
	@echo Compiling liblinear; cd $(LIBLINEARDIR) && $(MAKE) liblinear.a CC="$(CC)" CXX="$(CXX)" CFLAGS="$(CFLAGS) -Wno-uninitialized"

build-nmap-update: nmap-update/default_channel.h

#$(LIBPCAPDIR)/Makefile:
#	@echo Configuring libpcap; cd $(LIBPCAPDIR); ./configure


# Make a statically compiled binary for portability between distributions
static:
	$(MAKE) STATIC=-static

debug:
	$(MAKE) DBGFLAGS="-O0 -g -pg -ftest-coverage -fprofile-arcs"

# CALL THIS FROM ONE COMPUTER AND CHECK IN RESULTS BEFORE DOING ANYONE
# DOES A MAKE RELEASE
prerelease:
	cd $(NMAPDEVDIR) && $(MAKE) prerelease

# Make just the Nmap tarballs
release-tarballs:
	cd $(NMAPDEVDIR) && $(MAKE) release-tarballs

# Make the tarballs and RPMs (which are built from tarball)
release-rpms:
	cd $(NMAPDEVDIR) && $(MAKE) release-rpms

# Update the web site
web:
	cd $(NMAPDEVDIR) && $(MAKE) web

clean: lua_clean liblinear_clean  pcre_clean dnet_clean nsock_clean nbase_clean netutil_clean my_clean nping_clean zenmap_clean ncat_clean  ndiff_clean

my_clean:
	rm -f dependencies.mk
	rm -f $(OBJS) $(TARGET) config.cache

clean-%:
	-cd $* && $(MAKE) clean
distclean-%: clean-%
	-cd $* && $(MAKE) distclean

pcap_clean:
	-cd $(LIBPCAPDIR) && $(MAKE) clean
pcre_clean:
	-cd $(LIBPCREDIR) && $(MAKE) clean
dnet_clean:
	-cd $(LIBDNETDIR) && $(MAKE) clean
nbase_clean:
	-cd $(NBASEDIR) && $(MAKE) clean
nsock_clean:
	-cd $(NSOCKDIR)/src && $(MAKE) clean
netutil_clean:
	-cd libnetutil && $(MAKE) clean
ncat_clean:
	-cd $(NCATDIR) && $(MAKE) clean
lua_clean:
	-cd $(LIBLUADIR) && $(MAKE) clean
liblinear_clean:
	-cd $(LIBLINEARDIR) && $(MAKE) clean
zenmap_clean:
	-cd $(ZENMAPDIR) && $(PYTHON) setup.py clean --all
	rm -f $(ZENMAPDIR)/zenmapCore/__init__.pyc
	rm -f $(ZENMAPDIR)/zenmapCore/Version.pyc
	rm -f $(ZENMAPDIR)/zenmapCore/Name.pyc
ndiff_clean:
	-cd $(NDIFFDIR) && $(PYTHON) setup.py clean --all
nping_clean:
	-cd $(NPINGDIR) && $(MAKE) clean
pcap_dist_clean:
	-cd $(LIBPCAPDIR) && $(MAKE) distclean
pcre_dist_clean:
	-cd $(LIBPCREDIR) && $(MAKE) distclean
dnet_dist_clean:
	-cd $(LIBDNETDIR) && $(MAKE) distclean
lua_dist_clean:
	-cd $(LIBLUADIR) && $(MAKE) clean
liblinear_dist_clean: liblinear_clean
nbase_dist_clean:
	-cd $(NBASEDIR) && $(MAKE) distclean
nsock_dist_clean:
	-cd $(NSOCKDIR)/src && $(MAKE) distclean
netutil_dist_clean:
	-cd libnetutil && $(MAKE) distclean
ncat_dist_clean:
	-cd $(NCATDIR) && $(MAKE) distclean
zenmap_dist_clean: zenmap_clean
	-cd $(ZENMAPDIR) && rm -rf MANIFEST build/ dist/ INSTALLED_FILES
ndiff_dist_clean: ndiff_clean
	-cd $(NDIFFDIR) && rm -rf build/ dist/
nping_dist_clean:
	-cd $(NPINGDIR) && $(MAKE) distclean
debugclean:
	rm -f *.gcov *.gcda *.gcno gmon.out

distclean: my_clean my_distclean lua_dist_clean liblinear_dist_clean  pcre_dist_clean dnet_dist_clean nping_dist_clean zenmap_dist_clean ncat_dist_clean  nsock_dist_clean nbase_dist_clean netutil_dist_clean ndiff_dist_clean

my_distclean:
	rm -f Makefile Makefile.bak makefile.dep nmap_config.h stamp-h stamp-h.in \
	         config.cache config.log config.status

install-nmap: $(TARGET)
	$(INSTALL) -d $(DESTDIR)$(bindir) $(DESTDIR)$(mandir)/man1 $(DESTDIR)$(nmapdatadir)
	$(INSTALL) -c -m 755 nmap $(DESTDIR)$(bindir)/nmap
# Use strip -x to avoid stripping dynamically loaded NSE functions. See
# http://seclists.org/nmap-dev/2007/q4/0272.html.
	$(STRIP) -x $(DESTDIR)$(bindir)/nmap
	$(INSTALL) -c -m 644 docs/$(TARGET).1 $(DESTDIR)$(mandir)/man1/
	if [ "$(USE_NLS)" = "yes" ]; then \
	  for ll in $(filter $(ALL_LINGUAS),$(LINGUAS)); do \
	    $(INSTALL) -d $(DESTDIR)$(mandir)/$$ll/man1; \
	    $(INSTALL) -c -m 644 docs/man-xlate/$(TARGET)-$$ll.1 $(DESTDIR)$(mandir)/$$ll/man1/$(TARGET).1; \
	  done; \
	fi
	$(INSTALL) -c -m 644 docs/nmap.xsl $(DESTDIR)$(nmapdatadir)/
	$(INSTALL) -c -m 644 docs/nmap.dtd $(DESTDIR)$(nmapdatadir)/
	$(INSTALL) -c -m 644 nmap-services $(DESTDIR)$(nmapdatadir)/
	$(INSTALL) -c -m 644 nmap-payloads $(DESTDIR)$(nmapdatadir)/
	$(INSTALL) -c -m 644 nmap-rpc $(DESTDIR)$(nmapdatadir)/
	$(INSTALL) -c -m 644 nmap-os-db $(DESTDIR)$(nmapdatadir)/
	$(INSTALL) -c -m 644 nmap-service-probes $(DESTDIR)$(nmapdatadir)/
	$(INSTALL) -c -m 644 nmap-protocols $(DESTDIR)$(nmapdatadir)/
	$(INSTALL) -c -m 644 nmap-mac-prefixes $(DESTDIR)$(nmapdatadir)/

# Update the Ncat version number.
$(NCATDIR)/ncat.h: nmap.h
	sed -e 's/^#[ \t]*define[ \t]\+NCAT_VERSION[ \t]\+\(".*"\)/#define NCAT_VERSION "$(NMAP_VERSION)"/' $@ > $@.tmp
	mv -f $@.tmp $@

# Update the Nping version number. This is "0.NMAP_VERSION".
# If the 0. prefix is removed it must also be removed from nmap.spec.in.
$(NPINGDIR)/nping.h: nmap.h
	sed -e 's/^#[ \t]*define[ \t]\+NPING_VERSION[ \t]\+\(".*"\)/#define NPING_VERSION "0.$(NMAP_VERSION)"/' $@ > $@.tmp
	mv -f $@.tmp $@

# Update the version number used by Zenmap.
$(ZENMAPDIR)/zenmapCore/Version.py $(ZENMAPDIR)/share/zenmap/config/zenmap_version: nmap.h
	cd $(ZENMAPDIR) && $(PYTHON) install_scripts/utils/version_update.py "$(NMAP_VERSION)"

nmap-update/default_channel.h: nmap.h
	sed -e 's/^#[ \t]*define[ \t]\+DEFAULT_CHANNEL[ \t]\+\(".*"\)/#define DEFAULT_CHANNEL "$(NMAP_UPDATE_CHANNEL)"/' $@ > $@.tmp
	mv -f $@.tmp $@

# By default distutils rewrites installed scripts to hardcode the
# location of the Python interpreter they were built with (something
# like #!/usr/bin/python2.4). This is the wrong thing to do when
# installing on a machine other than the one used to do the build. Use
# this as the location of the interpreter whenever we're not doing a
# local installation.
DEFAULT_PYTHON_PATH = /usr/bin/env python

build-zenmap: $(ZENMAPDIR)/setup.py $(ZENMAPDIR)/zenmapCore/Version.py
# When DESTDIR is defined, assume we're building an executable
# distribution rather than a local installation and force a generic
# Python interpreter location.
	cd $(ZENMAPDIR) && $(PYTHON) setup.py build $(if $(DESTDIR),--executable "$(DEFAULT_PYTHON_PATH)")

install-zenmap: $(ZENMAPDIR)/setup.py
	$(INSTALL) -d $(DESTDIR)$(bindir) $(DESTDIR)$(mandir)/man1
	cd $(ZENMAPDIR) && $(PYTHON) setup.py --quiet install --prefix "$(prefix)" --force $(if $(DESTDIR),--root "$(DESTDIR)")
	$(INSTALL) -c -m 644 docs/zenmap.1 $(DESTDIR)$(mandir)/man1/
# Create a symlink from nmapfe to zenmap if nmapfe doesn't exist or is
# already a link.
	if [ ! -f $(DESTDIR)$(bindir)/nmapfe -o -L $(DESTDIR)$(bindir)/nmapfe ]; then \
		ln -sf zenmap $(DESTDIR)$(bindir)/nmapfe; \
	fi
# Create a symlink from xnmap to zenmap unconditionally.
	ln -sf zenmap $(DESTDIR)$(bindir)/xnmap

build-ndiff:
	cd $(NDIFFDIR) && $(PYTHON) setup.py build $(if $(DESTDIR),--executable "$(DEFAULT_PYTHON_PATH)")

build-nping: $(NPINGDIR)/Makefile nbase_build nsock_build netutil_build $(NPINGDIR)/nping.h
	@cd $(NPINGDIR) && $(MAKE)

install-ndiff:
	cd $(NDIFFDIR) && $(PYTHON) setup.py install --prefix "$(prefix)" $(if $(DESTDIR),--root "$(DESTDIR)")

NSE_FILES = scripts/script.db scripts/*.nse
NSE_LIB_LUA_FILES = nselib/*.lua nselib/*.luadoc

install-nse: $(TARGET)
	$(INSTALL) -d $(DESTDIR)$(nmapdatadir)/scripts
	$(INSTALL) -d $(DESTDIR)$(nmapdatadir)/nselib

# Remove obsolete scripts from a previous installation.
	(cd $(DESTDIR)$(nmapdatadir)/scripts && rm -f $(OLD_SCRIPT_NAMES))

	$(INSTALL) -c -m 644 nse_main.lua $(DESTDIR)$(nmapdatadir)/
	$(INSTALL) -c -m 644 $(NSE_FILES) $(DESTDIR)$(nmapdatadir)/scripts
	$(INSTALL) -c -m 644 $(NSE_LIB_LUA_FILES) $(DESTDIR)$(nmapdatadir)/nselib
	$(INSTALL) -d $(DESTDIR)$(nmapdatadir)/nselib/data
	for f in `find nselib/data -name .svn -prune -o -type d -print`; do \
		$(INSTALL) -d $(DESTDIR)$(nmapdatadir)/$$f; \
	done
	for f in `find nselib/data -name .svn -prune -o -type f -print`; do \
		$(INSTALL) -c -m 644 $$f $(DESTDIR)$(nmapdatadir)/$$f; \
	done

install-%: build-% %/Makefile
	cd $* && $(MAKE) install
uninstall-%: %/Makefile
	cd $* && $(MAKE) uninstall

install-ncat: $(NCATDIR)/ncat
	@cd $(NCATDIR) && $(MAKE) install

install-nping: $(NPINGDIR)/nping
	@cd $(NPINGDIR) && $(MAKE) install

install: install-nmap $(INSTALLNSE) $(INSTALLZENMAP) install-ncat  $(INSTALLNDIFF) $(INSTALLNPING)
	@echo "NMAP SUCCESSFULLY INSTALLED"

uninstall: uninstall-nmap $(UNINSTALLZENMAP) uninstall-ncat  $(UNINSTALLNPING)

uninstall-nmap:
	rm -f $(DESTDIR)$(bindir)/$(TARGET)
	rm -f $(DESTDIR)$(mandir)/man1/$(TARGET).1
	rm -f $(DESTDIR)$(mandir)/*/man1/$(TARGET).1
	rm -rf $(DESTDIR)$(nmapdatadir)

uninstall-zenmap:
	cd $(ZENMAPDIR) && $(PYTHON) setup.py uninstall
	rm -f $(DESTDIR)$(mandir)/man1/zenmap.1
# Uninstall nmapfe only if it's a symlink.
	if [ -L $(DESTDIR)$(bindir)/nmapfe ]; then \
		rm -f $(DESTDIR)$(bindir)/nmapfe; \
	fi
	rm -f $(DESTDIR)$(bindir)/xnmap

uninstall-ncat:
	@cd $(NCATDIR) && $(MAKE) uninstall

uninstall-nping:
	@cd $(NPINGDIR) && $(MAKE) uninstall

nse_check:
	./nmap -d --datadir . --script=unittest --script-args=unittest.run

ncat_check:
	@cd $(NCATDIR) && $(MAKE) check

ndiff_check:
	@cd $(NDIFFDIR) && $(PYTHON) ndifftest.py

nsock_check:
	@cd $(NSOCKDIR)/src && $(MAKE) check

zenmap_check:
	@cd $(ZENMAPDIR) && $(PYTHON) -m unittest discover build/lib.* '*.py'

check: ncat_check nsock_check zenmap_check nse_check ndiff_check

${srcdir}/configure: configure.ac 
	cd ${srcdir} && autoconf

## autoheader might not change config.h.in, so touch a stamp file.
#${srcdir}/config.h.in: stamp-h.in
#${srcdir}/stamp-h.in: configure.ac acconfig.h \
#	config.h.top config.h.bot
#	cd ${srcdir} && autoheader
#	echo timestamp > ${srcdir}/stamp-h.in
#
#config.h: stamp-h
#stamp-h: config.h.in config.status
#	./config.status

Makefile: Makefile.in config.status
	./config.status

config.status: configure
	./config.status --recheck

# Run the lua-format program to fix formatting of NSE files.
lua-format:
	./docs/style/lua-format -i scripts/*.nse

makefile.dep:
	$(CXX) -MM $(CPPFLAGS) $(SRCS) > $@
include makefile.dep

# These the old names of scripts that have been renamed or deleted. Any
# scripts with these names will be deleted from the installation
# directory on "make install" so that duplicate, old copies of scripts
# are not run.
OLD_SCRIPT_NAMES = $(addsuffix .nse, \
anonFTP ASN asn-to-prefix brutePOP3 bruteTelnet chargenTest daytimeTest \
dns-safe-recursion-port dns-safe-recursion-txid dns-test-open-recursion \
domino-enum-passwords echoTest ftpbounce HTTPAuth HTTP_open_proxy HTTPpasswd \
HTTPtrace iax2Detect ircServerInfo ircZombieTest mac-geolocation MSSQLm \
MySQLinfo netbios-smb-os-discovery nfs-acls nfs-dirlist popcapa PPTPversion \
promiscuous RealVNC_auth_bypass ripeQuery robots showHTMLTitle \
showHTTPVersion showOwner showSMTPVersion showSSHVersion skype_v2-version \
smb-enumdomains smb-enumsessions smb-enumshares smb-enumusers \
smb-serverstats smb-systeminfo SMTPcommands SMTP_openrelay_test \
smtp-check-vulns SNMPcommunitybrute SNMPsysdescr SQLInject SSH-hostkey \
SSHv1-support SSLv2-support strangeSMTPport UPnP-info xamppDefaultPass \
zoneTrans db2-info db2-brute html-title robots.txt xmpp sql-injection \
http-robtex-reverse-ip )

.PHONY: lua-format
