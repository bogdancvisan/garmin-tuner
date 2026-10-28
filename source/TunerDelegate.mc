import Toybox.Lang;
import Toybox.WatchUi;

class TunerDelegate extends WatchUi.BehaviorDelegate {
    private var _model as TunerModel;

    function initialize(model as TunerModel) {
        BehaviorDelegate.initialize();
        _model = model;
    }

    // DOWN / swipe: next tuning of the chosen instrument.
    function onNextPage() as Boolean {
        _model.stepTuning(1);
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() as Boolean {
        _model.stepTuning(-1);
        WatchUi.requestUpdate();
        return true;
    }

    // START (upper right) / tap: instrument menu.
    function onSelect() as Boolean {
        return openMenu();
    }

    // Long-press UP / MENU: same menu.
    function onMenu() as Boolean {
        return openMenu();
    }

    private function openMenu() as Boolean {
        _model.pause();
        var menu = new WatchUi.Menu2({ :title => "Instrument" });
        var names = Instruments.groupNames();
        for (var i = 0; i < names.size(); i++) {
            menu.addItem(new WatchUi.MenuItem(names[i], i == _model.group ? "Selected" : null, i, {}));
        }
        menu.addItem(new WatchUi.MenuItem("Vibrate in tune", _model.haptic ? "On" : "Off", :vibe, {}));
        WatchUi.pushView(menu, new MainMenuDelegate(_model), WatchUi.SLIDE_UP);
        return true;
    }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _model as TunerModel;

    function initialize(model as TunerModel) {
        Menu2InputDelegate.initialize();
        _model = model;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :vibe) {
            _model.haptic = !_model.haptic;
        } else {
            _model.setGroup(id as Number);
        }
        _model.resume();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onBack() as Void {
        _model.resume();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
