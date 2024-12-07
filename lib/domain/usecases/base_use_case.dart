import 'package:commandy/commandy.dart';

abstract interface class BaseUseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

abstract interface class StreamUseCase<Type, Params> {
  Stream<Result<Type>> call(Params params);
}
