package com.lumira.healthcare;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.graphics.Color;
import android.graphics.Typeface;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public class MainActivity extends Activity {
    private LinearLayout root;
    private final int teal = Color.rgb(22,160,133);

    @Override public void onCreate(Bundle savedInstanceState) { super.onCreate(savedInstanceState); showHome(); }
    private TextView text(String value,float size,int color){ TextView t=new TextView(this); t.setText(value); t.setTextSize(size); t.setTextColor(color); t.setPadding(0,8,0,8); return t; }
    private Button action(String label){ Button b=new Button(this); b.setText(label); b.setAllCaps(false); b.setTextSize(16); b.setTextColor(Color.WHITE); b.setBackgroundColor(teal); LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,58); p.setMargins(0,8,0,8); b.setLayoutParams(p); return b; }
    private void showHome(){
        root=new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL); root.setPadding(30,25,30,25); root.setBackgroundColor(Color.WHITE);
        TextView brand=text("LUMIRA",34,teal); brand.setTypeface(Typeface.DEFAULT_BOLD); root.addView(brand);
        UserProfile user=new SessionManager(this).getUser();
        String greeting=user.getName().isEmpty()?"Welcome":("Welcome, "+user.getName());
        root.addView(text(greeting,20,Color.DKGRAY)); root.addView(text("Healthcare Door to Door",16,Color.GRAY));
        Button profile=action("👤  My Profile"); profile.setOnClickListener(v->startActivity(new Intent(this,ProfileActivity.class))); root.addView(profile);
        TextView welcome=text("How can we help you today?",24,Color.rgb(35,35,35)); welcome.setPadding(0,28,0,12); root.addView(welcome);
        add("🩺  Find a Doctor","Doctor Care","Doctor discovery and appointment booking will be connected here.");
        add("📅  Book Appointment","Appointments","Your appointments and booking flow will appear here.");
        add("💊  Pharmacy","Pharmacy","Medicines, prescriptions and delivery will be connected here.");
        add("🚑  Emergency Help","Emergency","Emergency service integration will be added in the next module.");
        add("🏠  Home Healthcare","Home Healthcare","Nurse, caregiver and home-visit services will appear here.");
        ScrollView scroll=new ScrollView(this); scroll.addView(root); setContentView(scroll);
    }
    private void add(String label,String title,String body){ Button b=action(label); b.setOnClickListener(v->showMessage(title,body)); root.addView(b); }
    private void showMessage(String title,String body){ root.removeAllViews(); TextView back=text("← Back",17,teal); back.setOnClickListener(v->showHome()); root.addView(back); TextView h=text(title,30,teal); h.setTypeface(Typeface.DEFAULT_BOLD); root.addView(h); root.addView(text(body,18,Color.DKGRAY)); Button next=action("Continue"); next.setOnClickListener(v->showHome()); root.addView(next); }
}
