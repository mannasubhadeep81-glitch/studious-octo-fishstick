package com.lumira.healthcare;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Color;
import android.view.Gravity;
import android.widget.LinearLayout;
import android.widget.TextView;

public class FeatureActivity extends Activity {
    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String title = getIntent().getStringExtra("title");
        if (title == null) title = "LUMIRA";
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL); root.setPadding(40,60,40,40);
        TextView heading = new TextView(this); heading.setText(title); heading.setTextSize(30); heading.setTextColor(Color.rgb(22,160,133));
        TextView body = new TextView(this); body.setText("LUMIRA \u2022 Healthcare Door to Door\n\nThis module is ready for the next integration step."); body.setTextSize(18); body.setPadding(0,30,0,0);
        root.addView(heading); root.addView(body); setContentView(root);
    }
}
