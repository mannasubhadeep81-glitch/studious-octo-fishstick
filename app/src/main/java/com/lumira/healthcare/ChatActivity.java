package com.lumira.healthcare;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.content.Context;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import org.json.JSONObject;

public class ChatActivity extends Activity {
    private static final int NAVY = Color.rgb(24,39,70);
    private static final int PURPLE = Color.rgb(92,79,214);
    private static final int BG = Color.rgb(247,248,252);
    private static final int INK = Color.rgb(22,37,66);
    private static final int MUTED = Color.rgb(112,123,147);
    private final Handler main = new Handler(Looper.getMainLooper());
    private LinearLayout messages;
    private EditText input;
    private Button send;

    private int dp(int v){ return (int)(v * getResources().getDisplayMetrics().density + .5f); }
    private GradientDrawable bg(int color, int radius){ GradientDrawable d=new GradientDrawable(); d.setColor(color); d.setCornerRadius(dp(radius)); return d; }
    private TextView text(String s,float size,int color,boolean bold){ TextView t=new TextView(this); t.setText(s); t.setTextSize(size); t.setTextColor(color); if(bold)t.setTypeface(Typeface.DEFAULT,Typeface.BOLD); return t; }

    @Override protected void onCreate(Bundle b){
        super.onCreate(b);
        build();
    }

    private void build(){
        LinearLayout root=new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(BG);

        LinearLayout header=new LinearLayout(this);
        header.setGravity(Gravity.CENTER_VERTICAL);
        header.setPadding(dp(18),dp(14),dp(18),dp(14));
        header.setBackgroundColor(NAVY);
        TextView back=text("‹",34,Color.WHITE,false);
        back.setGravity(Gravity.CENTER);
        back.setOnClickListener(v->finish());
        header.addView(back,new LinearLayout.LayoutParams(dp(45),dp(48)));
        LinearLayout title=new LinearLayout(this); title.setOrientation(LinearLayout.VERTICAL);
        title.addView(text("LUMIRA AI",20,Color.WHITE,true));
        title.addView(text("Healthcare assistant • Secure backend",11,Color.rgb(205,216,235),false));
        header.addView(title,new LinearLayout.LayoutParams(0,-2,1));
        TextView status=text("● LIVE",11,Color.rgb(114,220,178),true); status.setGravity(Gravity.CENTER);
        header.addView(status,new LinearLayout.LayoutParams(dp(60),dp(44)));
        root.addView(header);

        ScrollView scroll=new ScrollView(this);
        messages=new LinearLayout(this); messages.setOrientation(LinearLayout.VERTICAL);
        messages.setPadding(dp(16),dp(18),dp(16),dp(18));
        scroll.addView(messages);
        root.addView(scroll,new LinearLayout.LayoutParams(-1,0,1));

        addMessage("LUMIRA AI", "Hello. I’m connected to the LUMIRA Render backend. How can I help you?", false);

        LinearLayout composer=new LinearLayout(this);
        composer.setGravity(Gravity.CENTER_VERTICAL);
        composer.setPadding(dp(10),dp(10),dp(10),dp(10));
        composer.setBackgroundColor(Color.WHITE);
        input=new EditText(this);
        input.setHint("Ask LUMIRA anything...");
        input.setTextSize(15);
        input.setTextColor(INK);
        input.setHintTextColor(MUTED);
        input.setSingleLine(false);
        input.setMaxLines(4);
        input.setPadding(dp(14),dp(8),dp(14),dp(8));
        input.setBackground(bg(Color.rgb(243,244,249),18));
        composer.addView(input,new LinearLayout.LayoutParams(0,dp(54),1));
        send=new Button(this);
        send.setText("Send");
        send.setTextColor(Color.WHITE);
        send.setTextSize(14);
        send.setAllCaps(false);
        send.setBackground(bg(PURPLE,18));
        send.setOnClickListener(v->sendMessage());
        LinearLayout.LayoutParams sp=new LinearLayout.LayoutParams(dp(86),dp(54)); sp.setMargins(dp(8),0,0,0);
        composer.addView(send,sp);
        root.addView(composer);
        setContentView(root);
    }

    private void sendMessage(){
        String message=input.getText().toString().trim();
        if(message.isEmpty()) return;
        addMessage("YOU",message,true);
        input.setText("");
        send.setEnabled(false);
        send.setText("...");
        addMessage("LUMIRA AI","Thinking…",false);
        ApiClient.chat(message,new ApiClient.Callback(){
            @Override public void onSuccess(String response){
                main.post(()->{
                    removeLastMessage();
                    try{
                        JSONObject json=new JSONObject(response);
                        String output=json.optString("output","");
                        if(output.isEmpty()) output="The backend returned an empty response.";
                        addMessage("LUMIRA AI",output,false);
                    }catch(Exception e){ addMessage("LUMIRA AI",response,false); }
                    finishSend();
                });
            }
            @Override public void onError(String error){
                main.post(()->{
                    removeLastMessage();
                    addMessage("LUMIRA AI","Connection error: " + error,false);
                    finishSend();
                });
            }
        });
    }

    private void finishSend(){ send.setEnabled(true); send.setText("Send"); }

    private void addMessage(String who,String body,boolean mine){
        LinearLayout box=new LinearLayout(this); box.setOrientation(LinearLayout.VERTICAL);
        box.setPadding(dp(14),dp(11),dp(14),dp(11));
        box.setBackground(bg(mine?Color.rgb(231,228,255):Color.WHITE,18));
        TextView w=text(who,10,mine?PURPLE:MUTED,true);
        TextView b=text(body,15,INK,false); b.setLineSpacing(0,1.08f);
        box.addView(w); box.addView(b,new LinearLayout.LayoutParams(-1,-2));
        LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2); p.setMargins(mine?dp(45):dp(0),dp(5),mine?dp(0):dp(45),dp(5));
        messages.addView(box,p);
    }

    private void removeLastMessage(){ if(messages.getChildCount()>0) messages.removeViewAt(messages.getChildCount()-1); }
}
