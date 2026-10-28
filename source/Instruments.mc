import Toybox.Lang;

// Presets store open-string MIDI note numbers, lowest string first.
module Instruments {
    function names() as Array<String> {
        return [
            "Standard (EADGBE)", "Drop D", "DADGAD", "Open G", "Open D", "Half step down", "Full step down",
            "Bass 4", "Bass 5", "Ukulele", "Violin", "Viola", "Cello", "Mandolin", "Banjo"
        ];
    }

    // Preset indices shown in the "Guitar tunings" and "Other instruments" menus.
    function guitarPresets() as Array<Number> { return [0, 1, 2, 3, 4, 5, 6]; }
    function otherPresets() as Array<Number> { return [7, 8, 9, 10, 11, 12, 13, 14]; }

    function notes(index as Number) as Array<Number> {
        switch (index) {
            case 0: return [40, 45, 50, 55, 59, 64];
            case 1: return [38, 45, 50, 55, 59, 64];
            case 2: return [38, 45, 50, 55, 57, 62];
            case 3: return [38, 43, 50, 55, 59, 62];
            case 4: return [38, 45, 50, 54, 57, 62];
            case 5: return [39, 44, 49, 54, 58, 63];
            case 6: return [38, 43, 48, 53, 57, 62];
            case 7: return [28, 33, 38, 43];
            case 8: return [23, 28, 33, 38, 43];
            case 9: return [67, 60, 64, 69];
            case 10: return [55, 62, 69, 76];
            case 11: return [48, 55, 62, 69];
            case 12: return [36, 43, 50, 57];
            case 13: return [55, 62, 69, 76];
            default: return [67, 50, 55, 59, 62];
        }
    }
}
