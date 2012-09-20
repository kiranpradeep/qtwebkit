# -------------------------------------------------------------------
# Project file for the QtWebKit C++ APIs
#
# See 'Tools/qmake/README' for an overview of the build system
# -------------------------------------------------------------------

# Use Qt5's module system
load(qt_build_config)

TEMPLATE = lib
TARGET = QtWebKit

WEBKIT_DESTDIR = $${ROOT_BUILD_DIR}/lib

WEBKIT += wtf javascriptcore webcore

build?(webkit1): WEBKIT += webkit1
build?(webkit2): WEBKIT += webkit2

# Ensure that changes to the WebKit1 and WebKit2 API will trigger a qmake of this
# file, which in turn runs syncqt to update the forwarding headers.
build?(webkit1): QMAKE_INTERNAL_INCLUDED_FILES *= WebKit/WebKit1.pro
build?(webkit2): QMAKE_INTERNAL_INCLUDED_FILES *= WebKit2/Target.pri

use?(3D_GRAPHICS): WEBKIT += angle

MODULE = webkit

# This is the canonical list of dependencies for the public API of
# the QtWebKit library, and will end up in the library's prl file.
QT_API_DEPENDS = core gui network
build?(webkit1): QT_API_DEPENDS += widgets

# We load the relevant modules here, so that the effects of each module
# on the QT variable can be picked up when we later load(qt_module).
load(webkit_modules)

# ---------------- Custom developer-build handling -------------------
#
# The assumption for Qt developer builds is that the module file
# will be put into qtbase/mkspecs/modules, and the libraries into
# qtbase/lib, with rpath/install_name set to the Qt lib dir.
#
# For WebKit we don't want that behavior for the libraries, as we want
# them to be self-contained in the WebKit build dir.
#
CONFIG += force_independent

BASE_TARGET = $$TARGET

load(qt_module)

# Allow doing a debug-only build of WebKit (not supported by Qt)
macx:!debug_and_release:debug: TARGET = $$BASE_TARGET

# Make sure the install_name of the QtWebKit library point to webkit
macx {
    # We do our own absolute path so that we can trick qmake into
    # using the webkit build path instead of the Qt install path.
    CONFIG -= absolute_library_soname
    QMAKE_LFLAGS_SONAME = $$QMAKE_LFLAGS_SONAME$$WEBKIT_DESTDIR/

    !debug_and_release|build_pass {
        # We also have to make sure the install_name is correct when
        # the library is installed.
        change_install_name.depends = install_target

        # The install rules generated by qmake for frameworks are busted in
        # that both the debug and the release makefile copy QtWebKit.framework
        # into the install dir, so whatever changes we did to the release library
        # will get overwritten when the debug library is installed. We work around
        # that by running install_name on both, for both configs.
        change_install_name.commands = framework_dir=\$\$(dirname $(TARGETD)); \
            for file in \$\$(ls $$[QT_INSTALL_LIBS]/\$\$framework_dir/$$BASE_TARGET*); do \
                install_name_tool -id \$\$file \$\$file; \
            done
        default_install_target.target = install
        default_install_target.depends += change_install_name

        QMAKE_EXTRA_TARGETS += change_install_name default_install_target
    }
}

qnx {
    # see: https://bugs.webkit.org/show_bug.cgi?id=93460
    # the gcc 4.4.2 used in the qnx bbndk cannot cope with
    # the linkage step of libQtWebKit, adding a dummy .cpp
    # file fixes this though - so do this here
    dummyfile.target = dummy.cpp
    dummyfile.commands = touch $$dummyfile.target
    QMAKE_EXTRA_TARGETS += dummyfile
    GENERATED_SOURCES += $$dummyfile.target
}
