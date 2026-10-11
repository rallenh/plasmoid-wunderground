/*
 * Copyright 2026  Allen Hewes
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */

/*
 * Small key/value cache on top of QML LocalStorage (SQLite under
 * ~/.local/share/plasmashell/QML/OfflineStorage/Databases/). Every value is
 * stored as JSON together with the time it was saved, so callers can decide
 * whether it is still fresh enough.
 */

.pragma library
.import QtQuick.LocalStorage as Sql

var _db = null;

function db() {
    if (_db === null) {
        _db = Sql.LocalStorage.openDatabaseSync("WundergroundPlasmoidCache", "1.0",
                                                "Wunderground widget cache", 2000000);
        _db.transaction(function (tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS cache(key TEXT PRIMARY KEY, saved INTEGER, json TEXT)");
        });
    }
    return _db;
}

/** Store a JSON-serializable value under key. Returns true on success. */
function save(key, value) {
    try {
        var json = JSON.stringify(value);
        db().transaction(function (tx) {
            tx.executeSql("INSERT OR REPLACE INTO cache(key, saved, json) VALUES(?, ?, ?)", [key, Date.now(), json]);
        });
        return true;
    } catch (e) {
        console.warn("[cache.js] save failed for " + key + ": " + e);
        return false;
    }
}

/**
 * Load the value stored under key.
 * Returns { saved: <ms since epoch>, value: <parsed JSON> } or null if missing, older than
 * maxAgeMs (when given), or unreadable.
 */
function load(key, maxAgeMs) {
    try {
        var row = null;
        db().readTransaction(function (tx) {
            var rs = tx.executeSql("SELECT saved, json FROM cache WHERE key = ?", [key]);
            if (rs.rows.length > 0)
                row = rs.rows.item(0);
        });
        if (row === null)
            return null;
        if (maxAgeMs !== undefined && maxAgeMs > 0 && Date.now() - row.saved > maxAgeMs)
            return null;
        return { saved: row.saved, value: JSON.parse(row.json) };
    } catch (e) {
        console.warn("[cache.js] load failed for " + key + ": " + e);
        return null;
    }
}

function remove(key) {
    try {
        db().transaction(function (tx) {
            tx.executeSql("DELETE FROM cache WHERE key = ?", [key]);
        });
    } catch (e) {
        console.warn("[cache.js] remove failed for " + key + ": " + e);
    }
}
