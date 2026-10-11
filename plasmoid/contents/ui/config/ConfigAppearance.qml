/*
 * Copyright 2026  Kevin Donnelly
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
import org.kde.plasma.components as PlasmaComponents
import org.kde.kcmutils as KCM
import "../lib" as Lib

KCM.SimpleKCM {

    id: appearancePage

    property alias cfg_inTrayActiveTimeoutSec: inTrayActiveTimeoutSec.value
    property string cfg_widgetFontName: plasmoid.configuration.widgetFontName
    property string cfg_widgetFontSize: plasmoid.configuration.widgetFontSize
    property string cfg_widgetIconSize: plasmoid.configuration.widgetIconSize

    property alias cfg_useSystemThemeIcons: useSystemThemeIcons.checked
    property alias cfg_textVisible: textVisible.checked
    property alias cfg_iconVisible: iconVisible.checked
    property alias cfg_textDropShadow: textDropShadow.checked
    property alias cfg_iconDropShadow: iconDropShadow.checked

    property int cfg_iconSizeMode
    property int cfg_textSizeMode
    property int cfg_shownInTooltip

    property alias cfg_tempAutoColor: tempAutoColor.checked
    property alias cfg_showTimeSeconds: showTimeSeconds.checked
    property alias cfg_useDefaultPage: useDefaultPage.checked
    property alias cfg_showBlurb: showBlurb.checked
    property alias cfg_defaultLoadPage: defaultLoadPage.currentIndex
    property alias cfg_showPresTrend: showPresTrend.checked


    QQC.ButtonGroup {
        id: iconSizeModeGroup

        Component.onCompleted: {
            cfg_iconSizeModeChanged()
        }
    }

    onCfg_iconSizeModeChanged: {
        switch (cfg_iconSizeMode) {
            case 0:
                iconSizeModeGroup.checkedButton = iconSizeModeFit;
                break;
            case 1:
                iconSizeModeGroup.checkedButton = iconSizeModeFixed;
                break;
            default:
        }
    }

    QQC.ButtonGroup {
        id: textSizeModeGroup

        Component.onCompleted: {
            cfg_textSizeModeChanged()
        }
    }

    onCfg_textSizeModeChanged: {
        switch (cfg_textSizeMode) {
            case 0:
                textSizeModeGroup.checkedButton = textSizeModeFit;
                break;
            case 1:
                textSizeModeGroup.checkedButton = textSizeModeFixed;
                break;
            default:
        }
    }

    QQC.ButtonGroup {
        id: shownInTooltipGroup

        Component.onCompleted: {
            cfg_shownInTooltipChanged()
        }
    }

    onCfg_shownInTooltipChanged: {
        switch (cfg_shownInTooltip) {
            case 0:
                shownInTooltipGroup.checkedButton = showIDInTooltip;
                break;
            case 1:
                shownInTooltipGroup.checkedButton = showNameInTooltip;
                break;
            case 2:
                shownInTooltipGroup.checkedButton = showBothInTooltip;
                break;
            default:
        }
    }

    Kirigami.FormLayout {
        anchors.fill: parent

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("General")
            Kirigami.FormData.isSection: true
        }

        Lib.BackgroundToggle {}

        QQC.CheckBox {
            id: useSystemThemeIcons

            Kirigami.FormData.label: i18n("Use system theme icons:")
        }

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Kirigami.FormData.label: i18n("Shown in tooltip:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop

            QQC.RadioButton {
                id: showIDInTooltip
                QQC.ButtonGroup.group: shownInTooltipGroup
                text: i18n("Station ID")
                onCheckedChanged: if (checked) cfg_shownInTooltip = 0;
            }

            QQC.RadioButton {
                id: showNameInTooltip
                QQC.ButtonGroup.group: shownInTooltipGroup
                text: i18n("Station Name")
                onCheckedChanged: if (checked) cfg_shownInTooltip = 1;
            }

            QQC.RadioButton {
                id: showBothInTooltip
                QQC.ButtonGroup.group: shownInTooltipGroup
                text: i18n("Both")
                onCheckedChanged: if (checked) cfg_shownInTooltip = 2;
            }
        }
        
        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Full Representation")
            Kirigami.FormData.isSection: true
        }


        QQC.CheckBox {
            id: tempAutoColor

            Kirigami.FormData.label: i18n("Auto-color temperature:")
        }

        QQC.CheckBox {
            id: showTimeSeconds

            Kirigami.FormData.label: i18n("Show time seconds:")
        }

        QQC.CheckBox {
            id: showBlurb

            Kirigami.FormData.label: i18n("Show blurb:")
        }

        QQC.CheckBox {
            id: useDefaultPage

            Kirigami.FormData.label: i18n("Use default page:")
        }

        QQC.ComboBox {
            id: defaultLoadPage

            enabled: useDefaultPage.checked

            model: [i18n("Weather Details"), i18n("Forecast"), i18n("Day Chart"), i18n("More Info")]

            Kirigami.FormData.label: i18n("Default page shown:")
        }
        QQC.CheckBox {
            id: showPresTrend

            Kirigami.FormData.label: i18n("Show pressure trend:")
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Compact Representation")
            Kirigami.FormData.isSection: true
        }

        // A font dialog instead of a ComboBox listing every installed font: the ComboBox built one menu item per
        // font family (1000+) every time this page was opened, which froze the settings window for ~1.5 s.
        RowLayout {
            Kirigami.FormData.label: i18n("Choose a Font:")
            spacing: Kirigami.Units.smallSpacing

            QQC.Label {
                text: cfg_widgetFontName === "" ? i18nc("Use default font", "Default") : cfg_widgetFontName
                font.family: cfg_widgetFontName === "" ? Kirigami.Theme.defaultFont.family : cfg_widgetFontName
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
                text: i18nc("Use default font", "Default")
                enabled: cfg_widgetFontName !== ""
                onClicked: cfg_widgetFontName = ""
            }
        }

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Kirigami.FormData.label: i18n("Text size mode:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop

            QQC.RadioButton {
                id: textSizeModeFit
                QQC.ButtonGroup.group: textSizeModeGroup
                text: i18n("Automatic fit")
                onCheckedChanged: if (checked) cfg_textSizeMode = 0;
            }

            QQC.RadioButton {
                id: textSizeModeFixed
                QQC.ButtonGroup.group: textSizeModeGroup
                text: i18n("Exact size")
                onCheckedChanged: if (checked) cfg_textSizeMode = 1;
            }
        }

        Row {
            Kirigami.FormData.label: i18n("Text size") + ":"

            QQC.SpinBox {
                id: widgetFontSize
                stepSize: 1
                from: 4
                value: cfg_widgetFontSize
                to: 512
                onValueChanged: {
                    cfg_widgetFontSize = widgetFontSize.value
                }
            }
            PlasmaComponents.Label {
                text: i18nc("pixels", "px")
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        QQC.CheckBox {
            id: textVisible
            
            Kirigami.FormData.label: i18n("Text visible") + ":"
        }

        QQC.CheckBox {
            id: textDropShadow

            Kirigami.FormData.label: i18n("Text drop shadow") + ":"
        }

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Kirigami.FormData.label: i18n("Icon size mode:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop

            QQC.RadioButton {
                id: iconSizeModeFit
                QQC.ButtonGroup.group: iconSizeModeGroup
                text: i18n("Automatic fit")
                onCheckedChanged: if (checked) cfg_iconSizeMode = 0;
            }

            QQC.RadioButton {
                id: iconSizeModeFixed
                QQC.ButtonGroup.group: iconSizeModeGroup
                text: i18n("Exact size")
                onCheckedChanged: if (checked) cfg_iconSizeMode = 1;
            }
        }

        Row {
            Kirigami.FormData.label: i18n("Icon size") + ":"

            QQC.SpinBox {
                id: widgetIconSize
                stepSize: 1
                from: 4
                value: cfg_widgetIconSize
                to: 512
                onValueChanged: {
                    cfg_widgetIconSize = widgetIconSize.value
                }
            }
            PlasmaComponents.Label {
                text: i18nc("pixels", "px")
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        QQC.CheckBox {
            id: iconVisible

            Kirigami.FormData.label: i18n("Icon visible") + ":"
        }
        QQC.CheckBox {
            id: iconDropShadow

            Kirigami.FormData.label: i18n("Icon drop shadow") + ":"
        }

        Row {
            Kirigami.FormData.label: i18n("System tray active timeout") + ":"

            QQC.SpinBox {
                id: inTrayActiveTimeoutSec
                stepSize: 10
                from: 10
                to: 8000
                anchors.verticalCenter: parent.verticalCenter
            }
            PlasmaComponents.Label {
                text: i18nc("Abbreviation for seconds", "sec")
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Loader {
        id: fontDialogLoader
        active: false
        sourceComponent: Component {
            Dialogs.FontDialog {
                title: i18n("Choose a Font")
                currentFont.family: cfg_widgetFontName === "" ? Kirigami.Theme.defaultFont.family : cfg_widgetFontName
                onAccepted: cfg_widgetFontName = selectedFont.family
            }
        }
    }
}
