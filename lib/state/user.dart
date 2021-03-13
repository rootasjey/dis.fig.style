import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:relines/router/app_router.gr.dart';
import 'package:relines/types/cloud_func_error.dart';
import 'package:relines/types/update_email_resp.dart';
import 'package:relines/utils/app_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';

part 'user.g.dart';

class StateUser = StateUserBase with _$StateUser;

abstract class StateUserBase with Store {
  User _userAuth;

  @observable
  String avatarUrl = '';

  @observable
  bool canManageQuotes = false;

  @observable
  String lang = 'en';

  @observable
  bool isFirstLaunch = false;

  @observable
  bool isUserConnected = false;

  @observable
  String username = '';

  /// Used to sync fav. status between views,
  /// e.g. re-fetch on nav. back from quote page -> quotes list.
  /// _NOTE: Should be set to false after status sync (usually on quotes list)_.
  bool mustUpdateFav = false;

  /// Last time the favourites has been updated.
  @observable
  DateTime updatedFavAt = DateTime.now();

  User get userAuth {
    return _userAuth;
  }

  Future refreshUserRights() async {
    try {
      if (_userAuth == null || _userAuth.uid == null) {
        canManageQuotes = false;
      }

      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userAuth.uid)
          .get();

      final userData = user.data();

      if (user == null || userData == null) {
        canManageQuotes = false;
      }

      final bool canManage = userData['rights']['user:managequotidian'];
      canManageQuotes = canManage;
    } on CloudFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");
      canManageQuotes = false;
    } catch (error) {
      debugPrint(error.toString());
      canManageQuotes = false;
    }
  }

  Future activateDevAccount() async {
    try {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userAuth.uid)
          .get();

      final userData = user.data();
      final devData = userData['developer'];

      if (devData == null) {
        return;
      }

      final isDevProgActive = devData['isProgramActive'];

      if (isDevProgActive != true) {
        final callable = CloudFunctions(
          app: Firebase.app(),
          region: 'europe-west3',
        ).getHttpsCallable(
          functionName: 'developers-activateDevProgram',
        );

        await callable.call();
      }
    } on CloudFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  /// Use on sign out / user's data has changed.
  void clearAuthCache() {
    _userAuth = null;
  }

  Future<UpdateEmailResp> deleteAccount(String idToken) async {
    try {
      final callable = CloudFunctions(
        app: Firebase.app(),
        region: 'europe-west3',
      ).getHttpsCallable(
        functionName: 'users-deleteAccount',
      );

      final response = await callable.call({
        'idToken': idToken,
      });

      signOut();

      return UpdateEmailResp.fromJSON(response.data);
    } on CloudFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");

      return UpdateEmailResp(
        success: false,
        error: CloudFuncError(
          code: exception.details['code'],
          message: exception.details['message'],
        ),
      );
    } on PlatformException catch (exception) {
      debugPrint(exception.toString());

      return UpdateEmailResp(
        success: false,
        error: CloudFuncError(
          code: exception.details['code'],
          message: exception.details['message'],
        ),
      );
    } catch (error) {
      debugPrint(error.toString());

      return UpdateEmailResp(
        success: false,
        error: CloudFuncError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }

  @action
  void setAvatarUrl(String url) {
    avatarUrl = url;
  }

  @action
  void setFirstLaunch(bool value) {
    isFirstLaunch = value;
  }

  @action
  void setLang(String newLang) {
    lang = newLang;
  }

  @action
  void setUserConnected() {
    isUserConnected = true;
  }

  @action
  void setUserDisconnected() {
    isUserConnected = false;
  }

  @action
  void setUserName(String name) {
    username = name;
  }

  @action
  void setAdminValue(bool value) {
    canManageQuotes = value;
  }

  /// Signin user with credentials if FirebaseAuth is null.
  Future<User> signin({String email, String password}) async {
    try {
      final credentialsMap = appStorage.getCredentials();

      email = email ?? credentialsMap['email'];
      password = password ?? credentialsMap['password'];

      if ((email == null || email.isEmpty) ||
          (password == null || password.isEmpty)) {
        return null;
      }

      final auth = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _userAuth = auth.user;

      // Subscription updates.
      FirebaseAuth.instance.userChanges().listen((userEvent) {
        _userAuth = userEvent;
        refreshUserRights();
      }, onDone: () {
        _userAuth = null;
      });

      setUserConnected();

      appStorage.setCredentials(
        email: email,
        password: password,
      );

      appStorage.setUserName(_userAuth.displayName);
      // PushNotifications.linkAuthUser(_userAuth.uid);

      await refreshUserRights();
      await activateDevAccount();

      return _userAuth;
    } catch (error) {
      appStorage.clearUserAuthData();
      return null;
    }
  }

  @action
  Future signOut({
    BuildContext context,
    bool redirectOnComplete = false,
  }) async {
    _userAuth = null;
    await appStorage.clearUserAuthData();
    await FirebaseAuth.instance.signOut();
    setUserDisconnected();

    // PushNotifications.unlinkAuthUser();

    if (redirectOnComplete) {
      if (context == null) {
        debugPrint("Please specify a context value to the"
            " [userState.signOut] function.");
        return;
      }

      context.router.root.navigate(HomeRoute());
    }
  }

  @action
  void updateFavDate() {
    updatedFavAt = DateTime.now();
  }

  Future<UpdateEmailResp> updateEmail(String email, String idToken) async {
    try {
      final callable = CloudFunctions(
        app: Firebase.app(),
        region: 'europe-west3',
      ).getHttpsCallable(
        functionName: 'users-updateEmail',
      );

      final response = await callable.call({
        'newEmail': email,
        'idToken': idToken,
      });

      appStorage.setEmail(email);
      await stateUser.signin(email: email);

      return UpdateEmailResp.fromJSON(response.data);
    } on CloudFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");
      return UpdateEmailResp(
        success: false,
        error: CloudFuncError(
          code: exception.details['code'],
          message: exception.details['message'],
        ),
      );
    } on PlatformException catch (exception) {
      debugPrint(exception.toString());
      return UpdateEmailResp(
        success: false,
        error: CloudFuncError(
          code: exception.details['code'],
          message: exception.details['message'],
        ),
      );
    } catch (error) {
      debugPrint(error.toString());

      return UpdateEmailResp(
        success: false,
        error: CloudFuncError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }

  Future<UpdateEmailResp> updateUsername(String newUsername) async {
    try {
      final callable = CloudFunctions(
        app: Firebase.app(),
        region: 'europe-west3',
      ).getHttpsCallable(
        functionName: 'users-updateUsername',
      );

      final response = await callable.call({
        'newUsername': newUsername,
      });

      appStorage.setUserName(newUsername);

      return UpdateEmailResp.fromJSON(response.data);
    } on CloudFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");
      return UpdateEmailResp(
        success: false,
        error: CloudFuncError(
          code: exception.details['code'],
          message: exception.details['message'],
        ),
      );
    } on PlatformException catch (exception) {
      debugPrint(exception.toString());

      return UpdateEmailResp(
        success: false,
        error: CloudFuncError(
          code: exception.details['code'],
          message: exception.details['message'],
        ),
      );
    } catch (error) {
      debugPrint(error.toString());

      return UpdateEmailResp(
        success: false,
        error: CloudFuncError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }
}

final stateUser = StateUser();
