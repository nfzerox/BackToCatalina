#import "BackToCatalina.h"
#import <Cocoa/Cocoa.h>
#import "BackToCatalina.h"
#import "ZKSwizzle.h"

static const NSDictionary *appSymbolMaps = @{
    @"com.apple.iWork.Keynote" :@{
        @"sidebar.leading": @"sf_tb_view",
        @"plus.rectangle": @"sf_tb_insert_addslide",
#if 0
        @"play.fill": @"sf_tb_play", // Blank for some reason
#endif
        @"tablecells": @"sf_tb_insert_table",
        @"chart.pie": @"sf_tb_insert_chart",
        @"textbox": @"sf_tb_insert_text",
        @"square.on.circle": @"sf_tb_insert_shape",
        @"photo": @"sf_tb_insert_media",
        @"text.bubble": @"sf_tb_insert_comment",
        @"paintbrush": @"sf_tb_inspector_format-N",
        @"sf_tb_inspector_animation": @"sf_tb_inspector_animation-N",
        @"rectangle.center.inset.fill": @"sf_tb_kn_document-N",
#if 0
        @"play.rectangle.on.rectangle": @"sf_tb_play_windowed", // Blank for some reason
#endif
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
        @"increase.indent": @"sf_tb_text_indent",
        @"sf_tb_style_connect": @"sf_tb_style_connect_legacy",
        @"sf_tb_style_copy": @"sf_tb_style_copy_legacy",
        @"sf_tb_style_paste": @"sf_tb_style_paste_legacy",
        @"rectangle.split.3x3": @"sf_tb_view_guides",
        @"crop": @"sf_tb_style_mask",
#if 0
        @"circle.rectangle.filled.pattern.diagonalline": @"sf_tb_style_alpha_legacy", // Shown with xmark
#endif
        @"lock": @"sf_tb_misc_lock",
        @"lock.open": @"sf_tb_misc_unlock",
        @"textformat": @"sf_tb_text_fonts",
        @"arrowshape.turn.up.forward.circle": @"sf_tb_misc_hyperlinks",
        @"slider.horizontal.3": @"sf_tb_style_adjust",
#if 0
        @"magnifyingglass": @"sf_tb_misc_find", // Conflicts with Find & Replace panel
#endif
        @"printer": @"sf_tb_misc_print",
    },
    @"com.apple.iWork.Numbers" :@{
        @"sidebar.leading": @"sf_tb_view",
        @"list.triangle": @"sf_tb_categories",
        @"sf_tb_icon_funcinsert": @"sf_tb_icon_funcinsert_legacy",
        @"tablecells": @"sf_tb_insert_table",
        @"chart.pie": @"sf_tb_insert_chart",
        @"textbox": @"sf_tb_insert_text",
        @"square.on.circle": @"sf_tb_insert_shape",
        @"photo": @"sf_tb_insert_media",
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
    },
    @"com.apple.iWork.Pages" :@{
        @"sidebar.leading": @"sf_tb_view",
        @"plus.square": @"sf_tb_insert_addpage",
        @"text.badge.plus": @"sf_tb_insert_WP",
        @"tablecells": @"sf_tb_insert_table",
        @"chart.pie": @"sf_tb_insert_chart",
        @"textbox": @"sf_tb_insert_text",
        @"square.on.circle": @"sf_tb_insert_shape",
        @"photo": @"sf_tb_insert_media",
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
    },
    @"com.apple.finder": @{
        @"clock": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarRecents.icns",
        @"appstore": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarApplicationsFolder.icns",
        @"menubar.dock.rectangle": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDesktopFolder.icns",
        @"doc": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDocumentsFolder.icns",
        @"arrow.down.circle": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDownloadsFolder.icns",
        @"film": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMoviesFolder.icns",
        @"music": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMusicFolder.icns",
        @"camera": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarPicturesFolder.icns",
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
#if 0
        @"airdrop": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarAirDrop.icns", // Conflicts with toolbar
        @"gearshape": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarSmartFolder.icns", // Conflicts with Settings window
        @"burn": @"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarBurnFolder.icns", // Conflicts with toolbar
#endif
    },
    @"com.apple.Music": @{
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
#if 0
        @"star": @"com.apple.Music.sidebar_iTunesStoreMedium_Normal",
        @"square.grid.3x3": @"com.apple.Music.sidebar_SmartPlaylistMedium_Normal",
        @"gearshape": @"com.apple.Music.sidebar_SmartPlaylistMedium_Normal", // Dark
        @"music.note.list": @"com.apple.Music.sidebar_PlaylistMedium_onLight_Normal",
        @"folder": @"com.apple.Music.sidebar_FolderMedium_Normal", // Dark
        @"opticaldisc": @"com.apple.Music.sidebar_CDMedium_Normal", // Dark
        @"person.2": @"com.apple.Music.sidebar_CompilationsMedium_Normal", // Dark
#endif
    }
};

hook(NSImage)
+ (instancetype)_imageWithSymbolName:(NSString *)symbolName inCatalog:(id)catalog variableValue:(double)variableValue accessibilityDescription:(NSString *)accessibilityDescription createdWithCompatibilityImageName:(BOOL)createdWithCompatibilityImageName {
#if DEBUG
    BOOL needsLogging = YES;
    BOOL needsDetailedLogging = NO;
    if (needsLogging || needsDetailedLogging) {
        NSLog(@"[SYMBOL] %@", symbolName);
    }
    if (needsDetailedLogging) {
        for (NSString *symbol in NSThread.callStackSymbols) {
            NSLog(@"[SYMBOL] %@", symbol);
        }
    }
#endif
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *symbolMap = appSymbolMaps[bundleIdentifier];
    BOOL isFinder = [bundleIdentifier isEqualToString:@"com.apple.finder"];
    BOOL isMusic = [bundleIdentifier isEqualToString:@"com.apple.Music"];
    if (symbolMap) {
        NSString *assetName = symbolMap[symbolName];
        if (assetName.length) {
            // For iWork apps only for now. This depends on the asset still being present in the current app bundle.
            NSImage *image;
            if (isFinder) {
                image = [[NSImage alloc] initWithContentsOfFile:assetName];
                image.template = YES;
            } else if (isMusic) {
                image = [carBundle imageForResource:assetName];
            } else {
                image = [NSBundle.mainBundle imageForResource:assetName];
            }
            return image;
        }
    }
    return _orig(id, symbolName, catalog, variableValue, accessibilityDescription, createdWithCompatibilityImageName);
}
endhook
