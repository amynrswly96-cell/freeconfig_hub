// GENERATED CODE - manually authored to match hive_generator output.
// اگر مدل را تغییر دادید، این فایل را با اجرای دستور زیر بازتولید کنید:
// flutter pub run build_runner build --delete-conflicting-outputs

part of 'server_model.dart';

class ServerModelAdapter extends TypeAdapter<ServerModel> {
  @override
  final int typeId = 0;

  @override
  ServerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerModel(
      id: fields[0] as String,
      name: fields[1] as String,
      countryCode: fields[2] as String,
      protocol: fields[3] as ServerProtocol,
      source: fields[4] as ServerSource,
      rawConfig: fields[5] as String,
      pingMs: fields[6] as int,
      isOnline: fields[7] as bool,
      tags: (fields[8] as List).cast<String>(),
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ServerModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.countryCode)
      ..writeByte(3)
      ..write(obj.protocol)
      ..writeByte(4)
      ..write(obj.source)
      ..writeByte(5)
      ..write(obj.rawConfig)
      ..writeByte(6)
      ..write(obj.pingMs)
      ..writeByte(7)
      ..write(obj.isOnline)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServerProtocolAdapter extends TypeAdapter<ServerProtocol> {
  @override
  final int typeId = 1;

  @override
  ServerProtocol read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ServerProtocol.vmess;
      case 1:
        return ServerProtocol.vless;
      case 2:
        return ServerProtocol.trojan;
      case 3:
        return ServerProtocol.shadowsocks;
      case 4:
        return ServerProtocol.clash;
      case 5:
      default:
        return ServerProtocol.unknown;
    }
  }

  @override
  void write(BinaryWriter writer, ServerProtocol obj) {
    switch (obj) {
      case ServerProtocol.vmess:
        writer.writeByte(0);
        break;
      case ServerProtocol.vless:
        writer.writeByte(1);
        break;
      case ServerProtocol.trojan:
        writer.writeByte(2);
        break;
      case ServerProtocol.shadowsocks:
        writer.writeByte(3);
        break;
      case ServerProtocol.clash:
        writer.writeByte(4);
        break;
      case ServerProtocol.unknown:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerProtocolAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServerSourceAdapter extends TypeAdapter<ServerSource> {
  @override
  final int typeId = 2;

  @override
  ServerSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ServerSource.official;
      case 1:
      default:
        return ServerSource.personal;
    }
  }

  @override
  void write(BinaryWriter writer, ServerSource obj) {
    switch (obj) {
      case ServerSource.official:
        writer.writeByte(0);
        break;
      case ServerSource.personal:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
