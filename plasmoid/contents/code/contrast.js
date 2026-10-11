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
 * Text colour with the highest contrast against a background colour, using the WCAG relative-luminance
 * contrast ratio (1:1 = none, 21:1 = black on white; 7:1 is the "enhanced" readability level).
 * Colours are passed as {r, g, b} with components 0..1 (what QML color values provide).
 */

.pragma library

var WHITE = { r: 1, g: 1, b: 1 };
var NEAR_BLACK = { r: 20 / 255, g: 20 / 255, b: 20 / 255 };

function channel(c) {
    return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}

function luminance(c) {
    return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

function ratio(a, b) {
    var la = luminance(a), lb = luminance(b);
    return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
}

function toHex(c) {
    function h(v) { return ("0" + Math.round(Math.max(0, Math.min(1, v)) * 255).toString(16)).slice(-2); }
    return "#" + h(c.r) + h(c.g) + h(c.b);
}

function hslToRgb(h, s, l) {
    function hue(p, q, t) {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1 / 6) return p + (q - p) * 6 * t;
        if (t < 1 / 2) return q;
        if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
        return p;
    }
    if (s === 0)
        return { r: l, g: l, b: l };
    var q = l < 0.5 ? l * (1 + s) : l + s - l * s, p = 2 * l - q;
    return { r: hue(p, q, h + 1 / 3), g: hue(p, q, h), b: hue(p, q, h - 1 / 3) };
}

function rgbToHsl(c) {
    var max = Math.max(c.r, c.g, c.b), min = Math.min(c.r, c.g, c.b), l = (max + min) / 2, h = 0, s = 0;
    if (max !== min) {
        var d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        if (max === c.r) h = (c.g - c.b) / d + (c.g < c.b ? 6 : 0);
        else if (max === c.g) h = (c.b - c.r) / d + 2;
        else h = (c.r - c.g) / d + 4;
        h /= 6;
    }
    return { h: h, s: s, l: l };
}

/**
 * White or near-black, whichever contrasts more with background.
 */
function blackOrWhite(background) {
    return ratio(WHITE, background) >= ratio(NEAR_BLACK, background) ? WHITE : NEAR_BLACK;
}

/**
 * A colour with the hue of tintSource (e.g. the wallpaper's most saturated colour), moved towards dark or
 * light (the same direction blackOrWhite picks) until it reaches minRatio (default 7) against background.
 * Falls back to blackOrWhite when no tint reaches it.
 */
function tinted(background, tintSource, minRatio) {
    var target = minRatio || 7;
    var dark = blackOrWhite(background) === NEAR_BLACK;
    var hsl = rgbToHsl(tintSource);
    var s = Math.min(hsl.s, 0.6);
    for (var i = 0; i <= 100; i++) {
        var l = dark ? 0.5 * (1 - i / 100) : 0.5 + 0.5 * i / 100;
        var cand = hslToRgb(hsl.h, s, l);
        if (ratio(cand, background) >= target)
            return cand;
    }
    return blackOrWhite(background);
}
