package com.lumira.healthcare;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public final class ApiClient {
    private static final String BASE_URL = "https://studious-octo-fishstick-7.onrender.com";

    private ApiClient() {}

    public interface Callback {
        void onSuccess(String response);
        void onError(String error);
    }

    public static void healthCheck(Callback callback) {
        new Thread(() -> {
            HttpURLConnection connection = null;
            try {
                URL url = new URL(BASE_URL + "/");
                connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod("GET");
                connection.setConnectTimeout(15000);
                connection.setReadTimeout(15000);

                int code = connection.getResponseCode();
                BufferedReader reader = new BufferedReader(
                        new InputStreamReader(
                                code >= 200 && code < 400
                                        ? connection.getInputStream()
                                        : connection.getErrorStream()
                        )
                );

                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                reader.close();

                if (code >= 200 && code < 300) {
                    callback.onSuccess(response.toString());
                } else {
                    callback.onError("HTTP " + code + ": " + response);
                }
            } catch (Exception e) {
                callback.onError(e.getMessage() == null ? "Connection failed" : e.getMessage());
            } finally {
                if (connection != null) connection.disconnect();
            }
        }).start();
    }
}
