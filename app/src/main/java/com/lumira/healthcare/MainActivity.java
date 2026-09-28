package com.lumira.healthcare;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public class MainActivity extends Activity {
    private static final int NAVY = Color.rgb(25, 40, 72);
    private static final int INK = Color.rgb(24, 39, 68);
    private static final int PURPLE = Color.rgb(91, 78, 214);
    private static final int CORAL = Color.rgb(255, 112, 102);
    private static final int BG = Color.rgb(247, 248, 252);
    private static final int CARD = Color.WHITE;
    private LinearLayout content;
    private UserProfile user;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        user = new SessionManager(this).getUser();
        showHome();
    }

    private int dp(int value) {
        return (int) (value * getResources().getDisplayMetrics().density + 0.5f);
    }

    private GradientDrawable bg(int color, int radius) {
        GradientDrawable d = new GradientDrawable();
        d.setColor(color);
        d.setCornerRadius(dp(radius));
        return d;
    }

    private TextView label(String value, float size, int color, boolean bold) {
        TextView t = new TextView(this);
        t.setText(value);
        t.setTextSize(size);
        t.setTextColor(color);
        if (bold) t.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        return t;
    }

    private LinearLayout card() {
        LinearLayout c = new LinearLayout(this);
        c.setOrientation(LinearLayout.VERTICAL);
        c.setPadding(dp(18), dp(16), dp(18), dp(16));
        c.setBackground(bg(CARD, 20));
        c.setElevation(dp(2));
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(-1, -2);
        p.setMargins(0, dp(7), 0, dp(7));
        c.setLayoutParams(p);
        return c;
    }

    private TextView pill(String text) {
        TextView p = label(text, 13, Color.rgb(40, 130, 105), true);
        p.setGravity(Gravity.CENTER);
        p.setPadding(dp(12), dp(7), dp(12), dp(7));
        p.setBackground(bg(Color.rgb(226, 247, 239), 18));
        return p;
    }

    private void showHome() {
        content = baseContent();

        String name = user.getName().isEmpty() ? "there" : user.getName();
        TextView date = label("YOUR CARE  •  TODAY", 12, Color.rgb(108, 119, 145), true);
        content.addView(date, lp(0, 4, 0, 0));
        TextView hello = label("Good morning, " + name, 28, INK, true);
        content.addView(hello, lp(0, 5, 0, 12));

        LinearLayout location = card();
        location.setOrientation(LinearLayout.HORIZONTAL);
        TextView locIcon = label("⌖", 25, PURPLE, false);
        location.addView(locIcon, new LinearLayout.LayoutParams(dp(38), dp(38)));
        LinearLayout locText = new LinearLayout(this);
        locText.setOrientation(LinearLayout.VERTICAL);
        locText.addView(label("Share your live location", 16, INK, true));
        locText.addView(label("Find the nearest available care", 13, Color.GRAY, false));
        location.addView(locText, new LinearLayout.LayoutParams(0, -2, 1));
        TextView arrow = label("›", 28, Color.GRAY, false);
        location.addView(arrow);
        location.setOnClickListener(v -> toast("Location sharing will be connected in the next backend step."));
        content.addView(location);

        LinearLayout hero = new LinearLayout(this);
        hero.setOrientation(LinearLayout.VERTICAL);
        hero.setPadding(dp(22), dp(22), dp(22), dp(20));
        hero.setBackground(bg(NAVY, 26));
        hero.setElevation(dp(3));
        TextView heroTitle = label("Need medical help now?", 24, Color.WHITE, true);
        hero.addView(heroTitle);
        hero.addView(label("A verified doctor can reach you at home in minutes.", 15, Color.rgb(220, 228, 242), false), lp(0, 7, 0, 14));
        TextView emergency = label("Request emergency doctor", 16, Color.WHITE, true);
        emergency.setGravity(Gravity.CENTER);
        emergency.setPadding(0, dp(15), 0, dp(15));
        emergency.setBackground(bg(CORAL, 18));
        emergency.setOnClickListener(v -> openFeature("Emergency"));
        hero.addView(emergency);
        TextView ambulance = label("🚑  Request an ambulance instead", 14, Color.rgb(255, 184, 178), true);
        ambulance.setPadding(0, dp(14), 0, 0);
        ambulance.setOnClickListener(v -> openFeature("Emergency"));
        hero.addView(ambulance);
        LinearLayout.LayoutParams hp = new LinearLayout.LayoutParams(-1, -2);
        hp.setMargins(0, dp(12), 0, dp(10));
        content.addView(hero, hp);

        content.addView(label("How can we help?", 23, INK, true), lp(0, 8, 0, 7));
        LinearLayout row1 = new LinearLayout(this);
        row1.setOrientation(LinearLayout.HORIZONTAL);
        row1.addView(serviceCard("♙", "Home visit", "Care at your doorstep", "Home Healthcare"), weightLp(0.5f, 8));
        row1.addView(serviceCard("▣", "Medicines", "Order from pharmacy", "Pharmacy"), weightLp(0.5f, 0));
        content.addView(row1);
        LinearLayout row2 = new LinearLayout(this);
        row2.setOrientation(LinearLayout.HORIZONTAL);
        row2.addView(serviceCard("🚑", "Ambulance", "Emergency transport", "Emergency"), weightLp(0.5f, 8));
        row2.addView(serviceCard("▤", "Records", "Your health history", "Records"), weightLp(0.5f, 0));
        content.addView(row2);

        LinearLayout visit = card();
        LinearLayout visitTop = new LinearLayout(this);
        visitTop.setOrientation(LinearLayout.HORIZONTAL);
        visitTop.addView(label("UPCOMING VISIT", 12, Color.rgb(106, 119, 146), true), new LinearLayout.LayoutParams(0, -2, 1));
        visitTop.addView(pill("● Confirmed"));
        visit.addView(visitTop);
        visit.addView(label("Tomorrow • 10:30 AM", 20, INK, true), lp(0, 7, 0, 7));
        visit.addView(label("Dr. Maya Shah", 16, INK, true));
        visit.addView(label("General Physician  •  Video consultation", 13, Color.GRAY, false));
        visit.setOnClickListener(v -> openFeature("Appointments"));
        content.addView(visit, lp(0, 10, 0, 8));

        LinearLayout trust = new LinearLayout(this);
        trust.setGravity(Gravity.CENTER_VERTICAL);
        trust.setPadding(dp(8), dp(12), dp(8), dp(14));
        trust.addView(label("◇", 20, Color.rgb(53, 150, 120), true));
        trust.addView(label("  Verified providers • Privacy-first care", 13, Color.GRAY, false));
        content.addView(trust);

        addBottomNav("Home");
        setContentView(content.getParent() instanceof View ? (View) content.getParent() : content);
    }

    private LinearLayout baseContent() {
        LinearLayout outer = new LinearLayout(this);
        outer.setOrientation(LinearLayout.VERTICAL);
        outer.setBackgroundColor(BG);

        ScrollView scroll = new ScrollView(this);
        scroll.setFillViewport(true);
        content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(dp(18), dp(18), dp(18), dp(90));
        scroll.addView(content);
        outer.addView(scroll, new LinearLayout.LayoutParams(-1, 0, 1));
        return outer;
    }

    private void addBottomNav(String selected) {
        LinearLayout nav = new LinearLayout(this);
        nav.setOrientation(LinearLayout.HORIZONTAL);
        nav.setGravity(Gravity.CENTER);
        nav.setPadding(dp(5), dp(7), dp(5), dp(7));
        nav.setBackground(bg(Color.WHITE, 0));
        String[] items = {"⌂\nHome", "♧\nActivity", "▤\nRecords", "♙\nProfile"};
        String[] keys = {"Home", "Activity", "Records", "Profile"};
        for (int i = 0; i < items.length; i++) {
            final String key = keys[i];
            TextView item = label(items[i], 13, key.equals(selected) ? PURPLE : Color.rgb(120, 128, 145), key.equals(selected));
            item.setGravity(Gravity.CENTER);
            item.setPadding(0, dp(5), 0, dp(5));
            item.setOnClickListener(v -> {
                if ("Home".equals(key)) showHome();
                else if ("Activity".equals(key)) showActivity();
                else if ("Records".equals(key)) showRecords();
                else showProfile();
            });
            nav.addView(item, new LinearLayout.LayoutParams(0, dp(58), 1));
        }
        ((LinearLayout) content.getParent().getParent()).addView(nav, new LinearLayout.LayoutParams(-1, dp(70)));
    }

    private TextView serviceCard(String icon, String title, String subtitle, String feature) {
        LinearLayout box = new LinearLayout(this);
        box.setOrientation(LinearLayout.VERTICAL);
        box.setPadding(dp(15), dp(15), dp(12), dp(14));
        box.setBackground(bg(Color.WHITE, 20));
        box.setElevation(dp(1));
        TextView i = label(icon, 22, PURPLE, true);
        i.setGravity(Gravity.CENTER);
        i.setBackground(bg(Color.rgb(242, 240, 255), 15));
        box.addView(i, new LinearLayout.LayoutParams(dp(42), dp(42)));
        box.addView(label(title, 16, INK, true), lp(0, 12, 0, 2));
        box.addView(label(subtitle, 11, Color.GRAY, false));
        box.setOnClickListener(v -> openFeature(feature));
        return wrapAsView(box);
    }

    private TextView wrapAsView(LinearLayout layout) {
        TextView proxy = new TextView(this);
        proxy.setText("");
        proxy.setVisibility(View.GONE);
        layout.setTag(proxy);
        // Return a TextView is not suitable for two-column content, so the actual layout is exposed via a helper cast.
        return proxy;
    }

    private LinearLayout.LayoutParams lp(int l, int t, int r, int b) {
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(-1, -2);
        p.setMargins(dp(l), dp(t), dp(r), dp(b));
        return p;
    }

    private LinearLayout.LayoutParams weightLp(float weight, int right) {
        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(0, -2, weight);
        p.setMargins(0, 0, dp(right), 0);
        return p;
    }

    private void showActivity() {
        content = baseContent();
        content.addView(label("YOUR CARE", 12, Color.GRAY, true));
        content.addView(label("Activity", 30, INK, true), lp(0, 5, 0, 14));
        LinearLayout upcoming = card();
        upcoming.addView(label("UPCOMING", 12, Color.GRAY, true));
        upcoming.addView(label("Dr. Maya Shah", 18, INK, true), lp(0, 7, 0, 2));
        upcoming.addView(label("General Physician  •  Tomorrow at 10:30 AM", 13, Color.GRAY, false));
        upcoming.setOnClickListener(v -> openFeature("Appointments"));
        content.addView(upcoming);
        LinearLayout orders = card();
        orders.setGravity(Gravity.CENTER);
        orders.addView(label("▣", 30, PURPLE, false));
        orders.addView(label("Medicine orders", 18, INK, true), lp(0, 7, 0, 2));
        orders.addView(label("Your orders will appear here", 14, Color.GRAY, false));
        content.addView(orders);
        content.addView(label("Need help?", 19, INK, true), lp(0, 18, 0, 5));
        content.addView(label("Our care team is available 24/7", 14, Color.GRAY, false));
        addBottomNav("Activity");
        setContentView(content.getParent() instanceof View ? (View) content.getParent() : content);
    }

    private void showRecords() {
        content = baseContent();
        content.addView(label("YOUR HEALTH", 12, Color.GRAY, true));
        content.addView(label("Records", 30, INK, true), lp(0, 5, 0, 14));
        LinearLayout health = card();
        health.addView(label("♡  Health overview", 18, INK, true));
        health.addView(label("Last updated after your home visit", 13, Color.GRAY, false), lp(0, 5, 0, 0));
        content.addView(health);
        content.addView(label("Prescriptions", 20, INK, true), lp(0, 18, 0, 5));
        LinearLayout rx = card();
        rx.addView(label("▤  Dr. Maya Shah", 17, INK, true));
        rx.addView(label("Paracetamol • Cetirizine • Jun 12, 2026", 13, Color.GRAY, false));
        content.addView(rx);
        content.addView(label("Past visits", 20, INK, true), lp(0, 18, 0, 5));
        content.addView(recordCard("Dr. Rohan Mehta", "Internal Medicine • May 28, 2026"));
        content.addView(recordCard("Dr. Maya Shah", "General Physician • Jun 12, 2026"));
        LinearLayout privacy = card();
        privacy.addView(label("🔒  Your records are private", 15, PURPLE, true));
        privacy.addView(label("Only you and the care team you approve can access them.", 12, Color.GRAY, false));
        content.addView(privacy, lp(0, 10, 0, 0));
        addBottomNav("Records");
        setContentView(content.getParent() instanceof View ? (View) content.getParent() : content);
    }

    private LinearLayout recordCard(String name, String detail) {
        LinearLayout c = card();
        c.addView(label("♙  " + name, 16, INK, true));
        c.addView(label(detail, 13, Color.GRAY, false));
        return c;
    }

    private void showProfile() {
        content = baseContent();
        content.addView(label("ACCOUNT", 12, Color.GRAY, true));
        content.addView(label("Profile", 30, INK, true), lp(0, 5, 0, 14));
        LinearLayout identity = new LinearLayout(this);
        identity.setOrientation(LinearLayout.VERTICAL);
        identity.setPadding(dp(20), dp(20), dp(20), dp(20));
        identity.setBackground(bg(NAVY, 24));
        String name = user.getName().isEmpty() ? "LUMIRA User" : user.getName();
        identity.addView(label(name, 22, Color.WHITE, true));
        identity.addView(label(user.getEmail().isEmpty() ? user.getPhone() : user.getEmail(), 13, Color.rgb(214, 222, 238), false), lp(0, 5, 0, 5));
        identity.addView(label("✓ Verified account", 12, Color.rgb(114, 220, 178), true));
        content.addView(identity);
        content.addView(label("Switch workspace", 20, INK, true), lp(0, 20, 0, 5));
        String[] roles = {"♡  Patient", "♙  Doctor", "▣  Pharmacy", "🚑  Ambulance", "⚙  Admin"};
        for (String role : roles) {
            LinearLayout r = card();
            r.setOrientation(LinearLayout.HORIZONTAL);
            r.addView(label(role, 16, INK, true), new LinearLayout.LayoutParams(0, -2, 1));
            r.addView(label("›", 24, Color.GRAY, false));
            content.addView(r);
        }
        TextView logout = label("Sign out", 16, Color.rgb(210, 70, 70), true);
        logout.setGravity(Gravity.CENTER);
        logout.setPadding(0, dp(15), 0, dp(15));
        logout.setOnClickListener(v -> { new SessionManager(this).logout(); finish(); });
        content.addView(logout, lp(0, 15, 0, 0));
        addBottomNav("Profile");
        setContentView(content.getParent() instanceof View ? (View) content.getParent() : content);
    }

    private void openFeature(String title) {
        if ("Records".equals(title)) { showRecords(); return; }
        Intent intent = new Intent(this, FeatureActivity.class);
        intent.putExtra("title", title);
        startActivity(intent);
    }

    private void toast(String message) {
        android.widget.Toast.makeText(this, message, android.widget.Toast.LENGTH_SHORT).show();
    }
}
