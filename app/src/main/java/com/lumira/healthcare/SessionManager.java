package com.lumira.healthcare;

import android.content.Context;
import android.content.SharedPreferences;

public final class SessionManager {
    private static final String PREF = "lumira_session";
    private static final String LOGGED_IN = "logged_in";
    private static final String NAME = "name";
    private static final String PHONE = "phone";
    private static final String EMAIL = "email";
    private final SharedPreferences prefs;

    public SessionManager(Context context) {
        prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE);
    }
    public void save(UserProfile user) {
        prefs.edit().putBoolean(LOGGED_IN, true)
                .putString(NAME, user.getName())
                .putString(PHONE, user.getPhone())
                .putString(EMAIL, user.getEmail()).apply();
    }
    public boolean isLoggedIn() { return prefs.getBoolean(LOGGED_IN, false); }
    public UserProfile getUser() {
        return new UserProfile(prefs.getString(NAME, ""), prefs.getString(PHONE, ""), prefs.getString(EMAIL, ""));
    }
    public void logout() { prefs.edit().clear().apply(); }
}
