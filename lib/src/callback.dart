part of flutter_prince_of_versions;

abstract class Callback {
  void canceled();
  void mandatoryUpdateNotAvailable();
  void downloaded();
  void downloading();
  void error();
  void installed();
  void installing();
  void updateAccepted();
  void updateDeclined();
  void noUpdate();
  void onPending();
}
