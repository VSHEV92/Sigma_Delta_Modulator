#
# This file is the libsigmadelta recipe.
#

SUMMARY = "Simple libsigmadelta application"
SECTION = "PETALINUX/libs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://sigmadelta.c \ 
	   file://sigmadelta.h \
	   file://Makefile \
		  "

S = "${WORKDIR}"

PACKAGE_ARCH = "${MACHINE_ARCH}"
PROVIDES = "sigmadelta"
TARGET_CC_ARCH += "${LDFLAGS}"

do_install() {
	     install -d ${D}${libdir}    
	     install -d ${D}${includedir}    
	     oe_libinstall -so libsigmadelta ${D}${libdir}    
	     install -d -m 0655 ${D}${includedir}/SIGMADELTA    
	     install -m 0644 ${S}/*.h ${D}${includedir}/SIGMADELTA/
}

FILES_${PN} = "${libdir}/*.so.* ${includedir}/*"    
FILES_${PN}-dev = "${libdir}/*.so"
