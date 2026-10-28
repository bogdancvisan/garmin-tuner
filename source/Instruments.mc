import Toybox.Lang;

// Instrument groups, each with one or more tunings. Notes are open-string MIDI numbers, lowest first.
// The last group is "Chromatic": it shows any note and has no strings.
module Instruments {
    const CHROMATIC = 8;

    function groupNames() as Array<String> {
        return ["Guitar", "Bass", "Ukulele", "Violin", "Viola", "Cello", "Mandolin", "Banjo", "Chromatic"];
    }

    function tuningNames(g as Number) as Array<String> {
        switch (g) {
            case 0: return ["Standard", "Drop D", "DADGAD", "Open G", "Open D", "Half step down", "Full step down"];
            case 1: return ["4-string", "4-string Drop D", "5-string", "4-string half down"];
            case 2: return ["Soprano GCEA", "Baritone DGBE", "Low G"];
            case 3: return ["Standard"];
            case 4: return ["Standard"];
            case 5: return ["Standard"];
            case 6: return ["Standard"];
            case 7: return ["Open G", "Double C", "Sawmill"];
            default: return ["Any note"];
        }
    }

    function notes(g as Number, t as Number) as Array<Number> {
        switch (g) {
            case 0:
                switch (t) {
                    case 0: return [40, 45, 50, 55, 59, 64];
                    case 1: return [38, 45, 50, 55, 59, 64];
                    case 2: return [38, 45, 50, 55, 57, 62];
                    case 3: return [38, 43, 50, 55, 59, 62];
                    case 4: return [38, 45, 50, 54, 57, 62];
                    case 5: return [39, 44, 49, 54, 58, 63];
                    default: return [38, 43, 48, 53, 57, 62];
                }
            case 1:
                switch (t) {
                    case 0: return [28, 33, 38, 43];
                    case 1: return [26, 33, 38, 43];
                    case 2: return [23, 28, 33, 38, 43];
                    default: return [27, 32, 37, 42];
                }
            case 2:
                switch (t) {
                    case 0: return [67, 60, 64, 69];
                    case 1: return [50, 55, 59, 64];
                    default: return [55, 60, 64, 69];
                }
            case 3: return [55, 62, 69, 76];
            case 4: return [48, 55, 62, 69];
            case 5: return [36, 43, 50, 57];
            case 6: return [55, 62, 69, 76];
            case 7:
                switch (t) {
                    case 0: return [67, 50, 55, 59, 62];
                    case 1: return [67, 48, 55, 60, 62];
                    default: return [67, 50, 55, 60, 62];
                }
            default: return [69];
        }
    }
}
