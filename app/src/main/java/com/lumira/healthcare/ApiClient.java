package com.lumira.healthcare;

import org.json.JSONObject;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public final class ApiClient {
    private static final String BASE_URL = "https://studious-octo-fishstick-7.onrender.com";

    private ApiClient() {}

    public interface Callback {
        void onSuccess(String response);
        void onError(String error);
    }

    public static void healthCheck(Callback callback) {
        new Thread(() -> request("GET", "/", null, callback)).start();
    }

    public static void chat(String message, Callback callback) {
        new Thread(() -> {
            try {
                JSONObject body = new JSONObject();
                body.put("message", message == null ? "" : message.trim());
                request("POST", "/api/chat", body.toString(), callback);
            } catch (Exception e) {
                callback.onError(e.getMessage() == null ? "Could not create request" : e.getMessage());
            }
        }).start();
    }

    private static void request(String method, String path, String body, Callback callback) {
        HttpURLConnection connection = null;
        try {
            URL url = new URL(BASE_URL + path);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod(method);
            connection.setConnectTimeout(20000);
            connection.setReadTimeout(60000);
            connection.setUseCaches(false);
            connection.setRequestProperty("Accept", "application/json");

            if ("POST".equals(method)) {
                connection.setDoOutput(true);
                connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
                connection.setFixedLengthStreamingMode(bytes.length);
                try (OutputStream out = connection.getOutputStream()) {
                    out.write(bytes);
                }
            }

            int code = connection.getResponseCode();
            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    code >= 200 && code < 400 ? connection.getInputStream() : connection.getErrorStream(),
                    StandardCharsets.UTF_8));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) response.append(line);
            reader.close();

            String result = response.toString();
            if (code >= 200 && code < 300) {
                callback.onSuccess(result);
            } else {
                callback.onError("HTTP " + code + ": " + result);
            }
        } catch (Exception e) {
            callback.onError(e.getMessage() == null ? "Connection failed" : e.getMessage());
        } finally {
            if (connection != null) connection.disconnect();
        }
    }
}
