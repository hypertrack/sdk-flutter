import '../sdk_methods.dart';
import '../sdk_wrapper.dart';

class HypertrackWrapperIos extends HypertrackSdkWrapper {

  @override
  Future<void> addGeotag(data, expectedLocation) async {
    await invokeSdkMethod(SdkMethod.addGeotag, data);
  }

}
