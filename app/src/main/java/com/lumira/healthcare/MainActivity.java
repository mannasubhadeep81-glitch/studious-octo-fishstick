package com.lumira.healthcare;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public class MainActivity extends Activity {
    private static final int TEAL = Color.rgb(22, 160, 133);
    private static final int DARK = Color.rgb(35, 35, 35);
    private LinearLayout root;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        showHome();
    }

    private TextView text(String value, float size, int color) {
        TextView t = new TextView(this);
        t.setText(value);
        t.setTextSize(size);
        t.setTextColor(color);
        t.setPadding(0, 8, 0, 8);
        return t;
    }

    private Button action(String label) {
        Button b = new Button(this);
        b.setText(label);
        b.setAllCaps(false);
        b.setTextSize(16);
        b.setTextColor(Color.WHITE);
        b.setGravity(Gravity.CENTER_VERTICAL | Gravity.START);
        b.setPadding(28, 0, 20, 0);
        b.setBackgroundColor(TEAL);
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(-1, 60);
        p.setMargins(0, 7, 0, 7);
        b.setLayoutParams(p);
        return b;
    }

    private void showHome() {
        root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(28, 30, 28, 28);
        root.setBackgroundColor(Color.WHITE);

        TextView brand = text("LUMIRA", 34, TEAL);
        brand.setTypeface(Typeface.DEFAULT_BOLD);
        root.addView(brand);
        root.addView(text("Healthcare Door to Door", 16, Color.GRAY));

        UserProfile user = new SessionManager(this).getUser();
        String greeting = user.getName().isEmpty() ? "Welcome" : "Welcome, " + user.getName();
        TextView hello = text(greeting, 21, DARK);
        hello.setPadding(0, 24, 0, 4);
        root.addView(hello);
        root.addView(text("How can we help you today?", 25, DARK));

        Button profile = action("👤  My Profile");
        profile.setOnClickListener(v -> startActivity(new Intent(this, ProfileActivity.class)));
        root.addView(profile);

        addFeature("🩺  Find a Doctor", "Search doctors and start an appointment", "Doctor Care");
        addFeature("📅  Book Appointment", "Manage your upcoming consultations", "Appointments");
        addFeature("💊  Pharmacy", "Prescriptions, medicines and delivery", "Pharmacy");
        addFeature("🚑  Emergency Help", "Quick access to emergency support", "Emergency");
        addFeature("🏠  Home Healthcare", "Nursing, caregiver and home visits", "Home Healthcare");
        addFeature("📹  Telemedicine", "Prepare for secure video consultations", "Telemedicine");

        root.addView(text("LUMIRA MVP • One Step Towards Humanity", 13, Color.GRAY));

        ScrollView scroll = new ScrollView(this);
        scroll.setFillViewport(true);
        scroll.addView(root);
        setContentView(scroll);
    }

    private void addFeature(String label, String subtitle, String title) {
        Button b = action(label + "\n" + subtitle);
        b.setOnClickListener(v -> {
            Intent intent = new Intent(this, FeatureActivity.class);
            intent.putExtra("title", title);
            startActivity(intent);
        });
        root.addView(b);
    }
}
