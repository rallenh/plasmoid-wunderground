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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Dialogs as Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQControls

// Text settings for the full view: one font family, sizes per kind of text, and the text colour.
KCM.SimpleKCM {
    id: textPage

    property string cfg_fontFamily
    property alias cfg_tempPointSize: tempPointSize.value
    property alias cfg_propHeadPointSize: propHeadPointSize.value
    property alias cfg_propPointSize: propPointSize.value
    property alias cfg_secondaryPointSize: secondaryPointSize.value
    property alias cfg_chartPointSize: chartPointSize.value
    property alias cfg_boldHeadings: boldHeadings.checked
    property int cfg_textColorMode
    property string cfg_customPrimaryColor
    property string cfg_customSecondaryColor
    property int cfg_autoContrastStyle
    property string cfg_autoContrastColor

    Kirigami.FormLayout {

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Font")
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Font family:")
            spacing: Kirigami.Units.smallSpacing

            QQC.Label {
                text: cfg_fontFamily === "" ? i18n("System font (%1)", Kirigami.Theme.defaultFont.family) : cfg_fontFamily
                font.family: cfg_fontFamily === "" ? Kirigami.Theme.defaultFont.family : cfg_fontFamily
            }
            QQC.Button {
                text: i18n("Choose…")
                icon.name: "preferences-desktop-font"
                onClicked: {
                    fontDialogLoader.active = true;
                    fontDialogLoader.item.open();
                }
            }
            QQC.Button {
                text: i18n("System font")
                enabled: cfg_fontFamily !== ""
                onClicked: cfg_fontFamily = ""
            }
        }

        QQC.CheckBox {
            id: boldHeadings
            Kirigami.FormData.label: i18n("Headings:")
            text: i18n("Bold")
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Sizes (points)")
            Kirigami.FormData.isSection: true
        }

        QQC.SpinBox {
            id: tempPointSize
            Kirigami.FormData.label: i18n("Temperature:")
            from: 6
            to: 120
            editable: true
        }

        QQC.SpinBox {
            id: propHeadPointSize
            Kirigami.FormData.label: i18n("Headings:")
            from: 6
            to: 72
            editable: true
        }

        QQC.SpinBox {
            id: propPointSize
            Kirigami.FormData.label: i18n("Values:")
            from: 6
            to: 72
            editable: true
        }

        QQC.SpinBox {
            id: secondaryPointSize
            Kirigami.FormData.label: i18n("Bottom row:")
            from: 0
            to: 72
            editable: true
            textFromValue: function (value) { return value === 0 ? i18n("Default") : value.toString(); }
            valueFromText: function (text) { return text === i18n("Default") ? 0 : parseInt(text); }
        }

        QQC.SpinBox {
            id: chartPointSize
            Kirigami.FormData.label: i18n("Chart labels:")
            from: 0
            to: 72
            editable: true
            textFromValue: function (value) { return value === 0 ? i18n("Default") : value.toString(); }
            valueFromText: function (text) { return text === i18n("Default") ? 0 : parseInt(text); }
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Colour")
            Kirigami.FormData.isSection: true
        }

        QQC.ButtonGroup { id: colorModeGroup }

        QQC.RadioButton {
            Kirigami.FormData.label: i18n("Text colour:")
            text: i18n("Automatic: best contrast with the wallpaper")
            checked: cfg_textColorMode === 2
            QQC.ButtonGroup.group: colorModeGroup
            onToggled: if (checked) cfg_textColorMode = 2
        }

        RowLayout {
            enabled: cfg_textColorMode === 2
            Layout.leftMargin: Kirigami.Units.gridUnit
            spacing: Kirigami.Units.largeSpacing

            QQC.RadioButton {
                text: i18n("White or black")
                checked: cfg_autoContrastStyle === 0
                onToggled: if (checked) cfg_autoContrastStyle = 0
            }
            QQC.RadioButton {
                text: i18n("Tinted from the wallpaper")
                checked: cfg_autoContrastStyle === 1
                onToggled: if (checked) cfg_autoContrastStyle = 1
            }
        }

        QQC.Label {
            visible: cfg_textColorMode === 2 && cfg_autoContrastColor !== ""
            Layout.leftMargin: Kirigami.Units.gridUnit
            text: i18n("Current automatic colour: %1", cfg_autoContrastColor)
            opacity: 0.75
        }

        QQC.RadioButton {
            text: i18n("Custom")
            checked: cfg_textColorMode === 1
            QQC.ButtonGroup.group: colorModeGroup
            onToggled: if (checked) cfg_textColorMode = 1
        }

        GridLayout {
            enabled: cfg_textColorMode === 1
            Layout.leftMargin: Kirigami.Units.gridUnit
            columns: 3

            QQC.Label { text: i18n("Main text:") }
            KQControls.ColorButton {
                color: cfg_customPrimaryColor
                showAlphaChannel: false
                dialogTitle: i18n("Main text colour")
                onAccepted: function (colour) { cfg_customPrimaryColor = colour.toString(); }
            }
            Item { Layout.fillWidth: true }

            QQC.Label { text: i18n("Bottom row:") }
            KQControls.ColorButton {
                color: cfg_customSecondaryColor !== "" ? cfg_customSecondaryColor : cfg_customPrimaryColor
                showAlphaChannel: true
                dialogTitle: i18n("Bottom row colour")
                onAccepted: function (colour) { cfg_customSecondaryColor = colour.toString(); }
            }
            QQC.Button {
                text: i18n("Main colour at 75 %")
                enabled: cfg_customSecondaryColor !== ""
                onClicked: cfg_customSecondaryColor = ""
            }
        }

        QQC.RadioButton {
            text: i18n("Plasma theme colours")
            checked: cfg_textColorMode === 0
            QQC.ButtonGroup.group: colorModeGroup
            onToggled: if (checked) cfg_textColorMode = 0
        }
    }

    Loader {
        id: fontDialogLoader
        active: false
        sourceComponent: Component {
            Dialogs.FontDialog {
                title: i18n("Choose a Font")
                currentFont.family: cfg_fontFamily === "" ? Kirigami.Theme.defaultFont.family : cfg_fontFamily
                onAccepted: cfg_fontFamily = selectedFont.family
            }
        }
    }
}
