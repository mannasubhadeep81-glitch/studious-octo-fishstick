package com.lumira.healthcare;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.TextView;

public class WorkspaceActivity extends Activity {
    private WebView webView;

    private int dp(int v){ return (int)(v * getResources().getDisplayMetrics().density + .5f); }
    private GradientDrawable bg(int color,int radius){ GradientDrawable d=new GradientDrawable(); d.setColor(color); d.setCornerRadius(dp(radius)); return d; }

    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FrameLayout root = new FrameLayout(this);
        webView = new WebView(this);
        webView.setWebViewClient(new WebViewClient());
        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setLoadWithOverviewMode(true);
        s.setUseWideViewPort(true);
        s.setBuiltInZoomControls(false);
        webView.setLayoutParams(new FrameLayout.LayoutParams(-1,-1));
        root.addView(webView);

        TextView ai = new TextView(this);
        ai.setText("✦  LUMIRA AI");
        ai.setTextSize(14);
        ai.setTextColor(Color.WHITE);
        ai.setTypeface(Typeface.DEFAULT,Typeface.BOLD);
        ai.setGravity(Gravity.CENTER);
        ai.setPadding(dp(18),0,dp(18),0);
        ai.setBackground(bg(Color.rgb(92,79,214),30));
        ai.setElevation(dp(8));
        ai.setOnClickListener(v -> startActivity(new Intent(this, ChatActivity.class)));
        FrameLayout.LayoutParams ap = new FrameLayout.LayoutParams(dp(150),dp(52),Gravity.BOTTOM|Gravity.END);
        ap.setMargins(0,0,dp(18),dp(24));
        root.addView(ai,ap);

        setContentView(root);
        webView.loadUrl("https://mannasubhadeep81-glitch.github.io/studious-octo-fishstick/ai-workspace/");
    }

    @Override public void onBackPressed() {
        if (webView.canGoBack()) webView.goBack(); else super.onBackPressed();
    }
}
