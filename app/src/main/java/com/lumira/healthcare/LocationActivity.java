package com.lumira.healthcare;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

public class LocationActivity extends Activity {
    private static final int REQUEST_LOCATION = 7001;
    private static final int NAVY=Color.rgb(24,39,70), INK=Color.rgb(22,37,66), PURPLE=Color.rgb(92,79,214), CORAL=Color.rgb(255,112,102), BG=Color.rgb(247,248,252), MUTED=Color.rgb(112,123,147);
    private TextView status;
    private LocationManager locationManager;

    private int dp(int v){return (int)(v*getResources().getDisplayMetrics().density+.5f);}
    private GradientDrawable bg(int c,int r){GradientDrawable d=new GradientDrawable();d.setColor(c);d.setCornerRadius(dp(r));return d;}
    private TextView text(String s,float z,int c,boolean b){TextView v=new TextView(this);v.setText(s);v.setTextSize(z);v.setTextColor(c);if(b)v.setTypeface(Typeface.DEFAULT,Typeface.BOLD);return v;}
    private LinearLayout.LayoutParams lp(int l,int t,int r,int b){LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2);p.setMargins(dp(l),dp(t),dp(r),dp(b));return p;}

    @Override public void onCreate(Bundle b){
        super.onCreate(b);
        locationManager=(LocationManager)getSystemService(LOCATION_SERVICE);
        LinearLayout screen=new LinearLayout(this);screen.setOrientation(LinearLayout.VERTICAL);screen.setBackgroundColor(BG);
        ScrollView scroll=new ScrollView(this);LinearLayout root=new LinearLayout(this);root.setOrientation(LinearLayout.VERTICAL);root.setPadding(dp(18),dp(14),dp(18),dp(30));scroll.addView(root);screen.addView(scroll,new LinearLayout.LayoutParams(-1,0,1));
        TextView back=text("‹   Back to LUMIRA",16,PURPLE,true);back.setPadding(0,dp(8),0,dp(12));back.setOnClickListener(v->finish());root.addView(back);
        LinearLayout hero=new LinearLayout(this);hero.setOrientation(LinearLayout.VERTICAL);hero.setPadding(dp(22),dp(22),dp(22),dp(22));hero.setBackground(bg(NAVY,28));
        hero.addView(text("LUMIRA CARE",11,Color.rgb(175,190,220),true));
        hero.addView(text("Share your location",28,Color.WHITE,true),lp(0,10,0,6));
        hero.addView(text("Allow location access to find your current position and open it safely in Google Maps.",14,Color.rgb(220,228,242),false));root.addView(hero);
        status=text("Location permission is required.",14,INK,true);status.setPadding(dp(18),dp(18),dp(18),dp(18));status.setBackground(bg(Color.WHITE,20));root.addView(status,lp(0,18,0,10));
        TextView share=text("Allow location & find me",16,Color.WHITE,true);share.setGravity(Gravity.CENTER);share.setPadding(0,dp(16),0,dp(16));share.setBackground(bg(CORAL,18));share.setOnClickListener(v->requestOrGetFreshLocation());root.addView(share,lp(0,6,0,10));
        TextView maps=text("Open Google Maps",15,PURPLE,true);maps.setGravity(Gravity.CENTER);maps.setPadding(0,dp(14),0,dp(14));maps.setBackground(bg(Color.rgb(242,240,255),18));maps.setOnClickListener(v->openMapsFromLastLocation());root.addView(maps,lp(0,0,0,10));
        root.addView(text("Privacy-first: LUMIRA requests location only when you choose to share it.",12,MUTED,false),lp(4,8,4,0));
        setContentView(screen);
    }

    private boolean hasLocationPermission(){
        return android.os.Build.VERSION.SDK_INT<23 || checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)==PackageManager.PERMISSION_GRANTED || checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION)==PackageManager.PERMISSION_GRANTED;
    }

    private void requestOrGetFreshLocation(){
        if(!hasLocationPermission()){
            if(android.os.Build.VERSION.SDK_INT>=23) requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION,Manifest.permission.ACCESS_COARSE_LOCATION},REQUEST_LOCATION);
            return;
        }
        getFreshLocation();
    }

    @Override public void onRequestPermissionsResult(int requestCode,String[] permissions,int[] grantResults){
        super.onRequestPermissionsResult(requestCode,permissions,grantResults);
        if(requestCode==REQUEST_LOCATION){
            boolean ok=false; for(int g:grantResults) if(g==PackageManager.PERMISSION_GRANTED) ok=true;
            if(ok){status.setText("Permission granted. Finding your current location…");getFreshLocation();}
            else{status.setText("Location permission was not granted. Enable it in Android Settings.");Toast.makeText(this,"Location permission is needed to share your position.",Toast.LENGTH_LONG).show();}
        }
    }

    private void getFreshLocation(){
        if(!hasLocationPermission()) return;
        try{
            boolean gps=locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
            boolean network=locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
            if(!gps && !network){
                status.setText("Location is turned off. Turn it on and try again.");
                try{startActivity(new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS));}catch(Exception ignored){}
                return;
            }
            status.setText("Finding your current GPS location…");
            final LocationListener listener=new LocationListener(){
                @Override public void onLocationChanged(Location location){
                    try{locationManager.removeUpdates(this);}catch(Exception ignored){}
                    showLocationOnMaps(location);
                }
                @Override public void onProviderDisabled(String provider){}
                @Override public void onProviderEnabled(String provider){}
                @Override public void onStatusChanged(String provider,int status,Bundle extras){}
            };
            if(gps) locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER,1000L,1f,listener);
            if(network) locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER,1000L,1f,listener);
            new android.os.Handler().postDelayed(()->{
                try{locationManager.removeUpdates(listener);}catch(Exception ignored){}
                openMapsFromLastLocation();
            },12000L);
        }catch(Exception e){
            status.setText("Could not access GPS. Please try again.");
        }
    }

    private void openMapsFromLastLocation(){
        if(!hasLocationPermission()) return;
        Location best=null;
        try{
            for(String provider:new String[]{LocationManager.GPS_PROVIDER,LocationManager.NETWORK_PROVIDER}){
                try{Location l=locationManager.getLastKnownLocation(provider);if(l!=null && (best==null || l.getTime()>best.getTime()))best=l;}catch(Exception ignored){}
            }
        }catch(Exception ignored){}
        if(best!=null) showLocationOnMaps(best);
        else status.setText("No recent location found. Tap ‘Allow location & find me’ to get a fresh position.");
    }

    private void showLocationOnMaps(Location location){
        double lat=location.getLatitude(),lon=location.getLongitude();
        status.setText(String.format(java.util.Locale.US,"Current location: %.6f, %.6f",lat,lon));
        Uri uri=Uri.parse("geo:"+lat+","+lon+"?q="+lat+","+lon+"(LUMIRA%20Location)");
        Intent i=new Intent(Intent.ACTION_VIEW,uri);i.setPackage("com.google.android.apps.maps");
        try{startActivity(i);}catch(Exception e){
            Intent web=new Intent(Intent.ACTION_VIEW,Uri.parse("https://www.google.com/maps/search/?api=1&query="+lat+","+lon));
            startActivity(web);
        }
    }

    @Override protected void onDestroy(){
        super.onDestroy();
        try{locationManager.removeUpdates(new LocationListener(){@Override public void onLocationChanged(Location location){} @Override public void onProviderDisabled(String provider){} @Override public void onProviderEnabled(String provider){} @Override public void onStatusChanged(String provider,int status,Bundle extras){}});}catch(Exception ignored){}
    }
}
