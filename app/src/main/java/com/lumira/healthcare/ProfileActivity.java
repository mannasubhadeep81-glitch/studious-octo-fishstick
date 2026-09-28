package com.lumira.healthcare;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Color;
import android.graphics.Typeface;
import android.view.Gravity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

public class ProfileActivity extends Activity {
    private final int teal = Color.rgb(22,160,133);
    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        SessionManager session = new SessionManager(this);
        UserProfile user = session.getUser();
        LinearLayout root = new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL); root.setPadding(32,55,32,32); root.setBackgroundColor(Color.WHITE);
        TextView title = new TextView(this); title.setText("My Profile"); title.setTextSize(30); title.setTextColor(teal); title.setTypeface(Typeface.DEFAULT_BOLD); root.addView(title);
        TextView info = new TextView(this); info.setText("\nName\n" + user.getName() + "\n\nPhone\n" + user.getPhone() + "\n\nEmail\n" + (user.getEmail().isEmpty()?"Not added":user.getEmail())); info.setTextSize(18); info.setTextColor(Color.DKGRAY); root.addView(info);
        Button logout = new Button(this); logout.setText("Sign out"); logout.setAllCaps(false); logout.setOnClickListener(v->{ session.logout(); finish(); }); root.addView(logout);
        setContentView(root);
    }
}
