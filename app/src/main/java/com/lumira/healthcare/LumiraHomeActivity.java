package com.lumira.healthcare;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public class LumiraHomeActivity extends Activity {
    private static final int NAVY = Color.rgb(24,39,70);
    private static final int PURPLE = Color.rgb(92,79,214);
    private static final int BG = Color.rgb(247,248,252);
    private static final int INK = Color.rgb(22,37,66);
    private static final int MUTED = Color.rgb(112,123,147);

    private int dp(int v) { return (int)(v * getResources().getDisplayMetrics().density + .5f); }
    private GradientDrawable bg(int color, int radius) { GradientDrawable d=new GradientDrawable(); d.setColor(color); d.setCornerRadius(dp(radius)); return d; }

    private TextView text(String s,float size,int color,boolean bold) {
        TextView t=new TextView(this); t.setText(s); t.setTextSize(size); t.setTextColor(color);
        if(bold)t.setTypeface(Typeface.DEFAULT,Typeface.BOLD); return t;
    }

    private void card(LinearLayout parent,String title,String subtitle,Runnable action) {
        TextView c=text(title+"\n"+subtitle,16,INK,true);
        c.setLineSpacing(0,1.15f); c.setPadding(dp(20),dp(18),dp(20),dp(18));
        c.setBackground(bg(Color.WHITE,22)); c.setElevation(dp(2)); c.setOnClickListener(v->action.run());
        LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2); p.setMargins(0,0,0,dp(12)); parent.addView(c,p);
    }

    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        LinearLayout root=new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL); root.setBackgroundColor(BG);

        LinearLayout header=new LinearLayout(this); header.setOrientation(LinearLayout.VERTICAL);
        header.setPadding(dp(22),dp(26),dp(22),dp(22)); header.setBackground(bg(NAVY,0));
        header.addView(text("LUMIRA",28,Color.WHITE,true));
        header.addView(text("Healthcare • AI • Care at your doorstep",13,Color.rgb(210,220,238),false)); root.addView(header);

        ScrollView scroll=new ScrollView(this); LinearLayout content=new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL); content.setPadding(dp(18),dp(18),dp(18),dp(24)); scroll.addView(content);

        content.addView(text("Your LUMIRA",24,INK,true));
        LinearLayout.LayoutParams intro=new LinearLayout.LayoutParams(-1,-2); intro.setMargins(0,0,0,dp(18));
        content.addView(text("One app • care • AI assistant • racing • workspace",13,MUTED,false),intro);

        card(content,"LUMIRA Care","Home care, emergency help, medicines, records and profile",
            ()->startActivity(new Intent(this,MainActivity.class)));
        card(content,"LUMIRA AI","Ask questions, including MBBS study questions, through the secure backend",
            ()->startActivity(new Intent(this,ChatActivity.class)));
        card(content,"LUMIRA Racing","Mobile 2D racing • traffic • AI driver • nitro • laps",
            ()->startActivity(new Intent(this,RacingActivity.class)));
        card(content,"AI Office","Planning, GitHub, build and development workspace",
            ()->startActivity(new Intent(this,OfficeDashboardActivity.class)));

        TextView status=text("AI connection is handled by the LUMIRA backend. API keys stay server-side.",12,MUTED,false);
        status.setPadding(dp(4),dp(8),dp(4),dp(8)); content.addView(status);

        root.addView(scroll,new LinearLayout.LayoutParams(-1,0,1)); setContentView(root);
    }
}
