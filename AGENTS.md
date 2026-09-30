# Agent guidance for mikey-mouse

This repo contains a macOS Swift/AppKit menu-bar replacement for Mac Mouse Fix.
Side buttons become back/forward navigation swipes in apps that ignore buttons
4 and 5, and the notched wheel scrolls smoothly. All source and scripts live in
this repo; `install.sh` links its launcher into `~/.local/bin`.

## Key rules

- Use test-first development for non-trivial changes. Write or update the
  automated test first, then implement the change until the test passes. If the
  current code has no clean test seam, extract one first and then add the test.
- When behaviour changes, rerun the relevant tests. If your change affects
  expectations, UI copy, layout, persistence, startup behaviour, or any tested
  contract, update the tests and rerun them.
- Test before committing. Run the automated tests and verify the actual tool.
  Check exit codes. For installer changes, run `bash Tests/install-tests.sh`.
- Keep build output and staged app bundles out of Git.
- Keep the bundle identifier `com.mikerosoft.mikey-mouse` stable. It is the
  existing settings, login-service and Accessibility identity.
- Keep shell scripts compatible with macOS Bash 3.2, including empty arrays
  under `set -u` in `build-app.sh`.
- Write plainly and conversationally, with no em dashes. Explain unusual code
  with comments. Avoid eyebrows or kickers in UI designs.
- PRs start with `## Why`, explaining what prompted the change in plain language.

## mikey-mouse specifics

### Dev workflow

```bash
swift test
bash restart.sh
tail -f ~/Library/Logs/mikey-mouse.log
```

- Always test the staged `~/Applications/Mikey Mouse.app` via `restart.sh`.
  Accessibility permission is keyed to the signed bundle.
- Verify side buttons with a real press over Finder. Each press logs the app
  under the pointer and whether it became a swipe. A swipe posted straight to
  Finder's pid with `CGEvent.postToPid` does not navigate, so it is no substitute.
- The event tap sits at the HID level on its own thread. Anything slow in the
  callback makes the whole mouse lag, and macOS turns a slow tap off.
- Only apps in `BackForwardRouter.swipeApps` get swipes. Chrome, VS Code and
  other apps that handle buttons 4 and 5 themselves must keep the raw click.
- Scroll feel (pixels per notch, time constant, acceleration) is subjective.
  Change it with Mike trying the real wheel, not from unit tests alone.
