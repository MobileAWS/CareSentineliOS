//
//  Constants.h
//  BedAlert
//
//  Created by Phill Giancarlo on 7/18/11.
//  Copyright 2011-2013 AppPotential, LLC. All rights reserved.
//


// -- Names and Domains
#define kDomainApp                  @"CareSentinelErrorDomain"
#define kNameApp                    @"CareSentinel"

// -- Colors
#define kOpacityIndicatorBackground 0.10f
#define kColorShadow                RGBA(0.0f, 0.0f, 0.0f, 0.10f)

#define kColorCellUnselectedTop     RGBA(58.0f, 58.0f, 58.0f, 0.35f)////RGBA(84.0f, 159.0f, 66.0f, 0.15f)
#define kColorCellUnselectedBottom  RGBA(58.0f, 58.0f, 58.0f, 0.35f)////RGBA(84.0f, 159.0f, 66.0f, 0.15f)

#define kColorCellSelectedTop       RGBA(255.0f, 255.0f, 255.0f, 0.50f)
#define kColorCellSelectedBottom    RGBA(255.0f, 255.0f, 255.0f, 0.50f)
#define kColorTopToolbarTint        RGB(58.0f, 58.0f, 58.0f)
#define kColorBlueTint              RGB(0.0f, 100.0f, 201.0f)
#define kColorTextActive            RGB(255.0f, 255.0f, 255.0f)
#define kColorTextInactive          RGB(255.0f, 239.0f, 168.0f)
#define kColorInfoLabel             RGB(94.0f, 109.0f, 86.0f)
#define kColorNavbar                RGB(30.0f, 129.0f, 180.0f)////RGB(84.0f, 159.0f, 66.0f)
#define kColorShadowInfoLabel       [UIColor colorWithWhite:0.15f alpha:0.10f]
#define kColorAPDialogBackground    RGB(255.0f, 255.0f, 255.0f)
#define kColorAccentTransparent     RGBA(255.0f, 255.0f, 255.0f, 0.50f)
#define kColorAccentLight           RGB(30.0f, 129.0f, 180.0f)////RGB(84.0f, 159.0f, 66.0f)
#define kColorAccentLightOutline    RGBA(30.0f, 129.0f, 180.0f, 0.15f)////RGBA(84.0f, 159.0f, 66.0f, 0.15f)
#define kColorAccentLightTransparent RGBA(201.0f, 183.0f, 152.0f, .20f)
#define kColorAccentDark            RGB(33.0f, 63.0f, 83.0f)////RGB(20.0f, 95.0f, 2.0f)
#define kColorAccentDarkOutline     RGBA(20.0f, 95.0f, 2.0f, 0.15f)
#define kColorAccentDarkTransparent RGBA(107.0f, 103.0f, 91.0f, 0.20f)
#define kColorCellText              [UIColor whiteColor]
#define kColorHighlightStrong       RGB(200.00f, 50.0f, 60.0f)
#define kColorAlertBackground       RGBA(239.0f, 146.0f, 11.0f, 0.50f)
#define kColorCallActiveBackground  RGBA(255.0f, 242.0f, 55.0f, 0.50f)
#define kColorDevHeaderBackground   RGBA(30.0f, 129.0f, 180.0f, 0.50f)////RGBA(210.0f, 210.0f, 240.0f, 0.50f)
#define kColorTextAlertHighlight    RGB(255.0f, 162.0f, 27.0f)

// -- Backgrounds
#define kImageBackdrop               @"Pattern-Cloth"
#define kImageBackgroundMain         @"Pattern-Cloth"
#define kImageBackgroundDefaultTitle @"Background-1"
#define kImageBackgroundUserTitle    @"MyBackground"
#define kImageInsetPanel             @"inset-panel"
#define kImageToolbarBackground      @"Background-Toolbar-Main"
#define kImageBackgroundTabBar       @"Background-Tab-Bar"

// -- Images
#define kImageBattery5              @"Battery-5"
#define kImageBattery4              @"Battery-4"
#define kImageBattery3              @"Battery-3"
#define kImageBattery2              @"Battery-2"
#define kImageBattery1              @"Battery-1"
#define kImageDeviceConnected5      @"Connected-5"
#define kImageDeviceConnected4      @"Connected-4"
#define kImageDeviceConnected3      @"Connected-3"
#define kImageDeviceConnected2      @"Connected-2"
#define kImageDeviceConnected1      @"Connected-1"
#define kImageDeviceDisconected     @"Disconnected"
#define kImageButtonChecked         @"Checked"
#define kImageButtonUnchecked       @"Unchecked"

// -- Fonts
#define kTextfieldFontName          @"HelveticaNeue-Medium"
#define kTextfieldFontSize          16.0f
#define kTextfieldFont              [UIFont fontWithName:kTextfieldFontName size:kTextfieldFontSize]
#define kFontTitleBar               [UIFont fontWithName:@"ArialRoundedMTBold" size:22.0f]
#define kFontTitleLabel             [UIFont fontWithName:@"ArialRoundedMTBold" size:17.0f]
#define kFontTableHeader            @"Futura-Medium"
#define kFontTableHeaderSize        24.0f
#define kPlainCellTextFont          @"HelveticaNeue-Light"
#define kPlainCellTextFontSize      17.0f
#define kPlainCellTextFontSizeLarge 22.0f
#define kPlainCellDetailTextFont    @"HelveticaNeue-Light"
#define kPlainCellDetailTextSize    14.0f

// -- Control ID Tags
#define kTagCellAlertImage           5
#define kTagCellBatteryImage        10
#define kTagCellConnectedImage      15

// -- Sizes
#define kStatusBarHeight            20.0f
#define kHeightAlertImage           48.0f
#define kWidthAlertImage            42.0f
#define kHeightBatteryImage         15.0f
#define kWidthBatteryImage          28.0f
#define kHeightConnectedImage       14.0f
#define kWidthConnectedImage        19.0f

// -- Thresholds
#define kThresholdLowBatteryLEvel   15

// -- P-List Files
#define kPListFileType              @"plist"
#define kPListBLEDeviceTypes        @"DeviceTypesList"

////// -- Audio Player Status Change Message
////#define kPlayerPlayingNotification  @"com.AppPotential.BedAlert.PlayerControlPlaying"
////#define kPlayerPausedNotification   @"com.AppPotential.BedAlert.PlayerControlPaused"
////#define kPlayerClosedNotification   @"com.AppPotential.BedAlert.PlayerControlClosed"

// -- Time Intervals
#define kTimeIntervalBatteryCheck   300.0f
#define kTimeIntervalProximityCheck   7.5f
#define kTimeIntervalAlertReplay     10.0f

