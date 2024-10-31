import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_nexus/utils/Utils.dart';
import '../utils/routes/routes_names.dart';

class ApiService with ChangeNotifier {
  final String _url = 'http://54.197.126.5:8080';
  final String _url2 = 'http://54.197.126.5:8000';

  bool loading = false;

  Future<void> _saveLoginType(String loginType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_type', loginType);
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenMap = json.decode(token);
    final accessToken = tokenMap['access_token'];
    final refreshToken = tokenMap['refresh_token'];
    final tokenType = tokenMap['token_type'];

    await prefs.setString('token', token);
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('token_type', tokenType);
  }

  Future<Map<String, String?>> getAllTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');
    final tokenType = prefs.getString('token_type');

    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }

  Future<bool> isLoggedIn() async {
    final tokens = await getAllTokens();
    return tokens['access_token'] != null;
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_type');

    Navigator.pushNamedAndRemoveUntil(
      context,
      RoutesName.selectionScreen,
      (route) => false,
    );
  }

  Future<void> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken != null) {
        final url =
            Uri.parse('$_url/token/refresh?refresh_token=$refreshToken');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final newAccessToken = data['access_token'];
          final tokenType = data['token_type'];

          await prefs.setString('access_token', newAccessToken);
          await prefs.setString('token_type', tokenType);
          print('token refreshed');
        } else {
          print(
              'Token refresh failed with status code: ${response.statusCode}');
          print('Error message: ${response.body}');
        }
      } else {
        print('Refresh token is null'); // Add a message for debugging
      }
    } catch (e) {
      // Handle errors
      print('Error refreshing token: $e');
    }
  }

  Future<void> checkTokenValidity(int response, BuildContext context) async {
    if (response == 401) {
      await logout(context);
      Utils.flushBarMessage('Session Expired. Logging Out.', context);
    }
  }

  Future<void> signupUser(
      String name, String email, String password, BuildContext context) async {
    final response = await http.post(
      Uri.parse('$_url/signup/user'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.userLoginScreen, (route) => false);
      Utils.flushBarMessage('User Account Created Successfully', context);
    } else {
      Utils.flushBarMessage(jsonDecode(response.body)['detail'], context);
      print('Failed to create user, ${response.statusCode}, ${response.body}');
    }
  }

  Future<String> loginUser(
      String email, String password, BuildContext context) async {
    loading = true;
    notifyListeners();
    final response = await http.post(
      Uri.parse('$_url/login/user'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];
      final tokenType = data['token_type'];
      await _saveToken(json.encode({
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
      }));

      await _saveLoginType('user'); // Store the login type as 'company'

      loading = false;
      notifyListeners();
      return accessToken;
    } else {
      loading = false;
      notifyListeners();
      Utils.flushBarMessage('Error: ${response.statusCode}, Failed', context);
      print(jsonDecode(response.body)['detail']);
      throw Exception(jsonDecode(response.body)['detail']);
    }
  }

  Future<void> signupCompany(
      String name,
      String email,
      String password,
      File logoFile,
      String description,
      String tagline,
      BuildContext context) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$_url/signup/companies'));

    request.files.add(
      http.MultipartFile.fromBytes(
        'logo',
        await logoFile.readAsBytes(),
        filename: logoFile.path,
      ),
    );

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['description'] = description;
    request.fields['tagline'] = tagline;

    final response = await request.send();

    if (response.statusCode == 200) {
      Navigator.pushNamedAndRemoveUntil(
          context, RoutesName.companyLoginScreen, (route) => false);
      print('Status code : 200');
      Utils.flushBarMessage('Company Account Created Successfully', context);
    } else {
      print("Response status code: ${response.statusCode}");
      Utils.flushBarMessage(
          jsonDecode(await response.stream.bytesToString())['detail'], context);
      throw Exception('Failed to create company, ${response.statusCode}');
    }
  }

  Future<String> loginCompany(
      String email, String password, BuildContext context) async {
    loading = true;
    notifyListeners();
    final response = await http.post(
      Uri.parse('$_url/login/companies'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];
      final tokenType = data['token_type'];
      await _saveToken(json.encode({
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
      }));
      await _saveLoginType('company'); // Store the login type as 'company'

      loading = false;
      notifyListeners();
      return accessToken;
    } else {
      loading = false;
      notifyListeners();
      Utils.flushBarMessage('Error: ${response.statusCode}, Failed', context);
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final tokens = await getAllTokens();
    final accessToken = tokens['access_token'];
    if (accessToken != null) {
      return {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
    }
    throw Exception('Token not found');
  }

  Future<Map<String, dynamic>> getcurrentUserData() async {
    refreshToken();
    final response = await http.get(Uri.parse('$_url/user/me'),
        headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('User Data: $data');
      return {
        'name': data['name'],
        'email': data['email'],
        'plan_name': data['plan_name'],
        'subscription_status': data['subscription_status'],
        'role': data['role']
      };
    } else {
      throw Exception('Failed to get current user email');
    }
  }

  Future<int> fetchTotalQueryLimit() async {
    refreshToken();
    final url = '$_url/user/query_limit';
    final response =
        await http.get(Uri.parse(url), headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data['query_limit']);
      return data['query_limit'];
    } else {
      throw Exception('Failed to load query limit');
    }
  }

  Future<int> fetchQueryCount() async {
    refreshToken();
    final url = Uri.parse(
      '$_url/user/query_count',
    );
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print(jsonData['query_count']);
      return jsonData['query_count'];
    } else {
      print(response.statusCode);
      throw Exception('Failed to get query limit');
    }
  }

  Future<File> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/image.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      print('Error downloading image: $e');
      rethrow; // Rethrow the error
    }
  }

  Future<String> generate3DModel(String imageUrl, BuildContext context) async {
    loading = true; // Set loading to true
    notifyListeners(); // Notify listeners about the change

    File downloadedImageFile;
    try {
      print('Starting image download...');
      downloadedImageFile = await _downloadImage(imageUrl);
      print('Image downloaded successfully: ${downloadedImageFile.path}');
    } catch (e) {
      print('Error downloading image: $e');
      throw Exception('Failed to download image: $e');
    }

    try {
      String url = '$_url/generate_3d/';
      var tokens = await getAllTokens();
      String? accessToken = tokens['access_token'];

      if (accessToken == null) {
        throw Exception('Access token is null');
      }

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.files.add(
          await http.MultipartFile.fromPath('file', downloadedImageFile.path));

      print('Sending request to $url');
      var response = await request.send();
      print('Request sent, waiting for response...');

      if (response.statusCode == 200 || response.statusCode == 307) {
        if (response.statusCode == 307) {
          var newUrl = response.headers['location'];
          if (newUrl != null) {
            print('Redirecting to $newUrl');
            request = http.MultipartRequest('POST', Uri.parse(newUrl));
            request.headers['Authorization'] = 'Bearer $accessToken';
            request.files.add(await http.MultipartFile.fromPath(
                'file', downloadedImageFile.path));
            response = await request.send();
          } else {
            throw Exception('Redirect location is null');
          }
        }

        var responseBody = await http.Response.fromStream(response);
        print('Response received, saving model...');
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        File file = File('$tempPath/model.gltf');
        await file.writeAsBytes(responseBody.bodyBytes);

        print('File saved at ${file.path}');
        loading = false; // Set loading to false
        notifyListeners(); // Notify listeners about the change
        return file.path;
      } else if (response.statusCode == 401) {
        logout(context);
        Utils.flushBarMessage('Session expired logging out.', context);
        throw Exception('Session expired');
      } else if (response.statusCode == 429) {
        Utils.flushBarMessage('Your query limit reached.', context);
        throw Exception('Query limit reached. Please try again later.');
      } else {
        print('Failed to generate 3D model: ${response.statusCode}');
        var responseBody = await http.Response.fromStream(response);
        print('Response body: ${responseBody.body}');
        loading = false; // Set loading to false
        notifyListeners(); // Notify listeners about the change
        throw Exception(
            'Failed to generate 3D model: ${response.statusCode}, ${responseBody.body}');
      }
    } catch (e) {
      loading = false; // Set loading to false
      notifyListeners(); // Notify listeners about the change
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<Image> sendRequest(
      String vtonImagePath, String garmImagePath, BuildContext context) async {
    refreshToken();
    try {
      String url = '$_url2/process_hd';

      final vtonImageBytes = await File(vtonImagePath).readAsBytes();
      final garmImageBytes = await File(garmImagePath).readAsBytes();
      final vtonImgEncoded = base64Encode(vtonImageBytes);
      final garmImgEncoded = base64Encode(garmImageBytes);

      // Prepare the JSON data payload
      final data = {
        "vton_img": vtonImgEncoded,
        "garm_img": garmImgEncoded,
        "n_samples": 1, // Optionally adjust
        "n_steps": 40, // Optionally adjust
        "image_scale": 9.0, // Optionally adjust
        "seed": -1 // Optionally adjust
      };

      // Send POST request to the API
      final response = await http.post(Uri.parse(url),
          headers: await _getHeaders(), body: jsonEncode(data));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final base64Image = result['result'];

        // Decode the base64 string into bytes
        Uint8List decodedBytes = base64Decode(base64Image);

        // Return the image widget
        return Image.memory(decodedBytes);
      } else if (response.statusCode == 401) {
        logout(context);
        Utils.flushBarMessage('Session expired logging out.', context);
        throw Exception('Session expired');
      } else {
        print('Failed to send request: ${response.statusCode}');
        throw Exception('Failed to send request: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasCompletedOnboarding', true);
  }

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasCompletedOnboarding') ?? false;
  }

  Future<void> addCompanyProduct(
      String imagePath, String description, BuildContext context) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$_url/company/upload-image'));

    request.headers.addAll(await _getHeaders());

    // Add image file
    var image = await http.MultipartFile.fromPath('image', imagePath);
    request.files.add(image);

    // Add description
    request.fields['description'] = description;

    // Send the request
    var response = await request.send();

    // Check the response status
    if (response.statusCode == 200) {
      Utils.flushBarMessage('Product successfully added', context);

      print('Image uploaded successfully!');
    } else if (response.statusCode == 429) {
      Utils.flushBarMessage('Your query limit reached.', context);

      throw Exception('Query limit reached. Please try again later.');
    } else {
      checkTokenValidity(response.statusCode, context);
      print('Error uploading image: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCompanies(
      BuildContext context) async {
    refreshToken();
    final Uri url = Uri.parse('$_url/companies');

    try {
      // Make the GET request with the authorization header
      final response = await http.get(url, headers: await _getHeaders());

      // Check if the response status is OK
      if (response.statusCode == 200) {
        // Parse the JSON response into a list of maps
        List<dynamic> data = json.decode(response.body);
        print('data $data');
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        checkTokenValidity(response.statusCode, context);
        print('Failed to load companies: ${response.statusCode}');
        throw Exception('Failed to load companies');
      }
    } catch (e) {
      // Handle any exceptions during the API call
      print('Error: $e');
      throw Exception('Failed to load companies');
    }
  }

  Future<List<Map<String, dynamic>>> getBrandImages(
      String companyId, BuildContext context) async {
    refreshToken();
    final Uri uri = Uri.parse('$_url/company/$companyId/images/');

    try {
      final response = await http.get(uri, headers: await _getHeaders());

      // Check for a successful response
      if (response.statusCode == 200) {
        // Parse the JSON response
        List<dynamic> data = jsonDecode(response.body);
        print('Image Data: $data');
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        checkTokenValidity(response.statusCode, context);
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred: $e');
      return [];
    }
  }

  Future<void> updateUser(
      String name, String email, String password, BuildContext context) async {
    final headers = await _getHeaders();

    final body =
        jsonEncode({'name': name, 'email': email, 'password': password});

    final Uri apiUrl = Uri.parse('$_url/user/update');

    try {
      final response = await http.put(
        apiUrl,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        Utils.flushBarMessage('Password Updated Successfully', context);
        print('User updated successfully!');
      } else {
        print('Error updating user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<List<Map<String, String>>> fetch3DModel() async {
    Map<String, String> headers = await _getHeaders();
    Uri uri = Uri.parse('$_url/company/get_3d_models');

    // Make the GET request
    http.Response response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print('Response: $data');
      // Ensure all values in the map are of type String
      List<Map<String, String>> images = data.map((item) {
        return {
          'path': item['path']
              .toString()
              .replaceAll('company_data', 'clothes'), // Replace path as needed
          'description': item['description'].toString(),
          'image_path': item['image_path']
              .toString()
              .replaceAll('company_data', 'clothes')
        };
      }).toList();

      print('Images: $images');
      return images;
    } else {
      // If the server returns an error response, throw an exception
      throw Exception('Failed to load 3D model');
    }
  }

  Future<List<Map<String, String>>> getAllMedia(
      String companyId, BuildContext context) async {
    Map<String, String> headers = await _getHeaders();

    Uri uri = Uri.parse('$_url/user/get_all_media/$companyId');
    http.Response response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print('Response: $data');

      List<Map<String, String>> images = data.map((item) {
        return {
          'path': item['path'].toString().replaceAll('company_data', 'clothes'),
          'description': item['description'].toString(),
          'image_path': item['image_path']
              .toString()
              .replaceAll('company_data', 'clothes')
        };
      }).toList();

      print('Images: $images');
      return images;
    } else {
      checkTokenValidity(response.statusCode, context);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  }

  Future<void> feedback(String? fName, String? lName, String? email,
      String? message, BuildContext context) async {
    final url = Uri.parse('$_url/submit_feedback/');
    final Map<String, dynamic> body = {
      "first_name": fName,
      "last_name": lName,
      "email": email,
      "message": message,
    };

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(body), // Encode the body to JSON format
      );

      if (response.statusCode == 200) {
        print('Successfully submitted');
        Utils.flushBarMessage('Form submitted successfully', context);
      } else {
        print('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting feedback: $e');
    }
  }
}
