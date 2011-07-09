include theos/makefiles/common.mk

BUNDLE_NAME = CalendarColors
CalendarColors_FILES = CalendarUtils.mm CalendarColors.mm
CalendarColors_INSTALL_PATH = /Library/PreferenceBundles
CalendarColors_FRAMEWORKS = UIKit CoreGraphics
CalendarColors_PRIVATE_FRAMEWORKS = Preferences
CalendarColors_LDFLAGS = -lsqlite3
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CalendarColors.plist$(ECHO_END)
