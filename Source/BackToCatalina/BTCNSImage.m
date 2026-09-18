#include "BackToCatalina.h"
#include "ZKSwizzle.h"

static const NSDictionary *appSymbolMaps = @{
    @"com.apple.Keynote" :@{
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
        @"paperclip": @"sf_tb_insert_media",
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
        @"decrease.indent": @"sf_tb_text_outdent_legacy",
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
    @"com.apple.Numbers" :@{
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
    },
    @"com.apple.Pages" :@{
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

static const NSDictionary *appBundleIdentifierMaps = @{
    @"com.apple.iWork.Keynote": @"com.apple.Keynote",
    @"com.apple.iWork.Numbers": @"com.apple.Numbers",
    @"com.apple.iWork.Pages": @"com.apple.Pages",
};

static NSDictionary *selectedAppSymbolMap;
static BOOL selectedAppUsesStyleBundle;

static void BTCSelectAppSymbolMap(NSString *bundleIdentifier) {
    bundleIdentifier = appBundleIdentifierMaps[bundleIdentifier] ?: bundleIdentifier;
    selectedAppSymbolMap = appSymbolMaps[bundleIdentifier];
    selectedAppUsesStyleBundle = [bundleIdentifier isEqualToString:@"com.apple.Music"];
}

__attribute__((constructor)) static void BTCInstallAppSymbolHooks(void) {
    BTCSelectAppSymbolMap(NSBundle.mainBundle.bundleIdentifier);
    BOOL install = selectedAppSymbolMap != nil;
#if DEBUG && defined(BTC_TRACE_SYMBOLS)
    install = YES;
#endif
    if (install) ZKSwizzleGroup(BTCAppSymbols);
}

ZKSwizzleInterfaceGroup(BTCAppSymbolImage, NSImage, NSObject, BTCAppSymbols)
@implementation BTCAppSymbolImage
+ (instancetype)_imageWithSymbolName:(NSString *)symbolName inCatalog:(id)catalog variableValue:(double)variableValue accessibilityDescription:(NSString *)accessibilityDescription createdWithCompatibilityImageName:(BOOL)createdWithCompatibilityImageName {
#if DEBUG && defined(BTC_TRACE_SYMBOLS)
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
    if (selectedAppSymbolMap) {
        NSString *assetName = selectedAppSymbolMap[symbolName];
        if (assetName.length) {
            // For iWork apps only for now. This depends on the asset still being present in the current app bundle.
            NSImage *image;
            if (selectedAppUsesStyleBundle && carBundle) {
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

hook(NSImageCell)

- (void)_setSidebarTintConfiguration:(NSTintConfiguration*)tintConfiguration {
    if (tintConfiguration == [NSTintConfiguration defaultTintConfiguration]) {
        // Restore legacy behaviour for sidebar tinting...
        tintConfiguration = [NSTintConfiguration monochromeTintConfiguration];
    }
    
    return ZKOrig(void, tintConfiguration);
}

endhook

hook(NSImageView)

- (void)_setSidebarTintConfiguration:(NSTintConfiguration*)tintConfiguration {
    if (tintConfiguration == [NSTintConfiguration defaultTintConfiguration]) {
        // Restore legacy behaviour for sidebar tinting...
        tintConfiguration = [NSTintConfiguration monochromeTintConfiguration];
    }
    
    return ZKOrig(void, tintConfiguration);
}

endhook
