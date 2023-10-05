// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String databaseHost = '47.250.10.195';
const int databasePort = 5432;
const String databaseName = 'amast_rnd';
const String username = 'rnd_user';
final String password = dotenv.env['SERVER_PASSWORD']!;

var databaseConnection = PostgreSQLConnection(
  databaseHost,
  databasePort,
  databaseName,
  queryTimeoutInSeconds: 3600,
  timeoutInSeconds: 3600,
  username: username,
  password: password,
);
