> [!WARNING]
> **Beware of fake websites impersonating Maccy.** Malicious sites (such as `maccyapp.net` and `maccyapp.com`) distribute malware disguised as Maccy. [**maccy.app**](https://maccy.app) is the **only** official website.

<img width="128px" src="https://maccy.app/img/maccy/Logo.png" alt="Logo" />

# Maccy — image history fork

[![Download DMG](https://img.shields.io/badge/Download-Maccy.dmg-blue)](https://github.com/nekell3r/Maccy/releases/latest/download/Maccy.dmg)
[![Build](https://github.com/nekell3r/Maccy/actions/workflows/test.yml/badge.svg)](https://github.com/nekell3r/Maccy/actions/workflows/test.yml)

Форк [p0deje/Maccy](https://github.com/p0deje/Maccy) с улучшенной историей картинок.
**[Скачать приложение](https://github.com/nekell3r/Maccy/releases/latest/download/Maccy.dmg)** ·
[Установка по-русски](INSTALL.ru.md) · [Все версии](https://github.com/nekell3r/Maccy/releases).
macOS 14+, Apple Silicon и Intel. Сборка не нотарифицирована Apple; при первом запуске
может потребоваться «Всё равно открыть» в настройках безопасности.

Maccy is a lightweight clipboard manager for macOS. It keeps the history of what you copy
and lets you quickly navigate, search, and use previous clipboard contents.

Maccy works on macOS Sonoma 14 or higher.

This fork improves image history: PNG/TIFF images with empty text representations are retained,
image data survives pasting without text formatting, and previews can be regenerated after cache cleanup.
Text recognition runs on a dedicated serial queue so batches of images do not block Swift's async task pool.
Right-click an image in history and choose **Copy image** or **Paste image** from its context menu.
Each action targets that image even if the list selection changes while the menu is open.
Copy restores the original clipboard representations; paste also inserts them into the previously active app.
These actions follow Maccy's existing copy/paste behavior and work independently of the default action setting.
Automatic pasting requires Accessibility permission, as in upstream Maccy.

<!-- vim-markdown-toc GFM -->

* [Features](#features)
* [Install](#install)
* [Usage](#usage)
* [Advanced](#advanced)
  * [Ignore Copied Items](#ignore-copied-items)
  * [Ignore Custom Copy Types](#ignore-custom-copy-types)
  * [Speed up Clipboard Check Interval](#speed-up-clipboard-check-interval)
* [FAQ](#faq)
  * [Why doesn't it paste when I select an item in history?](#why-doesnt-it-paste-when-i-select-an-item-in-history)
  * [When assigning a hotkey to open Maccy, it says that this hotkey is already used in some system setting.](#when-assigning-a-hotkey-to-open-maccy-it-says-that-this-hotkey-is-already-used-in-some-system-setting)
  * [How to restore hidden footer?](#how-to-restore-hidden-footer)
  * [How to ignore copies from Universal Clipboard?](#how-to-ignore-copies-from-universal-clipboard)
  * [My keyboard shortcut stopped working in password fields. How do I fix this?](#my-keyboard-shortcut-stopped-working-in-password-fields-how-do-i-fix-this)
* [Translations](#translations)
* [Motivation](#motivation)
* [License](#license)

<!-- vim-markdown-toc -->

## Features

* Lightweight and fast
* Keyboard-first
* Secure and private
* Native UI
* Open source and free

## Install

Download **[Maccy.dmg](https://github.com/nekell3r/Maccy/releases/latest/download/Maccy.dmg)**,
open it, quit the old Maccy, and drag Maccy.app into Applications. The DMG includes Russian installation instructions.
This fork preserves the original bundle identifier and existing history/preferences; run one copy of Maccy at a time.
Homebrew's `maccy` formula installs upstream, so use the DMG for this fork.

Updates in Settings use this fork's release feed. Both the feed and update ZIP are verified with a separate Sparkle EdDSA key.
The private key is stored in GitHub Actions secret `SPARKLE_PRIVATE_KEY` and the owner's macOS Keychain account `nekell3r.Maccy`.

## Build and release

With full Xcode 26.3 selected (the version pinned in CI; Command Line Tools alone are insufficient):

```sh
./scripts/build-release.sh
```

This builds an optimized universal app, creates `dist/Maccy.dmg` and `dist/Maccy.app.zip`,
checks the signature, both CPU architectures and the mounted DMG, and writes `dist/SHA256SUMS`.
The app uses an ad-hoc code signature; it is not Developer ID signed or notarized.

Every push/PR runs unit tests and the full application UI suite on an isolated macOS runner.
Successful runs produce a **Maccy-release** artifact containing the Release DMG and ZIP.
To publish: increment `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the Xcode project,
update `RELEASE_NOTES.md`, push, then tag that commit (for example, `git tag v2.7.2 && git push origin v2.7.2`).
The tag workflow repeats all checks, signs the ZIP and appcast with `SPARKLE_PRIVATE_KEY`, and publishes GitHub Releases automatically.
The permanent download URL above always serves the latest published release. Paste UI tests send global input only on the disposable CI desktop.

## Usage

1. <kbd>SHIFT (⇧)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>C</kbd> to popup Maccy or click on its icon in the menu bar.
2. Type what you want to find.
3. To select the history item you wish to copy, press <kbd>ENTER</kbd>, or click the item, or use <kbd>COMMAND (⌘)</kbd> + `n` shortcut.
4. To choose the history item and paste, press <kbd>OPTION (⌥)</kbd> + <kbd>ENTER</kbd>, or <kbd>OPTION (⌥)</kbd> + <kbd>CLICK</kbd> the item, or use <kbd>OPTION (⌥)</kbd> + `n` shortcut.
5. To choose the history item and paste without formatting, press <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> + <kbd>ENTER</kbd>, or <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> + <kbd>CLICK</kbd> the item, or use <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> + `n` shortcut.
6. To delete the history item, press <kbd>OPTION (⌥)</kbd> + <kbd>DELETE (⌫)</kbd>.
7. To see the full text of the history item, wait a couple of seconds for tooltip.
8. To pin the history item so that it remains on top of the list, press <kbd>OPTION (⌥)</kbd> + <kbd>P</kbd>. The item will be moved to the top with a random but permanent keyboard shortcut. To unpin it, press <kbd>OPTION (⌥)</kbd> + <kbd>P</kbd> again.
9. To clear all unpinned items, select _Clear_ in the menu, or press <kbd>OPTION (⌥)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>DELETE (⌫)</kbd>. To clear all items including pinned, select _Clear_ in the menu with  <kbd>OPTION (⌥)</kbd> pressed, or press <kbd>SHIFT (⇧)</kbd> + <kbd>OPTION (⌥)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>DELETE (⌫)</kbd>.
10. To disable Maccy and ignore new copies, click on the menu icon with <kbd>OPTION (⌥)</kbd> pressed.
11. To ignore only the next copy, click on the menu icon with <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> pressed.
12. To customize the behavior, check "Preferences…" window, or press <kbd>COMMAND (⌘)</kbd> + <kbd>,</kbd>.

## Advanced

### Ignore Copied Items

You can tell Maccy to ignore all copied items:

```sh
defaults write org.p0deje.Maccy ignoreEvents true # default is false
```

This is useful if you have some workflow for copying sensitive data. You can set `ignoreEvents` to true, copy the data and set `ignoreEvents` back to false.

You can also click the menu icon with <kbd>OPTION (⌥)</kbd> pressed. To ignore only the next copy, click with <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> pressed.

### Ignore Custom Copy Types

By default Maccy will ignore certain copy types that are considered to be confidential
or temporary. The default list always include the following types:

* `org.nspasteboard.TransientType`
* `org.nspasteboard.ConcealedType`
* `org.nspasteboard.AutoGeneratedType`

Also, default configuration includes the following types but they can be removed
or overwritten:

* `com.agilebits.onepassword`
* `com.typeit4me.clipping`
* `de.petermaurer.TransientPasteboardType`
* `Pasteboard generator type`
* `net.antelle.keeweb`

You can add additional custom types using settings.
To find what custom types are used by an application, you can use
free application [Pasteboard-Viewer](https://github.com/sindresorhus/Pasteboard-Viewer).
Simply download the application, open it, copy something from the application you
want to ignore and look for any custom types in the left sidebar. [Here is an example
of using this approach to ignore Adobe InDesign](https://github.com/p0deje/Maccy/issues/125).

### Speed up Clipboard Check Interval

By default, Maccy checks clipboard every 500 ms, which should be enough for most users. If you want
to speed it up, you can change it with `defaults`:

```sh
defaults write org.p0deje.Maccy clipboardCheckInterval 0.1 # 100 ms
```

## FAQ

### Why doesn't it paste when I select an item in history?

1. Make sure you have "Paste automatically" enabled in Preferences.
2. Make sure "Maccy" is added to System Settings -> Privacy & Security -> Accessibility.

### When assigning a hotkey to open Maccy, it says that this hotkey is already used in some system setting.

1. Open System settings -> Keyboard -> Keyboard Shortcuts.
2. Find where that hotkey is used. For example, "Convert text to simplified Chinese" is under Services -> Text.
3. Disable that hotkey or remove assigned combination ([screenshot](https://github.com/p0deje/Maccy/assets/576152/446719e6-c3e5-4eb0-95fb-5a811066487f)).
4. Restart Maccy.
5. Assign hotkey in Maccy settings.

### How to restore hidden footer?

1. Open Maccy window.
2. Press <kbd>COMMAND (⌘)</kbd> + <kbd>,</kbd> to open preferences.
3. Enable footer in Appearance section.

If for some reason it doesn't work, run the following command in Terminal.app:

```sh
defaults write org.p0deje.Maccy showFooter 1
```

### How to ignore copies from [Universal Clipboard](https://support.apple.com/en-us/102430)?

1. Open Preferences -> Ignore -> Pasteboard Types.
2. Add `com.apple.is-remote-clipboard`.

### My keyboard shortcut stopped working in password fields. How do I fix this?

If your shortcut produces a character (like `Option+C` → "ç"), macOS security may block it in password fields. Use [Karabiner-Elements](https://karabiner-elements.pqrs.org/) to remap your shortcut to a different combination like `Cmd+Shift+C`. [See detailed solution](docs/keyboard-shortcut-password-fields.md).

## Translations

The translations are hosted in [Weblate](https://hosted.weblate.org/engage/maccy/).
You can use it to suggest changes in translations and localize the application to a new language.

[![Translation status](https://hosted.weblate.org/widget/maccy/multi-auto.svg)](https://hosted.weblate.org/engage/maccy/)

## Motivation

There are dozens of similar applications out there, so why build another?
Over the past years since I moved from Linux to macOS, I struggled to find
a clipboard manager that is as free and simple as [Parcellite](http://parcellite.sourceforge.net),
but I couldn't. So I've decided to build one.

Also, I wanted to learn Swift and get acquainted with macOS application development.

## License

[MIT](./LICENSE)
