//
//  shared.h
//  BackToCatalina
//
//  Created by ittrgrey on 29/08/2026.
//

#include "../BackToCatalina.h"
#include "../ZKSwizzle.h"

static char BTCReplacementGlyphKey;
static inline void BTCMarkReplacementGlyph(NSImage *image) {
    if (image) objc_setAssociatedObject(image, &BTCReplacementGlyphKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
static inline BOOL BTCIsReplacementGlyph(NSImage *image) {
    return [objc_getAssociatedObject(image, &BTCReplacementGlyphKey) boolValue];
}

@interface NSImage (BTCGlyphSymbol)
- (BOOL)_isSymbolImage;
- (NSString *)_symbolName;
- (id)_reps;
@end

@interface NSObject (BTCGlyphRepresentation)
- (NSString *)symbolName;
@end

@interface NSWindow (GlyphRef)
- (id)_toolbarView;
@end

@interface NSImage (GlyphRef)
- (BOOL)_isSymbolImage;
@end

static inline NSString* GetSymbolName(NSImage* symbol) {
    if ([symbol respondsToSelector:@selector(_symbolName)]) {
        return [symbol _symbolName];
    }
    if ([symbol respondsToSelector:@selector(_reps)]) {
        id reps = [symbol _reps];
        if ([reps respondsToSelector:@selector(symbolName)]) {
            return [reps symbolName];
        }
    }
    return nil;
}

static const NSDictionary* toolbarGlyphMap = @{
    @"chevron.backward": @"Backarrow.pdf",
    @"chevron.left": @"Backarrow.pdf", // Different glyphs are used... when it's not a toolbar
    @"chevron.forward": @"Forwardarrow.pdf",
    @"chevron.right": @"Forwardarrow.pdf", // Different glyphs are used... when it's not a toolbar
    @"sidebar.left": @"sidebar.pdf",
    @"sidebar.leading": @"sidebar.pdf",
    @"square.and.arrow.up": @"share.pdf",
    @"rectangle.split.3x1": @"ViewSwitcherColumns.pdf",
    @"ellipsis": @"Gear.pdf",
    @"folder.badge.plus": @"newFolder.pdf",
    @"square.and.pencil": @"TB_NewTemplate.pdf",
    @"textformat.size.smaller": @"textSmaller.pdf",
    @"textformat.size.larger": @"textBigger.pdf",
    @"magnifyingglass": @"SearchMagGlass.pdf",
    @"info.circle": @"getInfoOutline.pdf",
    @"plus": @"plus.pdf",
    @"minus": @"minus.pdf",
    @"play.fill": @"Play.pdf",
    @"pause.fill": @"Pause.pdf",
    @"arrow.clockwise": @"RefreshButton.pdf",
    @"squares.below.rectangle": @"ToolbarGalleryView.pdf",
    @"square.grid.2x2": @"ToolbarIconView.pdf",
    @"square.grid.3x2": @"ToolbarIconView.pdf",
    @"square.grid.3x1.below.line.grid.1x2": @"ToolbarArrangeByTemplate.pdf",
    @"square.grid.4x3.fill": @"TopSitesButton.pdf",
    @"list.bullet": @"ViewSwitcherList.pdf",
    @"tag": @"ToolbarTagIcon.pdf",
    @"arrow.down.circle": @"transfer-download.pdf",
    @"arrow.down": @"ToolbarDownloadsArrow.pdf",
    @"square.on.square": @"ToolbarButtonTabOverview.pdf",
    @"star": @"ToolbarBookmarksBar.pdf",
    @"printer": @"print.pdf",
    @"rectangle.and.pencil.and.ellipsis": @"autofill.pdf",
    @"house": @"home.pdf",
    @"gearshape": @"Gear.pdf",
    @"icloud": @"CloudTabs.pdf",
    @"envelope": @"ToolbarEmail.pdf",
    @"clock": @"ToolbarHistory.pdf",
    @"plus.circle": @"plusEnclosed.pdf",
    @"speaker.wave.2.fill": @"SpeakerWithSoundStroke.pdf",
};

static const NSDictionary* prefsGlyphMap = @{
    // General
    @"gearshape": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/General.icns",
    @"slider.horizontal.3": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/General.icns",
    @"sidebar.left": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarPrefs.icns",
    @"sidebar.leading": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarPrefs.icns",
    @"tag": @"PrefToolbarTagsIcon_32",
    @"gearshape.2": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarAdvanced.icns",
    @"wrench.and.screwdriver": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarCustomizeIcon.icns",
    @"at": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Accounts.icns",
    @"folder": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericFolderIcon.icns",
    @"bell": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Actions.icns",
    @"info.circle": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarInfo.icns",
    @"info.circle.fill": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarInfo.icns",
    
    // Safari
    @"lock": @"SecurityPreferences",
    @"square.on.square": @"TabsPreferences",
    @"puzzlepiece.extension": @"ExtensionsPreferences",
    @"key": @"PasswordsPreferences",
    @"hand.raised": @"PrivacyPreferences",
    @"rectangle.and.pencil.and.ellipsis": @"AutoFillPreferencesNew",
    @"magnifyingglass": @"SearchPreferencesNew",
    @"globe": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns", // overlaps with Terminal
    @"person": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/VCard.icns",
    @"person.crop.square.filled.and.at.rectangle": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/VCard.icns",
    @"flag.and.flag.filled.crossed": @"FeatureFlags",
    
    // Playback (shared across a few applications)
    @"play.circle": @"PreferencesPlaybackButton",
    
    // Mail
    @"xmark.bin": @"junkmail",
    @"textformat": @"FontsAndColorPreferences",
    @"eyeglasses": @"ViewerPreferences",
    @"square.and.pencil": @"ComposingPreferences",
    @"signature": @"SignaturePreferences",
    @"envelope.arrow.triangle.branch": @"RulesPreferences",
    @"envelope.and.arrow.trianglehead.branch": @"RulesPreferences",
    
    // Contacts
    @"square.and.at.rectangle": @"ABTemplatePreferencesModule",
    @"person.crop.square.fill.and.at.rectangle": @"ABVCardPreferencesModule",
    
    // Books
    @"icloud": @"iCloud",
    @"book": @"iBooksAppIcon", // Not anatomically correct, but I'm not sure what else would be appropriate
    
    // Preview
    @"photo.on.rectangle": @"TB_PrefsImages",
    @"text.document": @"TB_PrefsPDF",
    
    // ColorSync Utility
    @"cross.circle": @"FirstAid",
    @"doc.badge.gearshape": @"Profiles",
    @"display": @"Devices",
    @"camera.filters": @"Filters",
    @"calculator": @"Calculator",
    
    // Grapher
    @"number": @"NumberPreferences",
    @"sum": @"EquationPreferences",
    
    // Script Editor
    @"pencil": @"SEEditingPreferences",
    @"clock": @"SEHistoryPreferences",
    
    // Audio MIDI Setup
    @"hifispeaker.2": @"SpeakerIcon",
    
    // Terminal
    @"rectangle.3.offgrid": @"TTPreferencesWindowGroups",
};

// Resolve app-specific overlaps
static const NSDictionary* applicationPrefsGlyphMap = @{
    @"com.apple.Terminal": @{
        @"doc.badge.gearshape": @"TTPreferencesProfiles",
        @"globe": @"TTPreferencesEncodings",
    }
};

static const NSDictionary* finderSidebarGlyphMap = @{
    // Finder
    @"clock": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarRecents.icns",
    @"appstore": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarApplicationsFolder.icns",
    @"menubar.dock.rectangle": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDesktopFolder.icns",
    @"doc": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDocumentsFolder.icns",
    @"document": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDocumentsFolder.icns",
    @"arrow.down.circle": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDownloadsFolder.icns",
    @"film": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMoviesFolder.icns",
    @"music": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMusicFolder.icns",
    @"camera": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarPicturesFolder.icns",
    @"photo": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarPicturesFolder.icns",
    @"house": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarHomeFolder.icns",
    @"icloud": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariCloud.icns",
    @"display": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDisplay.icns",
    @"desktopcomputer": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariMac.icns",
    @"macmini": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacMini.icns",
    @"macmini.gen2": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacMini.icns",
    @"macmini.gen3": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacMini.icns",
    @"macmini.fill": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacMini.icns",
    @"macmini.gen2.fill": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacMini.icns",
    @"macmini.gen3.fill": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacMini.icns",
    @"macpro.gen1": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacPro.icns",
    @"macpro.gen2": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacProCylinder.icns",
    @"macpro.gen3": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacPro.icns",
    @"macpro.gen3.server": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacPro.icns",
    @"macpro.gen1.fill": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacPro.icns",
    @"macpro.gen2.fill": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacProCylinder.icns",
    @"macpro.gen3.fill": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacPro.icns",
    @"macpro.gen3.server.fill": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacPro.icns",
    @"xserve": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarXserve.icns",
    @"xserve.raid": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarXserve.icns",
    @"iphone": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPhone.icns",
    @"iphone.gen1": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPhone.icns",
    @"iphone.gen2": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPhone.icns",
    @"iphone.gen3": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPhone.icns",
    @"ipod.touch": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPodTouch.icns",
    @"ipad": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPad.icns",
    @"ipad.landscape": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPad.icns",
    @"ipad.gen1": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPad.icns",
    @"ipad.gen1.landscape": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPad.icns",
    @"ipad.gen2": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPad.icns",
    @"ipad.gen2.landscape": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariPad.icns",
    @"laptopcomputer": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarLaptop.icns",
    @"macbook": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarLaptop.icns",
    @"macbook.gen1": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarLaptop.icns",
    @"macbook.gen2": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarLaptop.icns",
    @"internaldrive": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarInternalDisk.icns",
    @"externaldrive": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarExternalDisk.icns",
    @"externaldrive.connected.to.line.below": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarServerDrive.icns",
    @"opticaldisc": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarOpticalDisk.icns",
    @"bonjour": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarBonjour.icns",
    @"pc": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarPC.icns",
    @"building.columns.fill": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarGenericFolder.icns",
    @"folder": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarGenericFolder.icns",
    @"hammer": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarGenericFolder.icns",
    @"figure.walk.diamond": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarGenericFolder.icns",
    @"network": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarNetwork.icns",
    @"wrench.and.screwdriver.fill": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarUtilitiesFolder.icns",
    @"airdrop": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarAirDrop.icns",
    @"gearshape": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarSmartFolder.icns",
    @"burn": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarBurnFolder.icns",
};
    
static const NSDictionary* sidebarGlyphMap = @{
    // Below are still disabled due to conflicts with other types
    // TODO - add application-specific overrides here
    // For now we defer to legacy NSImage hooks here, which still take priority
    // Any overrides will need to take priority over the "generic" icons used by Finder etc
#if 0
    // Apple Music
    @"home": @"com.apple.Music.sidebar_ForYouMedium_Normal",
    @"square.grid.2x2": @"com.apple.Music.sidebar_BrowseMedium_Normal",
    @"dot.radiowaves.left.and.right": @"com.apple.Music.sidebar_RadioMedium_Normal",
    @"clock": @"com.apple.Music.sidebar_RecentlyAddedMedium_Normal",
    @"music.mic": @"com.apple.Music.sidebar_ArtistsMedium_Normal",
    @"square.stack": @"com.apple.Music.sidebar_AlbumsMedium_Normal",
    @"music.note": @"com.apple.Music.sidebar_SongsMedium_Normal",
    @"guitars": @"com.apple.Music.sidebar_GenresMedium_Normal",
    @"music.quarternote.3": @"com.apple.Music.sidebar_ComposersMedium_Normal",
    @"tv.music.note": @"com.apple.Music.sidebar_MusicVideosMedium_Normal",
    @"tv": @"com.apple.Music.sidebar_TVandMoviesMedium_Normal",
    @"person.crop.square": @"com.apple.Music.sidebar_ForYouMedium_Normal",
    @"star": @"com.apple.Music.sidebar_iTunesStoreMedium_Normal",
    @"square.grid.3x3": @"com.apple.Music.sidebar_SmartPlaylistMedium_Normal",
    @"gearshape": @"com.apple.Music.sidebar_SmartPlaylistMedium_Normal", // Dark
    @"music.note.list": @"com.apple.Music.sidebar_PlaylistMedium_onLight_Normal",
    @"folder": @"com.apple.Music.sidebar_FolderMedium_Normal", // Dark
    @"opticaldisc": @"com.apple.Music.sidebar_CDMedium_Normal", // Dark
    @"person.2": @"com.apple.Music.sidebar_CompilationsMedium_Normal", // Dark
    
    // Pages
    @"sidebar.leading": @"sf_tb_view",
    @"plus.square": @"sf_tb_insert_addpage",
    @"text.badge.plus": @"sf_tb_insert_WP",
    @"tablecells": @"sf_tb_insert_table",
    @"chart.pie": @"sf_tb_insert_chart",
    @"textbox": @"sf_tb_insert_text",
    @"square.on.circle": @"sf_tb_insert_shape",
    @"photo": @"sf_tb_insert_media",
    @"paperclip": @"sf_tb_insert_media",
    @"text.bubble": @"sf_tb_insert_comment",
    @"paintbrush": @"sf_tb_inspector_format-N",
    @"doc.text.rtl": @"sf_tb_pg_document-N",
    @"square.2.stack.3d.top.fill": @"sf_tb_arrange_forward",
    @"square.2.stack.3d.bottom.fill": @"sf_tb_arrange_backward",
    @"square.3.stack.3d.top.fill": @"sf_tb_arrange_front",
    @"square.3.stack.3d.bottom.fill": @"sf_tb_arrange_back",
    @"flip.horizontal": @"sf_tb_arrange_flipH",
    @"sf_tb_arrange_flipV": @"sf_tb_arrange_flipV_legacy",
    @"sf_tb_arrange_group": @"sf_tb_arrange_group_legacy",
    @"sf_tb_arrange_ungroup": @"sf_tb_arrange_ungroup_legacy",
    @"sf_tb_text_biggertext": @"sf_tb_text_biggertext_legacy",
    @"sf_tb_text_smallertext": @"sf_tb_text_smallertext_legacy",
    @"textformat.superscript": @"sf_tb_text_superscript",
    @"textformat.subscript": @"sf_tb_text_subscript",
    @"sf_tb_text_outdent": @"sf_tb_text_outdent_legacy",
    @"decrease.indent": @"sf_tb_text_outdent_legacy",
    @"increase.indent": @"sf_tb_text_indent",
    @"sf_tb_text_tracking": @"sf_tb_text_tracking_legacy",
    @"sf_tb_style_copy": @"sf_tb_style_copy_legacy",
    @"sf_tb_style_paste": @"sf_tb_style_paste_legacy",
    @"rectangle.split.3x3": @"sf_tb_view_guides",
    @"crop": @"sf_tb_style_mask",
    @"lock": @"sf_tb_misc_lock",
    @"lock.open": @"sf_tb_misc_unlock",
    @"textformat": @"sf_tb_text_fonts",
    @"arrowshape.turn.up.forward.circle": @"sf_tb_misc_hyperlinks",
    @"slider.horizontal.3": @"sf_tb_style_adjust",
    @"printer": @"sf_tb_misc_print",
    
    // Numbers
    @"sidebar.leading": @"sf_tb_view",
    @"list.triangle": @"sf_tb_categories",
    @"sf_tb_icon_funcinsert": @"sf_tb_icon_funcinsert_legacy",
    @"tablecells": @"sf_tb_insert_table",
    @"chart.pie": @"sf_tb_insert_chart",
    @"textbox": @"sf_tb_insert_text",
    @"square.on.circle": @"sf_tb_insert_shape",
    @"photo": @"sf_tb_insert_media",
    @"paperclip": @"sf_tb_insert_media",
    @"text.bubble": @"sf_tb_insert_comment",
    @"paintbrush": @"sf_tb_inspector_format-N",
    @"line.horizontal.3.decrease.circle": @"sf_tb_inspector_organize_off-N",
    @"square.2.stack.3d.top.fill": @"sf_tb_arrange_forward",
    @"square.2.stack.3d.bottom.fill": @"sf_tb_arrange_backward",
    @"square.3.stack.3d.top.fill": @"sf_tb_arrange_front",
    @"square.3.stack.3d.bottom.fill": @"sf_tb_arrange_back",
    @"flip.horizontal": @"sf_tb_arrange_flipH",
    @"sf_tb_arrange_flipV": @"sf_tb_arrange_flipV_legacy",
    @"sf_tb_arrange_group": @"sf_tb_arrange_group_legacy",
    @"sf_tb_arrange_ungroup": @"sf_tb_arrange_ungroup_legacy",
    @"sf_tb_text_biggertext": @"sf_tb_text_biggertext_legacy",
    @"sf_tb_text_smallertext": @"sf_tb_text_smallertext_legacy",
    @"textformat.superscript": @"sf_tb_text_superscript",
    @"textformat.subscript": @"sf_tb_text_subscript",
    @"decrease.indent": @"sf_tb_text_outdent_legacy",
    @"sf_tb_text_outdent": @"sf_tb_text_outdent_legacy",
    @"increase.indent": @"sf_tb_text_indent",
    @"sf_tb_style_copy": @"sf_tb_style_copy_legacy",
    @"sf_tb_style_paste": @"sf_tb_style_paste_legacy",
    @"rectangle.split.3x3": @"sf_tb_view_guides",
    @"crop": @"sf_tb_style_mask",
    @"lock": @"sf_tb_misc_lock",
    @"lock.open": @"sf_tb_misc_unlock",
    @"textformat": @"sf_tb_text_fonts",
    @"arrowshape.turn.up.forward.circle": @"sf_tb_misc_hyperlinks",
    @"slider.horizontal.3": @"sf_tb_style_adjust",
    @"printer": @"sf_tb_misc_print",
    
    // Keynote
    @"sidebar.leading": @"sf_tb_view",
    @"plus.rectangle": @"sf_tb_insert_addslide",
    @"tablecells": @"sf_tb_insert_table",
    @"chart.pie": @"sf_tb_insert_chart",
    @"textbox": @"sf_tb_insert_text",
    @"square.on.circle": @"sf_tb_insert_shape",
    @"photo": @"sf_tb_insert_media",
    @"paperclip": @"sf_tb_insert_media",
    @"text.bubble": @"sf_tb_insert_comment",
    @"paintbrush": @"sf_tb_inspector_format-N",
    @"sf_tb_inspector_animation": @"sf_tb_inspector_animation-N",
    @"rectangle.center.inset.fill": @"sf_tb_kn_document-N",
    @"play.rectangle.fill": @"sf_tb_showmode_rehearse",
    @"list.bullet": @"sf_tb_view_elist",
    @"sf_tb_view_masters": @"sf_tb_view_masters_legacy",
    @"sf_tb_showmode_skip": @"sf_tb_showmode_skip_legacy",
    @"record.circle": @"sf_tb_showmode_record",
    @"square.2.stack.3d.top.fill": @"sf_tb_arrange_forward",
    @"square.2.stack.3d.bottom.fill": @"sf_tb_arrange_backward",
    @"square.3.stack.3d.top.fill": @"sf_tb_arrange_front",
    @"square.3.stack.3d.bottom.fill": @"sf_tb_arrange_back",
    @"flip.horizontal": @"sf_tb_arrange_flipH",
    @"sf_tb_arrange_flipV": @"sf_tb_arrange_flipV_legacy",
    @"sf_tb_arrange_group": @"sf_tb_arrange_group_legacy",
    @"sf_tb_arrange_ungroup": @"sf_tb_arrange_ungroup_legacy",
    @"sf_tb_text_biggertext": @"sf_tb_text_biggertext_legacy",
    @"sf_tb_text_smallertext": @"sf_tb_text_smallertext_legacy",
    @"textformat.superscript": @"sf_tb_text_superscript",
    @"textformat.subscript": @"sf_tb_text_subscript",
    @"sf_tb_text_outdent": @"sf_tb_text_outdent_legacy",
    @"decrease.indent": @"sf_tb_text_outdent_legacy",
    @"increase.indent": @"sf_tb_text_indent",
    @"sf_tb_style_connect": @"sf_tb_style_connect_legacy",
    @"sf_tb_style_copy": @"sf_tb_style_copy_legacy",
    @"sf_tb_style_paste": @"sf_tb_style_paste_legacy",
    @"rectangle.split.3x3": @"sf_tb_view_guides",
    @"crop": @"sf_tb_style_mask",
    @"circle.rectangle.filled.pattern.diagonalline": @"sf_tb_style_alpha_legacy",
    @"lock": @"sf_tb_misc_lock",
    @"lock.open": @"sf_tb_misc_unlock",
    @"textformat": @"sf_tb_text_fonts",
    @"arrowshape.turn.up.forward.circle": @"sf_tb_misc_hyperlinks",
    @"slider.horizontal.3": @"sf_tb_style_adjust",
    @"magnifyingglass": @"sf_tb_misc_find",
    @"printer": @"sf_tb_misc_print",
#endif
};
