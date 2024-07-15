library routes;

import 'dart:convert';

import 'package:auth_server/config/set_up.dart';
import 'package:auth_server/utils/request_utils.dart';
import 'package:auth_server/utils/utils.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part "public/login.dart";
part "public/register.dart";
part "protected/echo.dart";
