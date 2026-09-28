package com.lumira.healthcare;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

public class FeatureActivity extends Activity {
    private static final int TEAL = Color.rgb(22, 160, 133);

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String title = getIntent().getStringExtra("title");
        if (title == null) title = "LUMIRA";

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(32, 45, 32, 32);
        root.setBackgroundColor(Color.WHITE);

        TextView back = new TextView(this);
        back.setText("← Back to LUMIRA");
        back.setTextSize(17);
        back.setTextColor(TEAL);
        back.setPadding(0, 0, 0, 30);
        back.setOnClickListener(v -> finish());
        root.addView(back);

        TextView heading = new TextView(this);
        heading.setText(title);
        heading.setTextSize(30);
        heading.setTextColor(TEAL);
        heading.setTypeface(Typeface.DEFAULT_BOLD);
        root.addView(heading);

        TextView body = new TextView(this);
        body.setText(getDescription(title));
        body.setTextSize(18);
        body.setTextColor(Color.DKGRAY);
        body.setPadding(0, 25, 0, 30);
        root.addView(body);

        Button continueButton = new Button(this);
        continueButton.setText("Continue");
        continueButton.setAllCaps(false);
        continueButton.setTextSize(17);
        continueButton.setTextColor(Color.WHITE);
        continueButton.setGravity(Gravity.CENTER);
        continueButton.setBackgroundColor(TEAL);
        continueButton.setOnClickListener(v -> finish());
        root.addView(continueButton);

        setContentView(root);
    }

    private String getDescription(String title) {
        if ("Doctor Care".equals(title))
            return "Find doctors by specialty and prepare the appointment workflow.\n\nNext integration: doctor profiles, availability, booking and consultation history.";
        if ("Appointments".equals(title))
            return "Your appointment center.\n\nNext integration: date/time selection, confirmation, cancellation and reminders.";
        if ("Pharmacy".equals(title))
            return "Medicine and prescription management.\n\nNext integration: prescription upload, medicine search, cart and delivery tracking.";
        if ("Emergency".equals(title))
            return "Emergency support entry point.\n\nNext integration: verified emergency contacts, ambulance workflow and live location sharing.";
        if ("Home Healthcare".equals(title))
            return "Healthcare at your doorstep.\n\nNext integration: nursing, caregiver, lab sample collection and home-visit scheduling.";
        if ("Telemedicine".equals(title))
            return "Secure digital consultation preparation.\n\nNext integration: doctor availability, consent, secure video and consultation records.";
        return "LUMIRA • Healthcare Door to Door\n\nThis module is ready for the next integration step.";
    }
}
