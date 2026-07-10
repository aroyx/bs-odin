grep '#define ICON_LUCIDE_' lucide.h | sed -E 's/#define (ICON_LUCIDE_[A-Z0-9_]+) u8"\\u([0-9a-fA-F]+)"/    0x\2, \/\/ \1/'
