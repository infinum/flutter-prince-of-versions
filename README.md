# Flutter Prince of Versions

Library checks for updates using configuration from some resource.

It uses:
 - Prince of Versions on iOS (https://github.com/infinum/iOS-prince-of-versions)
 - Prince of Versions on Android (https://github.com/infinum/Android-Prince-of-Versions)
 - Queen of Versions on Android (https://github.com/infinum/Android-Prince-of-Versions/tree/master/queen-of-versions)

## Usage

Use this library when you want to check if the new version of your application is available and do something with that
information (prompt user to update the application).

### Check if an update is available

```dart
 if (!await FlutterPrinceOfVersions.isUpdateAvailable('https://pastebin.com/raw/0MfYmWGu')) {
    return;
 }
 showAlert("New available", "A new update for your app is available.");
```

### Check for mandatory update
```dart
 if (!await FlutterPrinceOfVersions.isMandatoryUpdateAvailable(url)) {
    return;
 }
 showAlert("Mandatory update available", "A mandatory update for your app is available.");
```

### Getting all the remote data

```dart
 final data = await FlutterPrinceOfVersions.checkForUpdates(url);
 print('Update status: ${data.status.toString()}');
 print('Current version: ${data.version.major}');
 print('Last available major version: ${data.updateInfo.lastVersionAvailable.major}');
```

With fetching all the remote data, you have the flexiblity of creating a custom flow regarding the updates.
For example you can always update the app when a new minor version is available.

### Automatic check with data from the App Store

If you don't want to manage the JSON configuration file required by above mentioned methods, you can use `checkForUpdatesFromStore`.
This method will automatically get your app BundleID and it will return version info fetched from the App Store.

However, `updateStatus` result can only assume values `UpdateStatus.noUpdateAvailable` and `UpdateStatus.newUpdateAvailable`.
It is not possible to check if update is mandatory by using this method and data provided by the AppStore.

### Automatic check with data from Google Play

For checking updates on Google Play use `checkForUpdatesFromGooglePlay`. This method will automatically check Play Store
and prompt user about a new version.
TODO: Explaing more, come back when implemented and tested.

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

Feedback and code contributions are very much welcome. Just make a pull request with a short description of your changes.

## Credits

Maintained and sponsored by [Infinum](http://www.infinum.com).
<a href='https://infinum.com'>
  <img src='https://infinum.com/infinum.png' href='https://infinum.com' width='264'>
</a>
