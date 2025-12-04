

part of 'user_vehicle_model.dart';





class UserVehicleAdapter extends TypeAdapter<UserVehicle> {
  @override
  final int typeId = 0;

  @override
  UserVehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserVehicle(
      id: fields[0] as String,
      brand: fields[1] as String,
      model: fields[2] as String,
      year: fields[3] as int,
      avgConsumption: fields[4] as double,
      fuelType: fields[5] as int,
      nickname: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserVehicle obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.brand)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.avgConsumption)
      ..writeByte(5)
      ..write(obj.fuelType)
      ..writeByte(6)
      ..write(obj.nickname);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserVehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
