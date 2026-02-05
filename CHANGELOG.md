# Changelog
All notable changes to this plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.7] - 2026-02-04
### Added
- Toggle terminal command and keymap.
- Focus now always enters terminal mode.

### Changed
- Terminal focus keymap moved to <leader>caf.
- Terminal toggle keymap is <leader>cat.

## [0.1.6] - 2026-02-04
### Fixed
- Avoid stale visual ranges by only using live range in Visual mode.
- Set terminal buffer name and hide it from buffer lists.

## [0.1.5] - 2026-02-04
### Added
- Prefix sent paths with "@" for cursor-agent.

## [0.1.4] - 2026-02-04
### Fixed
- Visual selection now uses live line range for all visual modes.
- Reuse existing terminal window across tabs and prevent buffer replacement.
- Exit Visual mode after send/copy from Visual mode.

## [0.1.3] - 2026-02-04
### Fixed
- Visual selection now uses live range from Visual mode mappings.
- Terminal window reuse across tabs to avoid duplicate windows.

### Added
- Esc Esc to exit terminal mode (configurable).

## [0.1.2] - 2026-02-04
### Fixed
- Visual selection now uses current range instead of stale marks.

## [0.1.1] - 2026-02-04
### Added
- Terminal window navigation with Ctrl+h/j/k/l.

### Changed
- Reuse existing terminal window instead of opening duplicates.
- Default terminal split to right side.

## [0.1.0] - 2026-02-04
### Added
- Copy path with lines from current buffer (normal/visual).
- Copy file path without line numbers.
- Send path or file path to cursor-agent terminal.
- Focus cursor-agent terminal.
- Default keymaps under `<leader>a`.

[Unreleased]: https://example.com/compare/0.1.7...HEAD
[0.1.7]: https://example.com/compare/0.1.6...0.1.7
[0.1.6]: https://example.com/compare/0.1.5...0.1.6
[0.1.5]: https://example.com/compare/0.1.4...0.1.5
[0.1.4]: https://example.com/compare/0.1.3...0.1.4
[0.1.3]: https://example.com/compare/0.1.2...0.1.3
[0.1.2]: https://example.com/compare/0.1.1...0.1.2
[0.1.1]: https://example.com/compare/0.1.0...0.1.1
[0.1.0]: https://example.com/releases/0.1.0
