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

/** LUMIRA Office: dashboard for the ChatGPT/OpenAI-led development workflow. */
public class OfficeDashboardActivity extends Activity {
    private final int NAVY = Color.rgb(24,39,70);
    private final int PURPLE = Color.rgb(92,79,214);
    private final int BG = Color.rgb(247,248,252);
    private final int INK = Color.rgb(22,37,66);
    private final int MUTED = Color.rgb(112,123,147);

    private int dp(int v) { return (int)(v * getResources().getDisplayMetrics().density + .5f); }
    private GradientDrawable bg(int c, int r) { GradientDrawable d=new GradientDrawable(); d.setColor(c); d.setCornerRadius(dp(r)); return d; }
    private TextView t(String s,float size,int c,boolean bold) { TextView v=new TextView(this); v.setText(s); v.setTextSize(size); v.setTextColor(c); if(bold)v.setTypeface(Typeface.DEFAULT,Typeface.BOLD); return v; }

    @Override protected void onCreate(Bundle b) { super.onCreate(b); build(); }

    private void build() {
        LinearLayout root=new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL); root.setBackgroundColor(BG);
        LinearLayout header=new LinearLayout(this); header.setGravity(Gravity.CENTER_VERTICAL); header.setPadding(dp(18),dp(16),dp(18),dp(16)); header.setBackgroundColor(NAVY);
        LinearLayout titles=new LinearLayout(this); titles.setOrientation(LinearLayout.VERTICAL); titles.addView(t("LUMIRA AI OFFICE",21,Color.WHITE,true)); titles.addView(t("ChatGPT-led development workspace",12,Color.rgb(205,216,235),false));
        header.addView(titles,new LinearLayout.LayoutParams(0,-2,1));
        TextView live=t("● AI READY",11,Color.rgb(114,220,178),true); live.setGravity(Gravity.CENTER); header.addView(live,new LinearLayout.LayoutParams(dp(90),dp(44))); root.addView(header);

        ScrollView scroll=new ScrollView(this); LinearLayout content=new LinearLayout(this); content.setOrientation(LinearLayout.VERTICAL); content.setPadding(dp(16),dp(18),dp(16),dp(24)); scroll.addView(content); root.addView(scroll,new LinearLayout.LayoutParams(-1,0,1));
        content.addView(t("MAIN WORKFLOW",11,MUTED,true)); content.addView(t("Your AI development office",27,INK,true),margin(0,4,0,16));

        LinearLayout command=card(); command.addView(t("🧠  ChatGPT / OpenAI",19,INK,true)); command.addView(t("Main AI brain • planning • coding • analysis",13,MUTED,false),margin(0,5,0,0)); command.setOnClickListener(v->startActivity(new android.content.Intent(this,ChatActivity.class))); content.addView(command,margin(0,0,0,10));
        content.addView(module("⌘  GitHub","Source code • commits • pull requests • Actions","Connected workflow",Color.rgb(239,240,246)),margin(0,0,0,10));
        content.addView(module("⚙  Build & Test","GitHub Actions • APK build • test status","Automation",Color.rgb(235,247,244)),margin(0,0,0,10));
        content.addView(module("☁  Render","Backend • API • deployment","Server",Color.rgb(242,240,255)),margin(0,0,0,10));

        LinearLayout flow=card(); flow.addView(t("WORKFLOW",11,MUTED,true)); flow.addView(t("You → ChatGPT → GitHub → Actions → Render → LUMIRA",14,INK,true),margin(0,8,0,2)); flow.addView(t("Production-impacting changes should require your approval.",12,MUTED,false)); content.addView(flow,margin(0,8,0,0));
        setContentView(root);
    }
    private LinearLayout card(){ LinearLayout c=new LinearLayout(this); c.setOrientation(LinearLayout.VERTICAL); c.setPadding(dp(17),dp(16),dp(17),dp(16)); c.setBackground(bg(Color.WHITE,20)); c.setElevation(dp(2)); return c; }
    private LinearLayout module(String title,String sub,String status,int fill){ LinearLayout c=card(); TextView h=t(title,18,INK,true); c.addView(h); c.addView(t(sub,13,MUTED,false),margin(0,5,0,8)); TextView s=t("●  "+status,11,PURPLE,true); s.setPadding(dp(10),dp(6),dp(10),dp(6)); s.setBackground(bg(fill,14)); c.addView(s); return c; }
    private LinearLayout.LayoutParams margin(int l,int t,int r,int b){ LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2); p.setMargins(dp(l),dp(t),dp(r),dp(b)); return p; }
}
