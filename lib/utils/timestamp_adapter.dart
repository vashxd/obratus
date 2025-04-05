import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

/// Adaptador para o tipo Timestamp do Firebase
class TimestampAdapter extends TypeAdapter<Timestamp> {
  @override
  final int typeId = 100; // Escolhendo um ID que provavelmente não conflita com outros adaptadores

  @override
  Timestamp read(BinaryReader reader) {
    // Lê os segundos e nanossegundos do BinaryReader
    final seconds = reader.readInt();
    final nanoseconds = reader.readInt();
    
    // Cria um novo Timestamp com esses valores
    return Timestamp(seconds, nanoseconds);
  }

  @override
  void write(BinaryWriter writer, Timestamp obj) {
    // Escreve os segundos e nanossegundos no BinaryWriter
    writer.writeInt(obj.seconds);
    writer.writeInt(obj.nanoseconds);
  }
}