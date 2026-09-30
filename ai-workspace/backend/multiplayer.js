import { WebSocketServer } from 'ws';

const rooms = new Map();
const MAX_PLAYERS = 4;
const clean = v => String(v || '').replace(/[^a-zA-Z0-9_-]/g,'').slice(0,48);
export function attachMultiplayer(server){
  const wss = new WebSocketServer({ server, path:'/ws/racing' });
  wss.on('connection',(ws)=>{
    let roomId=null, playerId=null, name='PLAYER';
    const send=o=>{if(ws.readyState===1)ws.send(JSON.stringify(o))};
    ws.on('message',raw=>{
      try{
        const m=JSON.parse(raw.toString());
        if(m.type==='join'){
          roomId=clean(m.roomId||''); playerId=clean(m.playerId||''); name=String(m.name||'PLAYER').slice(0,24);
          if(!roomId||!playerId)return send({type:'error',message:'roomId and playerId required'});
          let room=rooms.get(roomId); if(!room){room={players:new Map(),started:false};rooms.set(roomId,room)}
          if(room.players.size>=MAX_PLAYERS&&!room.players.has(playerId))return send({type:'error',message:'Room is full'});
          room.players.set(playerId,{ws,name,x:0,y:0,ready:false});
          send({type:'joined',roomId,playerId,players:[...room.players].map(([id,p])=>({id,name:p.name,ready:p.ready}))});
          broadcast(room,{type:'players',players:[...room.players].map(([id,p])=>({id,name:p.name,ready:p.ready}))});
        } else if(m.type==='ready'&&roomId&&playerId){const room=rooms.get(roomId);const p=room?.players.get(playerId);if(p){p.ready=!!m.ready;broadcast(room,{type:'players',players:[...room.players].map(([id,q])=>({id,name:q.name,ready:q.ready}))});if(room.players.size>=2&&[...room.players.values()].every(q=>q.ready)){room.started=true;broadcast(room,{type:'start',at:Date.now()+1500})}}}
        else if(m.type==='state'&&roomId&&playerId){const room=rooms.get(roomId);const p=room?.players.get(playerId);if(p){p.x=Number(m.x)||0;p.y=Number(m.y)||0;p.lap=Number(m.lap)||1;broadcast(room,{type:'state',id:playerId,x:p.x,y:p.y,lap:p.lap},ws)}}
        else if(m.type==='finish'&&roomId&&playerId){const room=rooms.get(roomId);if(room)broadcast(room,{type:'finish',id:playerId,score:Number(m.score)||0})}
      }catch{send({type:'error',message:'Invalid multiplayer message'})}
    });
    ws.on('close',()=>{if(roomId){const room=rooms.get(roomId);if(room){room.players.delete(playerId);broadcast(room,{type:'players',players:[...room.players].map(([id,p])=>({id,name:p.name,ready:p.ready}))});if(!room.players.size)rooms.delete(roomId)}}});
  });
  return wss;
}
function broadcast(room,msg,except=null){const data=JSON.stringify(msg);for(const p of room.players.values())if(p.ws!==except&&p.ws.readyState===1)p.ws.send(data)}
