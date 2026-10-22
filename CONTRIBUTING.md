# Contributing

Thanks for helping! This file is for people working on the package itself; the
README is for the people who use it.

## Code layout

The code is in `lib/src`, grouped by feature:

| Folder | Content |
|--------|---------|
| `core/` | Models (`AwesomeDate`, `AwesomeTime`, `AwesomeDateTime`, `AwesomeDateRange`), formats, locales, utils and validation |
| `shared/` | The wheel widget, `ItemTheme`, `AwesomeWheelStyle`, `AwesomePickerThemeData`, `AwesomeSemanticLabels` and the helper that builds a wheel |
| `date/`, `time/`, `datetime/` | One folder per picker: the widget, its public controller, its theme and its `...PickerLogic` |
| `range/` | `AwesomeDateRangePicker` and its controller |
| `duration/` | `AwesomeDurationPicker`, its controller, its theme and `DurationPickerLogic` |
| `modal/` | `showAwesomePicker` and the `showAwesome...Picker` functions |

The `...PickerLogic` classes hold the rules (clamping, exclusions, the items of
each wheel) and have no widget code, so they are unit-tested directly. The
public `Awesome...PickerController` classes are the small, stable API.

## Everyday commands

```sh
flutter test                                       # run the tests
flutter analyze                                    # every public member needs a doc comment
dart format lib test tool example/lib example/test
flutter test tool/generate_screenshots_test.dart   # regenerate doc/images
cd example && flutter run                          # try the package (add -d chrome for the web)
```

Run the screenshot command whenever the look of a picker changes, and commit
the new images. The images of the README are generated from the real widgets
with the Roboto font bundled with Flutter.

## Checks before a release

Run these from the package folder; each should pass:

```sh
dart format --output=none --set-exit-if-changed lib test tool example/lib example/test
flutter analyze && flutter test
(cd example && flutter analyze && flutter test)
flutter pub downgrade && flutter analyze && flutter test   # the lowest dependency versions; then: flutter pub upgrade
flutter pub publish --dry-run                              # what pub.dev validates
```

## Releasing

1. Set the new `version` in `pubspec.yaml` and add a section for it to
   `CHANGELOG.md`. A published version can never be changed or reused, so even
   a fix to the README needs a new version.
2. Commit and push, then run the checks above (the dry run should report 0
   warnings on a clean tree).
3. `flutter pub publish`, then tag the release: `git tag -a vX.Y.Z -m "Release
   X.Y.Z" && git push origin vX.Y.Z`.

Two things to keep in mind, because pub.dev shows the README of the published
version and nothing else:

- The images of the README use **absolute URLs** (`https://github.com/.../blob/master/doc/images/...?raw=true`).
  pub.dev drops relative image paths written inside HTML, so they would not
  show.
- Keep the README for the people who use the package. Anything about working on
  it goes here.

## The live demo

The example app is deployed to GitHub Pages by `.github/workflows/pages.yml` on
every push to `master`. Enable it once in the repository: *Settings > Pages >
Build and deployment > Source: GitHub Actions*.
