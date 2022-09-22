import 'package:hypertrack_plugin/src/sdk_methods.dart';

import '../sdk_wrapper.dart';

class HypertrackWrapperAndroid extends HypertrackSdkWrapper {

  @override
  Future<void> addGeotag(data, expectedLocation) async {
    await invokeSdkMethod(SdkMethod.addGeotag, data);
  }

}
