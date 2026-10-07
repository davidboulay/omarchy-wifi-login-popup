import QtQuick
import Quickshell
import Quickshell.Io

// Wi-Fi Login Popup service. Runs only while the plugin is enabled.
//
// Keeps bin/wifi-login-popup watching NetworkManager. When NM's connectivity
// check reports a captive portal, the watcher opens the sign-in page in a
// floating window. Disabling the plugin unloads this item, which stops the
// watcher; nothing is left behind.
Item {
  id: root

  // Injected by omarchy-shell.
  property var shell: null

  readonly property string pluginDir: {
    var url = String(Qt.resolvedUrl("."))
    return decodeURIComponent(url.replace(/^file:\/\//, "")).replace(/\/$/, "")
  }

  Process {
    id: watcher
    command: ["bash", root.pluginDir + "/bin/wifi-login-popup", "watch"]
    running: true
    stdout: SplitParser {
      onRead: line => console.log("wifi-login-popup: " + line)
    }
    // NetworkManager restarted or the watcher died: try again shortly.
    onExited: restart.start()
  }

  Timer {
    id: restart
    interval: 5000
    onTriggered: watcher.running = true
  }
}
