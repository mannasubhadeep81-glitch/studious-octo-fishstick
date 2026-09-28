package com.lumira.healthcare;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public class FeatureActivity extends Activity {
    private static final int NAVY=Color.rgb(25,40,72), INK=Color.rgb(24,39,68), PURPLE=Color.rgb(91,78,214), CORAL=Color.rgb(255,112,102), BG=Color.rgb(247,248,252);
    private int dp(int v){return (int)(v*getResources().getDisplayMetrics().density+.5f);}
    private GradientDrawable bg(int color,int radius){GradientDrawable d=new GradientDrawable();d.setColor(color);d.setCornerRadius(dp(radius));return d;}
    private TextView text(String s,float size,int color,boolean bold){TextView t=new TextView(this);t.setText(s);t.setTextSize(size);t.setTextColor(color);if(bold)t.setTypeface(Typeface.DEFAULT,Typeface.BOLD);return t;}
    private LinearLayout.LayoutParams lp(int l,int t,int r,int b){LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2);p.setMargins(dp(l),dp(t),dp(r),dp(b));return p;}

    @Override public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState); String title=getIntent().getStringExtra("title"); if(title==null)title="LUMIRA";
        LinearLayout screen=new LinearLayout(this);screen.setOrientation(LinearLayout.VERTICAL);screen.setBackgroundColor(BG);
        ScrollView scroll=new ScrollView(this);LinearLayout root=new LinearLayout(this);root.setOrientation(LinearLayout.VERTICAL);root.setPadding(dp(18),dp(18),dp(18),dp(35));scroll.addView(root);screen.addView(scroll,new LinearLayout.LayoutParams(-1,0,1));
        TextView back=text("‹   Back to LUMIRA",16,PURPLE,true);back.setPadding(0,dp(8),0,dp(18));back.setOnClickListener(v->finish());root.addView(back);
        LinearLayout hero=new LinearLayout(this);hero.setOrientation(LinearLayout.VERTICAL);hero.setPadding(dp(22),dp(24),dp(22),dp(22));hero.setBackground(bg(NAVY,26));hero.addView(text(icon(title),34,Color.WHITE,true));hero.addView(text(title,28,Color.WHITE,true),lp(0,8,0,5));hero.addView(text(getDescription(title),14,Color.rgb(220,228,242),false));root.addView(hero);
        root.addView(text("What you can do",21,INK,true),lp(0,22,0,6));
        for(String a:getActions(title)){LinearLayout c=new LinearLayout(this);c.setOrientation(LinearLayout.HORIZONTAL);c.setGravity(Gravity.CENTER_VERTICAL);c.setPadding(dp(17),dp(15),dp(17),dp(15));c.setBackground(bg(Color.WHITE,18));c.setElevation(dp(1));c.addView(text("✓",19,Color.rgb(50,160,125),true),new LinearLayout.LayoutParams(dp(35),dp(35)));c.addView(text(a,15,INK,true),new LinearLayout.LayoutParams(0,-2,1));c.addView(text("›",25,Color.GRAY,false));root.addView(c,lp(0,5,0,5));}
        TextView primary=text(primaryAction(title),16,Color.WHITE,true);primary.setGravity(Gravity.CENTER);primary.setPadding(0,dp(16),0,dp(16));primary.setBackground(bg(CORAL,18));primary.setOnClickListener(v->android.widget.Toast.makeText(this,"This screen is ready for backend integration.",android.widget.Toast.LENGTH_SHORT).show());root.addView(primary,lp(0,18,0,8));
        TextView note=text("LUMIRA  •  Secure, compassionate, door-to-door care",12,Color.GRAY,false);note.setGravity(Gravity.CENTER);root.addView(note,lp(0,12,0,0));setContentView(screen);
    }
    private String icon(String title){if(title.contains("Pharmacy"))return"▣";if(title.contains("Emergency"))return"🚑";if(title.contains("Home"))return"⌂";if(title.contains("Telemedicine"))return"◉";if(title.contains("Appointment"))return"▣";return"♙";}
    private String primaryAction(String title){if(title.contains("Emergency"))return"Request emergency support";if(title.contains("Pharmacy"))return"Browse medicines";if(title.contains("Appointment"))return"Book an appointment";if(title.contains("Telemedicine"))return"Start consultation setup";return"Find available care";}
    private String[] getActions(String title){if(title.contains("Pharmacy"))return new String[]{"Browse common medicines","Upload a prescription for review","Track medicine delivery"};if(title.contains("Emergency"))return new String[]{"Request a verified emergency doctor","Request an ambulance","Share your location with approved care"};if(title.contains("Appointments"))return new String[]{"View upcoming appointments","Choose date and time","Manage confirmation and reminders"};if(title.contains("Home Healthcare"))return new String[]{"Request a home visit","Choose nursing or caregiver support","Schedule home sample collection"};if(title.contains("Telemedicine"))return new String[]{"Find available doctors","Prepare consent and consultation","Keep consultation records"};return new String[]{"Browse doctors by specialty","View doctor profiles and availability","Start the appointment workflow"};}
    private String getDescription(String title){if(title.contains("Doctor Care"))return"Find doctors by specialty, review availability and prepare your consultation.";if(title.contains("Appointments"))return"Manage upcoming consultations, dates, reminders and confirmations.";if(title.contains("Pharmacy"))return"Order medicines from verified pharmacies and keep prescriptions organized.";if(title.contains("Emergency"))return"A fast entry point for emergency care, ambulance requests and approved location sharing.";if(title.contains("Home Healthcare"))return"Bring nursing, caregiver and home-visit services closer to your doorstep.";if(title.contains("Telemedicine"))return"Prepare for a secure digital consultation with an available healthcare provider.";return"LUMIRA • Healthcare Door to Door";}
}
