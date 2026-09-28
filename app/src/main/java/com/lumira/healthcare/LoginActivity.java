package com.lumira.healthcare;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

public class LoginActivity extends Activity {
    private final int teal = Color.rgb(22,160,133);
    private EditText name, phone, email;
    private SessionManager session;

    private TextView label(String value, float size, int color) {
        TextView t = new TextView(this); t.setText(value); t.setTextSize(size); t.setTextColor(color); t.setPadding(0,8,0,8); return t;
    }
    private EditText field(String hint, int type) {
        EditText e = new EditText(this); e.setHint(hint); e.setTextSize(17); e.setSingleLine(true); e.setInputType(type);
        e.setPadding(18,10,18,10); return e;
    }
    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        session = new SessionManager(this);
        if (session.isLoggedIn()) { openHome(); return; }
        LinearLayout root = new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL); root.setPadding(32,70,32,32); root.setGravity(Gravity.CENTER_HORIZONTAL); root.setBackgroundColor(Color.WHITE);
        TextView brand = label("LUMIRA", 38, teal); brand.setTypeface(Typeface.DEFAULT_BOLD); root.addView(brand);
        root.addView(label("Healthcare Door to Door",18,Color.DKGRAY));
        root.addView(label("Create your patient profile",22,Color.rgb(35,35,35)));
        name = field("Full name", InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_CAP_WORD); phone = field("Phone number", InputType.TYPE_CLASS_PHONE); email = field("Email (optional)", InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        root.addView(name); root.addView(phone); root.addView(email);
        Button start = new Button(this); start.setText("Create Profile & Continue"); start.setAllCaps(false); start.setTextSize(17); start.setTextColor(Color.WHITE); start.setBackgroundColor(teal); root.addView(start);
        start.setOnClickListener(v -> saveAndContinue());
        setContentView(root);
    }
    private void saveAndContinue() {
        String n=name.getText().toString().trim(), p=phone.getText().toString().trim(), e=email.getText().toString().trim();
        if(n.length()<2){ name.setError("Enter your name"); return; }
        if(p.length()<10){ phone.setError("Enter a valid phone number"); return; }
        if(!e.isEmpty() && !android.util.Patterns.EMAIL_ADDRESS.matcher(e).matches()){ email.setError("Enter a valid email"); return; }
        session.save(new UserProfile(n,p,e)); openHome();
    }
    private void openHome(){ startActivity(new Intent(this, MainActivity.class)); finish(); }
}
