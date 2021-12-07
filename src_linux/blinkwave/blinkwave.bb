#
# This file is the blinkwave recipe.
#

SUMMARY = "Simple blinkwave application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://blinkwave.c \
	   file://Makefile \
		  "

S = "${WORKDIR}"

DEPENDS = " sigmadelta"

do_compile() {
        ${CC} ${CFLAGS} ${LDFLAGS} -o blinkwave blinkwave.c -lsigmadelta -lm
}

do_install() {
	     install -d ${D}${bindir}
	     install -m 0755 blinkwave ${D}${bindir}
}
