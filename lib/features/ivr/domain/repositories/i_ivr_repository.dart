import '../entities/ivr_entity.dart';

abstract class IIvrRepository {
  Future<IvrEntity> requestCall({required String toNumber});
}
