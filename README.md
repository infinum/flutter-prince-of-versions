# Flutter Prince of Versions

<p align="center">
    <img src="https://raw.githubusercontent.com/infinum/flutter-prince-of-versions/master/prince-of-versions.png" width="300" max-width="50%" alt="PoV"/>
</p>


Library checks for updates using configuration from some resource.

It uses:
 - [Prince of Versions on iOS](https://github.com/infinum/iOS-prince-of-versions)
 - [Prince of Versions on Android](https://github.com/infinum/Android-Prince-of-Versions)
 - [Queen of Versions on Android](https://github.com/infinum/Android-Prince-of-Versions/tree/master/queen-of-versions)

 ## Table of contents

* [Usage](#usage)
* [JSON file formatting](#json-file-formatting)
* [Contributing](#contributing)
* [License](#license)
* [Credits](#credits)

## Usage

Use this library when you want to check if the new version of your application is available and do something with that
information (prompt user to update the application).

### Getting all the remote data

```dart
final data = await FlutterPrinceOfVersions.checkForUpdates(
  url: url,
  shouldPinCertificates: false,
  requestOptions: {
    'region': (String region) {
      return region == 'hr';
    }
  },
);
print('Update status: ${data.status.toString()}');
print('Current version: ${data.version.major}');
print('Last available major version: ${data.updateInfo.lastVersionAvailable.major}');
```

With fetching all the remote data, you have the flexiblity of creating a custom flow regarding the updates.
For example you can always update the app when a new minor version is available.

### Automatic check with data from the App Store

If you don't want to manage the JSON configuration file required by above mentioned methods, you can use `checkForUpdatesFromAppStore`.
This method will automatically get your app BundleID and it will return version info fetched from the App Store.

However, `updateStatus` result can only assume values `UpdateStatus.noUpdateAvailable` and `UpdateStatus.newUpdateAvailable`.
It is not possible to check if update is mandatory by using this method and data provided by the App Store.

### Automatic check with data from Google Play

For checking updates on Google Play use `checkForUpdatesFromGooglePlay`. This method will automatically check Google Play
and prompt user about a new version. Whenever a status of the update is changed, your callback methods will be triggered.

```dart
final Callback callback = MyCallback(context);
await FlutterPrinceOfVersions.checkForUpdatesFromGooglePlay('Google Play url', callback);
```

```dart
class MyCallback extends Callback {
  MyCallback(BuildContext context) {
    _context = context;
  }
  BuildContext _context;

  @override
  void error(String localizedMessage) {
    showDialog<bool>(
      context: _context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('An error occurred'),
          content: Text('$localizedMessage'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Ok'),
              isDestructiveAction: false,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }
}
```

In this example, we created a class and implemented an error method. When `checkForUpdatesFromGooglePlay` triggers an error method, an alert dialog will show.

### R8 / ProGuard

If you are using R8 or ProGuard add the options from
[this file](https://github.com/infinum/Android-Prince-of-Versions/blob/master/prince-of-versions/prince-of-versions.pro).

## JSON file formatting

For JSON file details and formatting, read [JSON specification](https://github.com/infinum/iOS-prince-of-versions/blob/master/JSON.md).

### iOS example

```
{
   "ios":{
      "minimum_version":"1.2.3",
      "minimum_version_min_sdk":"8.0.0",
      "latest_version":{
         "version":"2.4.5",
         "notification_type":"ALWAYS",
         "min_sdk":"12.1.2"
      }
   },
   "ios2":[
      {
         "required_version":"1.2.3",
         "last_version_available":"1.9.0",
         "notify_last_version_frequency":"ALWAYS",
         "requirements":{
            "required_os_version":"8.0.0",
            "region":"hr",
            "bluetooth":"5.0"
         },
         "meta":{
            "key1":"value1",
            "key2":2
         }
      },
      {
         "required_version":"1.2.3",
         "last_version_available":"2.4.5",
         "notify_last_version_frequency":"ALWAYS",
         "requirements":{
            "required_os_version":"12.1.2"
         },
         "meta":{
            "key3":"value3",
         }
      }
   ],
   "meta":{
      "key3":true,
      "key4":"value2"
   }
}
```


### Android example

```
{
	"android": [{
		"required_version": 10,
		"last_version_available":12,
		"notify_last_version_frequency":"ONCE",
		"requirements":{
		   "required_os_version":18
		},
		"meta":{
		   "key1":"value3"
		}
	},{
		"required_version": 10,
		"last_version_available":13,
		"notify_last_version_frequency":"ONCE",
		"requirements":{
		   "required_os_version":19
		},
		"meta":{
		   "key2":"value4"
		}
	}],
	"meta": {
		"key1": "value1",
		"key2": "value2"
	}
}
```

## Contributing

We believe that the community can help us improve and build better a product.
Please refer to our [contributing guide](CONTRIBUTING.md) to learn about the types of contributions we accept and the process for submitting them.

To ensure that our community remains respectful and professional, we defined a [code of conduct](CODE_OF_CONDUCT.md) <!-- and [coding standards](<link>) --> that we expect all contributors to follow.

We appreciate your interest and look forward to your contributions.

## License

```text
Copyright 2024 Infinum

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Credits

Maintained and sponsored by [Infinum](https://infinum.com).

<div align="center">
    <a href='https://infinum.com'>
    <picture>
        <source srcset="https://assets.infinum.com/brand/logo/static/white.svg" media="(prefers-color-scheme: dark)">
        <img src="https://assets.infinum.com/brand/logo/static/default.svg">
    </picture>
    </a>
</div>
