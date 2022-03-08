# loplat_plengi

loplat plengi(Place Engine) SDK plugin project.

## Supported platforms

* Flutter Android
* Flutter iOS

## Installation

Add `loplat_plengi: ^1.0.0` to your `pubspec.yaml` dependencies. And import it:

```dart
import 'package:loplat_plengi/loplat_plengi.dart';
```

## generate template

```bash
$ flutter create --template=plugin --org com.loplat --platforms=android,ios -a java -i swift loplat_plengi
$ cd loplat_plengi
$ cd example
$ flutter pub upgrade
$ dart migrate --apply-changes
```

