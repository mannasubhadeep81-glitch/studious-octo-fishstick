package com.lumira.healthcare;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Color;
import android.graphics.Typeface;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public class MainActivity extends Activity {
    private LinearLayout root;
    private int teal = Color.rgb(22,160,133);

    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        showHome();
    }

    private TextView text(String value, float size, int color) {
        TextView t = new TextView(this);
        t.setText(value); t.setTextSize(size); t.setTextColor(color);
        t.setPadding(0, 8, 0, 8); return t;
    }

    private Button action(String label) {
        Button b = new Button(this); b.setText(label); b.setAllCaps(false);
        b.setTextSize(16); b.setTextColor(Color.WHITE); b.setBackgroundColor(teal);
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(-1, 58);
        p.setMargins(0, 10, 0, 10); b.setLayoutParams(p); return b;
    }

    private void showHome() {
        root = new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(36, 28, 36, 28); root.setBackgroundColor(Color.WHITE);

        TextView brand = text("LUMIRA", 34, teal); brand.setTypeface(Typeface.DEFAULT_BOLD);
        root.addView(brand);
        root.addView(text("Healthcare Door to Door", 17, Color.DKGRAY));
        root.addView(text("One Step Towards Humanity", 15, Color.GRAY));

        TextView welcome = text("How can we help you today?", 25, Color.rgb(35,35,35));
        welcome.setPadding(0, 38, 0, 18); root.addView(welcome);

        Button doctor = action("🩺  Find a Doctor");
        doctor.setOnClickListener(v -> showMessage("Doctor Care", "Doctor discovery and appointment booking will be connected here."));
        root.addView(doctor);
        Button appointment = action("📅  Book Appointment");
        appointment.setOnClickListener(v -> showMessage("Appointments", "Your appointments and booking flow will appear here."));
        root.addView(appointment);
        Button pharmacy = action("💊  Pharmacy");
        pharmacy.setOnClickListener(v -> showMessage("Pharmacy", "Medicines, prescriptions and delivery will be connected here."));
        root.addView(pharmacy);
        Button emergency = action("🚑  Emergency Help");
        emergency.setOnClickListener(v -> showMessage("Emergency", "Emergency service integration will be added in the next module."));
        root.addView(emergency);
        Button homecare = action("🏠  Home Healthcare");
        homecare.setOnClickListener(v -> showMessage("Home Healthcare", "Nurse, caregiver and home-visit services will appear here."));
        root.addView(homecare);

        ScrollView scroll = new ScrollView(this); scroll.addView(root); setContentView(scroll);
    }

    private void showMessage(String title, String body) {
        root.removeAllViews();
        TextView back = text("← Back", 17, teal); back.setOnClickListener(v -> showHome()); root.addView(back);
        TextView h = text(title, 30, teal); h.setTypeface(Typeface.DEFAULT_BOLD); root.addView(h);
        root.addView(text(body, 18, Color.DKGRAY));
        Button next = action("Continue"); next.setOnClickListener(v -> showHome()); root.addView(next);
    }
}
