part of flutter_prince_of_versions;

abstract class Callback {
  void canceled() {}
  void mandatoryUpdateNotAvailable(
      QueenOfVersionsUpdateData queenData, UpdateInfo updateInfo) {}
  void downloaded(QueenOfVersionsUpdateData queenData) {}
  void downloading(QueenOfVersionsUpdateData queenData) {}
  void error(String localizedMessage) {}
  void installed(QueenOfVersionsUpdateData queenData) {}
  void installing(QueenOfVersionsUpdateData queenData) {}
  void updateAccepted(QueenOfVersionsUpdateData queenData, UpdateStatus status,
      UpdateData? updateData) {}
  void updateDeclined(QueenOfVersionsUpdateData queenData, UpdateStatus status,
      UpdateData? updateData) {}
  void noUpdate(UpdateInfo? updateInfo) {}
  void onPending(QueenOfVersionsUpdateData queenData) {}
}
