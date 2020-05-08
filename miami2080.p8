pico-8 cartridge // http://www.pico-8.com
version 26
__lua__
--miami 2080
--surveillance brigade operations

function _init()
 first_time_map=true
 cur_threats={}
 stage=1
 --particles
 dust,dust_front={},{}
 dust_col={5,9,9,10}
 --glitch effect
 glit = {}
 glit.t=0

 --state
 _upd=update_map
 _drw=draw_map
 init_map()
 
 init_database()
 dtb_init()
 
 offset=0
 t=0
 money=10000
 money_printed=10000
 
 --temp angle
 a=0
end

--scene gameover
function update_gameover()
 if ❎_released and btn(❎) then
 	_init()
 end
end

function draw_gameover()
 cls()
 print("game over",20,40,8)
 print("press ❎ to continue",20,50,9)
end

--core functions
function _update60()
 update_input()
 dtb_update()
 _upd()
 --this must be at the end
 update_released()
end

function _draw()
 _drw()
 dtb_draw()
end

function draw_money()
 if money_printed<money-15 then
  money_printed+=15
	 print_money(10)
 elseif money_printed<money then
  money_printed+=1
	 print_money(10)
 elseif money_printed>money+55 then
  money_printed-=55
	 print_money(8)
 elseif money_printed>money then
  money_printed-=1
	 print_money(8)
 else
  print_money(9)
 end
end

function print_money(col)
	print("$"..money_printed,100,1,col)
end

--input manager
function update_input()
 if not text_mode then
  btn⬅️,btn➡️,btn⬆️,btn⬇️,btn❎,btn🅾️,btnp⬅️,btnp➡️,btnp⬆️,btnp⬇️,btnp❎,btnp🅾️=btn(⬅️),btn(➡️),btn(⬆️),btn(⬇️),btn(❎),btn(🅾️),btnp(⬅️),btnp(➡️),btnp(⬆️),btnp(⬇️),btnp(❎),btnp(🅾️)
 else
  --en texte, tout passer a nil
  btn⬅️,btn➡️,btn⬆️,btn⬇️,btn❎,btn🅾️,btnp⬅️,btnp➡️,btnp⬆️,btnp⬇️,btnp❎,btnp🅾️=false
 end
end

function update_released()
	if not btn(❎) then
  ❎_released=true
 else
  ❎_released=false
 end
 if not btn(🅾️) then
  🅾️_released=true
 else
  🅾️_released=false
 end
end
-->8
--scene shop

function init_shop()
	menu_index=1
 choice=1
	trans_t=-30
end

function update_shop()
 if btnp⬆️ then
  menu_index=max(1,menu_index-1)
 end
 if btnp⬇️ then
  menu_index=min(4,menu_index+1)
 end
 for i=1,3 do
  if menu_index==i then
   if btnp⬅️ then
    choice = max(1,choice-1)
   end
   if btnp➡️ then
    choice = min(3,choice+1)
   end
  end
 end
 local item={ship,weapon,secondary}
 if btnp🅾️ then
  if menu_index<=3 then
   for i in all(item[menu_index][choice].text) do
    dtb_disp(i)
   end
  end
 end
 if btnp❎ and ❎_released then
  if menu_index<=3 then
	  item=item[menu_index][choice]
   if item.price and not item.bought then
    if item.price<=money then
     money-=item.price
     item.bought=true
     eqp[menu_index]=choice
     --sfx(2)
    else
     sfx(0)
    end
   else
    eqp[menu_index]=choice
    sfx(1)
   end
  else
   dtb_disp("et c'est parti.",function()
	   init_shmup()
	   _upd=update_shmup
	   _drw=draw_shmup
   end)
	 end
	end
	trans_t+=1
end

function draw_shop()
 if trans_t<0 then
  cls(11)
 else
	 cls(3)
	end
 --big square
 if trans_t>15 then
  rect(10,20,118,95,11)
 end
 if trans_t>17 then
  rectfill(11,21,117,94,13)
 end
 --deploy
 if trans_t>13 then
	 local x,y=14,99
	 rectfill(x,y,x+36,y+12,11)
	 if menu_index==4 then
	  print("deploy",x+7,y+4,3)
	 else
	  rectfill(x,y,x+36,y+12,0)
	  print("deploy",x+7,y+4,11)
	 end
	end
 --items
 if trans_t>90 then
  draw_items(ship,1,38)
 end
 if trans_t>140 then
  draw_items(weapon,2,56)
 end
 if trans_t>143 then
  draw_items(secondary,3,74)
 end
 if trans_t>45 then
	 print("shop",20,26,5)
	 print("shop",21,26,5)
	 print("shop",20,25,6)
	 print("c:info",86,26,5)
	 print("c:info",87,26,5)
	 print("c:info",86,25,6)
 end
 if trans_t>13 then
  rectfill(11,11,40,16,0)
	 print("stage"..stage,12,12,11)
	 rectfill(89,11,117,16,0)
	 print("$"..money,90,12,11)
	end
	frame_borders()
end

function draw_items(array,eqp_slot,y)
 for i,c in pairs(array) do
  local x=18+22*(i-1)
  draw_item(x,y,13,3)
  if menu_index==eqp_slot and 
  choice==i then
   draw_item(x,y,11,3)
  end
  if eqp[eqp_slot]==i then
   draw_item(x,y,13,6)
  end
  if menu_index==eqp_slot and 
  choice==i and
  eqp[eqp_slot]==i then
   draw_item(x,y,11,6)
  end
  if eqp_slot==1 then
   spr(c.anim[1],x+2,y+1,2,2)
  else
   spr(c.anim[1],x+6,y+3)
  end
  if c.price and not c.bought then
   print(c.price,x+1,y+11,1)
   print(c.price,x+2,y+11,1)
   print(c.price,x+1,y+10,6)
  end
 end
end

function draw_item(x,y,col1,col2)
 if trans_t>94 then
  rect(x,y,x+19,y+16,col1)
 end
 rectfill(x+1,y+1,x+18,y+15,col2)
end

-->8
--scene shmup
function init_shmup()
 --music(3)
 bullets={}
 e_bullets={}
 enemies={}
 explosions={}
 wave=0
 notif_text=""
 notif_t=0
 init_player()
 money_printed=money
end

function update_shmup()
 t+=1
 screen_shake()
 update_player()
	update_enemies()
	update_bullets()
	update_explosions()
	wave_manager()
	for d in all(dust) do
  d:update()
 end
 for d in all(dust_front) do
  d:update()
 end
end

function wave_manager()
	if wave==0 then
	 update_stage_start()
	else
		local info=stages[stage][wave]
		--decrease wave timer
		if type(info[5])=="number" then
			info[5]-=1
		end
		--when timer=0 or no enemy
		if not text_mode and (info[5]==0 or #enemies==0) then
		 if type(info[1])=="function" then
			 info[1]()
		 elseif type(info[1])=="string" then
		  for t in all(info) do
		   dtb_disp(t)
		  end
		 else
		  spawn_enemies(info[1],enemy[info[2]],info[3],info[4])
		 end
		 --next wave
		 wave=min(#stages[stage],wave+1)
		 --wave+=1
		end
	end
end

function update_stage_start()
	notif_t+=1
	notif_text="day "..stage
	if p.y==80 then
	 wave=1
	else
		p.y=max(80,p.y-0.5)
	end
end

function draw_shmup()
	cls()
	for d in all(dust) do
  d:draw()
 end
	draw_player()
	spr(animate({64,65,66,67,68,69,70,71,72}),p.x+7,p.y+8)
	for e in all(enemies) do
		if e.canflip and e.x<60 then
		 spr(animate(e.anim),e.x,e.y,e.spr_w,e.spr_h,true)
		else
		 spr(animate(e.anim),e.x,e.y,e.spr_w,e.spr_h)
	 end
	end
	for b in all(bullets) do
		spr(animate(b.anim),b.x,b.y)
	end
	for d in all(dust_front) do
  d:draw()
 end
	for e in all(explosions) do
		circ(e.x,e.y,e.t/2,8+e.t%3)
	end
	for b in all(e_bullets) do
		spr(animate(b.anim),b.x,b.y)
		--rectfill(b.x+b.x1,b.y+b.y1,b.x+b.x1+b.w,b.y+b.y1+b.h)
	end
	--rectfill(p.x+p.x1,p.y+p.y1,p.x+p.x1+p.w,p.y+p.y1+p.h)
	for i=1,p.life do
		spr(80,i*8,1)
	end
	draw_money()
	draw_bosslife()
	draw_notif(notif_text,notif_t)
end

function draw_bosslife()
 for e in all(enemies) do
 	if e.boss then
 	 local col=1
 	 local w=6+e.life/enemy[5].life*119
 		line(5,1,125,1,col)
 		for i=1,3 do
 			local y=1+i
 			line(5-i,y,126-i,y,col)
 			line(6-i,y,w-i,y,8)
			end
			line(2,5,122,5,col)
		end
 end
end

--bullets + explosions

function shoot(bullet,x,y)
 local b={}
 --recopier la table originelle
 for j,k in pairs(bullet) do
  b[j] = k
 end
 b.x=p.x+x
 b.y=p.y+y
 add(bullets,b)
 sfx(bullet.sfx)
end

function update_bullets()
	for b in all(bullets) do
		b.y-=b.speed
		b.duration-=1
		if (b.duration==0) del(bullets,b)
	end
	for b in all(e_bullets) do
		b.y+=b.dy*b.speed
		b.x+=b.dx*b.speed
		if b.y>130 or b.y<-10
		or b.x>130 or b.x<-10 then
		 del(e_bullets,b)
	 end
	end
end

function explode(x,y)
 add(explosions,{
  x=x,
  y=y,
  t=0})
end

function update_explosions()
 for e in all(explosions) do
  e.t+=1
 	if (e.t==13) del(explosions,e)
 end
end
-->8
--database

function init_database()
 --stage,difficulty,target,proximity
	threats={
	 {2,"low",2,1},
	 {3,"medium",1,1},
	 {4,"high",1,2},
	 {5,"extreme",1,3}
	}
 --equipment chosen
 --ship, weapon, secondary
 eqp={1,1,1}
	--ships
	ship={
	 {
	  speed=1.2,
   life=3,
   anim={16},
   x1=7,y1=9,
   w=1,h=2,
   text={"si tu veux mon avis,","c'est pas avec ce rafiot que t'iras bien loin.","mais bon, quand y a pas de thune,","y a pas de thune."}
  },
  {
   speed=1.2,
   life=4,
   price=2090,
   anim={18},
   x1=7,y1=7,
   w=1,h=1
  },
  {
	  speed=1.2,
   life=5,
   price=9930,
   anim={16},
   x1=7,y1=9,
   w=1,h=2
  },
 }
 --weapons
 weapon={
  {
   speed=4,
   frequency=8,
   duration=35,
   damage=10,
   sfx=0,
   anim={31},
   x1=2,y1=2,
   w=3,h=3
  },
  {
   price=800,
   speed=3,
   frequency=8,
   duration=25,
   damage=15,
   sfx=13,
   anim={30},
   x1=0,y1=1,
   w=6,h=6
  },
  {
   price=5990,
   speed=3,
   frequency=8,
   duration=25,
   damage=20,
   sfx=13,
   anim={29},
   x1=1,y1=0,
   w=5,h=7
  }
 }
 --secondary
 secondary={
  {
   speed=3.5,
   frequency=12,
   duration=16,
   damage=20,
   sfx=13,
   anim={47},
   x1=2,y1=2,
   w=3,h=3
  },
  {
   price=6200,
   speed=4,
   frequency=20,
   duration=35,
   damage=60,
   sfx=13,
   anim={46},
   x1=2,y1=0,
   w=3,h=7
  },
  {
   price=14700,
   speed=3,
   frequency=6,
   duration=13,
   damage=30,
   sfx=13,
   anim={45},
   x1=0,y1=0,
   w=6,h=7
  }
 }
 --enemies
 enemy={
  {
   --little guy
	  life=60,
	  money=20,
   anim={1},
   spr_w=1,spr_h=1,
   x1=0,y1=0,w=7,h=7,
   emitters={
    {1,0,0}
   }
  },
  {
   --tunnel guy
	  life=140,
	  money=120,
   anim={4},
   spr_w=2,spr_h=1,
   x1=0,y1=0,w=15,h=7,
   emitters={
    {3,0,2},
    {4,8,2},
    {1,4,0}
   }
  },
  {
   --wheel guy
	  life=180,
	  money=120,
   anim={2},
   spr_w=1,spr_h=1,
   x1=0,y1=0,w=7,h=7,
   emitters={
    {5,0,0}
   }
  },
  {
   --big vertical laser guy
	  life=240,
	  y_goal=20,
	  money=140,
   anim={6},
   spr_w=2,spr_h=3,
   x1=1,y1=3,w=14,h=22,
   emitters={
    {7,4,8}
   },
   reactors={
    {5,5},
    {11,5}
   }
  },
  {
   --horizontal laser guy
	  life=180,
	  following=true,
	  lifespan=280,
	  canflip=true,
	  money=140,
   anim={20},
   spr_w=2,spr_h=2,
   x1=0,y1=0,w=15,h=15,
   emitters={
    {8,4,4}
   },
   reactors={}
  },
  {
   --giga boss
   boss=true,
	  life=2000,
	  money=10000,
   anim={128},
   spr_w=16,spr_h=4,
   x1=0,y1=0,w=16*8,h=28,
   emitters={
    {1,50,22},
    {1,84,12},
    {6,96,6},
    {5,34,16}
   }
  },
  {
   --following tunnel guy
	  life=140,
	  money=120,
   anim={4},
   spr_w=2,spr_h=1,
   x1=0,y1=0,w=15,h=7,
   emitters={
    {9,0,2},
    {10,8,2}
   }
  },
 }
 --bullet emitters
 emitter={
  {
   --follow
   bullet=2,
   frequency=40,
   speed=1.6,
   repeats=1,
   angle=function (rpt,emt,e)
    return angle_to(e.x+emt[2],e.y+emt[3],p.x+p.x1-2,p.y+p.y1-2)
   end
  },
  {
   --straight down
   bullet=1,
   frequency=40,
   speed=1.6,
   repeats=1,
   angle=function ()
    return 0.25
   end
  },
  {
   --wave tunnel side1
   bullet=2,
   frequency=4,
   speed=1.5,
   repeats=1,
   angle=function (rpt,emt)
    emt.pattern_t+=0.1
    if flr(emt.pattern_t)%4~=2 then
	    return 0.25+0.06+sin(emt.pattern_t)/50
	   end
   end
  },
  {
   --wave tunnel side2
   bullet=2,
   frequency=4,
   speed=1.5,
   repeats=1,
   angle=function (rpt,emt)
    emt.pattern_t+=0.1
    if flr(emt.pattern_t)%4~=2 then
	    return 0.25-(0.06+sin(emt.pattern_t)/50)
	   end
   end
  },
  {
   --wheel large gap
   bullet=1,
   frequency=8,
   speed=1.3,
   repeats=4,
   angle=function (rpt,emt)
    emt.pattern_t+=0.01
	   return emt.pattern_t+0.25*rpt
   end
  },
  {
   --wheel tight
   bullet=1,
   frequency=4,
   speed=1.3,
   repeats=4,
   angle=function (rpt,emt)
    emt.pattern_t+=0.0075
	   return emt.pattern_t+0.25*rpt
   end
  },
  {
   --straight laser
   bullet=4,
   frequency=1,
   speed=3,
   repeats=1,
   angle=function (rpt,emt)
    emt.pattern_t+=0.1
    if flr(emt.pattern_t)%10>=3 then
	    return 0.25
	   end
   end
  },
  {
   --horizontal laser
   bullet=5,
   frequency=1,
   speed=3,
   repeats=1,
   angle=function (rpt,emt,e)
    emt.pattern_t+=0.1
    if flr(emt.pattern_t)%10>=4 and emt.pattern_t<20 then
	    if e.x<64 then
		    return 0
		   else
		    return 0.5
		   end
	   end
   end
  },
  {
   --wave tunnel follow side1
   bullet=2,
   frequency=4,
   speed=1.5,
   repeats=1,
   angle=function (rpt,emt,e)
    if flr(emt.pattern_t)%4==0 then
     --reprend pos. joueur
     e.base_a=angle_to(e.x+emt[2],e.y+emt[3],p.x+p.x1-2,p.y+p.y1-2)
    end
    emt.pattern_t+=0.1
    if flr(emt.pattern_t)%4~=0 then
	    return e.base_a+0.04+sin(emt.pattern_t)/50
	   end
   end
  },
  {
   --wave tunnel follow side2
   bullet=2,
   frequency=4,
   speed=1.5,
   repeats=1,
   angle=function (rpt,emt,e)
    emt.pattern_t+=0.1
    if flr(emt.pattern_t)%4~=0 then
	    return e.base_a-(0.04-sin(emt.pattern_t)/50)
	   end
   end
  }
 }
 bullet={
  {
   anim={15},
   x1=3,y1=3,
   w=1,h=1
  },
  {
   anim={14},
   x1=2,y1=2,
   w=3,h=3
  },
  {
   anim={13},
   x1=1,y1=1,
   w=5,h=5
  },
  {
   anim={12},
   x1=0,y1=0,
   w=7,h=5
  },
  {
   anim={11},
   x1=0,y1=0,
   w=5,h=7
  }
 }
 --wave arguments:
 --enemy amount,enemy type,
 --wave width,behaviour,
 --time until this wave
 --(none=wait until 0 enemy)
 stages={
  {
   --1-introduction
   {"alors, la petite jeune.","premiere mission sur le terrain ?","tu verras, ceux-la sont un peu lents.","ca devrait bien se passer.","oublie pas de leur tirer dessus quand meme.","c'est ❎. voili voilou."},
   {1,1,30,1},
   {1,1,-20,1},
   {3,1,80,1},
   {"pas mal.","enfin, y a pas de quoi etre fier non plus,","mais c'est pas mal.","y en a d'autres qui arrivent.","plein de petits points rouges."},
   {2,1,60,2},
   {4,1,100,3,6},
   {2,1,80,1,6},
   {1,1,8,1,6},
   {"ah ben, je vois deja plus personne.","c'etait du bon travail.","alors euh, bienvenue dans la brigade.","tu peux rentrer, il faut que tu dises bonjour au colonel."},
   {function()
	   _upd=update_map
	   _drw=draw_map
	   init_map()
   end}
  },
  {
   --{1,4,-40,4},
   --{1,1,80,2,1},
   --{1,1,-80,3,1},
   --{function()
	   --_upd=update_shop
	   --_drw=draw_shop
   --end},
   --{1,3,40,1},
   --{1,2,0,1},
   {1,7,60,1},
   {1,5,128,5},
   {1,5,-96,5},
   {1,2,30,1},
   {1,1,98,2,1},
   {1,1,-98,3,20},
   {1,2,-30,2},
   {4,1,60,2},
   {2,2,70,2},
   {3,2,98,2}
  },
  {
   {1,6,128,4}
  }
 }
end
-->8
--player

function init_player()
 p={}
 --recopier le ship originel
 for j,k in pairs(ship[eqp[1]]) do
  p[j] = k
 end
	p.x,p.y=56,158
 p.invincible=false
 p.inv_t=0
 p.wep1_t=0
 p.wep1_t_max=weapon[eqp[2]].frequency
 p.wep2_t=0
 p.wep2_t_max=secondary[eqp[3]].frequency
end

function update_player()
 --movement
 local ix,iy,speed=0,0,1
 if (btn⬅️) ix-=1
	if (btn➡️) ix+=1
	if (btn⬆️) iy-=1
	if (btn⬇️) iy+=1
	if ix~=0 and iy~=0 and btn🅾️ then
	 ix*=0.8
	 iy*=0.8
	 speed=p.speed*0.6
	elseif btn🅾️ then
		speed=p.speed*0.6
	else
	 speed=p.speed
	 --p.x,p.y=flr(p.x),flr(p.y)
	end
	--avance sans bords de l'ecran
	if wave~=0 then
	 p.x=mid(-6,p.x+ix*speed,118)
	 p.y=mid(-8,p.y+iy*speed,115)
	end
	--weapons
	p.wep1_t+=1
	p.wep2_t+=1
	if btn🅾️ then
	 if p.wep2_t>=p.wep2_t_max then
	  shoot(secondary[eqp[3]],4,-2)
	  p.wep2_t=0
	 end
	elseif btn❎ and p.wep1_t>=p.wep1_t_max then
	 shoot(weapon[eqp[2]],-2,2)
	 shoot(weapon[eqp[2]],10,2)
	 p.wep1_t=0
	end
	--collision
	for b in all(e_bullets) do
		if collision(b,p) and
		 not p.invincible then
			p.life-=1
			p.invincible=true
			explode(b.x+4,b.y+4)
			del(e_bullets,b)
			offset=0.15
			sfx(1)
		end
	end
	if p.life<=0 then
	 _upd=update_gameover
  _drw=draw_gameover
	end
	if p.invincible and p.inv_t<60 then
	 p.inv_t+=1
	else
	 p.inv_t=0
	 p.invincible=false
	end
 player_dust(8,14)
end

function player_dust(x,y)
	add_new_dust(p.x+x,p.y+y,rnd(0.3)-0.15,-(rnd(1)-1),7,3,0.1,dust_col)
end


function draw_player()
 if p.inv_t%3==0 then
 	spr(animate(p.anim),p.x,p.y,2,2)
 end
end
-->8
--enemies

function spawn_enemies(amount,enemy,width,behaviour)
 gap=(width-amount*8)/(amount-1)
 for i=1,amount do
  local e={}
  --recopier la table originelle
  for j,k in pairs(enemy) do
   e[j] = k
  end
  --movements
  if behaviour==1 then
   --coming from above
   e.x=flr((128-width)/2)+8*(i-1)+gap*(i-1)
	  e.x_change=0
	  e.y=-10
	  e.y_change=30
	  e.move_duration=60
	 elseif behaviour==2 then
	  --coming from the left
	  e.x=-80+i*20
	  e.x_change=flr((128-width)/2)+8*(i-1)+gap*(i-1)-e.x
	  e.y=10
	  e.y_change=20
	  e.move_duration=150+rnd(40)
	 elseif behaviour==3 then
	  --coming from the right
	  e.x=208-i*20
	  e.x_change=flr((128-width)/2)+8*(i-1)+gap*(i-1)-e.x
	  e.y=10
	  e.y_change=20
	  e.move_duration=150+rnd(40)
	 elseif behaviour==4 then
	  --slow entrance
	  e.x=flr((128-width)/2)+8*(i-1)+gap*(i-1)
	  e.x_change=0
	  e.y=-32
	  if (not e.y_goal) e.y_goal=0
	 elseif behaviour==5 then
   --following from above
   e.x=flr((128-width)/2)+8*(i-1)+gap*(i-1)
	  e.x_change=0
	  e.y=-16
	  e.y_change=p.y+10
	  e.move_duration=200
	 end
	 e.start_x,e.start_y=e.x,e.y
	 --timers
	 e.move_t=0
	 for emt in all(e.emitters) do
	  emt.shoot_t=0
	  emt.pattern_t=0
	 end
	 add(enemies,e)
 end
end

function update_enemies()
 for e in all(enemies) do
  --avance
  if not e.ease_finished then
	  if e.move_duration then
	 	 if e.move_t<e.move_duration then
	 	  e.move_t+=1
	   else
	    e.ease_finished=true
	   end
	   e.y=elastic_in_out(e.move_t,e.start_y,e.y_change,e.move_duration)
		  e.x=elastic_in_out(e.move_t,e.start_x,e.x_change,e.move_duration)
		 else
		  e.y=min(e.y_goal,e.y+0.2)
		 end
		else
		 --mouvement ease termine
	  if e.following then
	   if e.y>p.y+4 then
	   	e.y-=0.2
	   elseif e.y<p.y+4 then
	    e.y+=0.2
    end
    e.lifespan-=1
    if e.lifespan==0 then
     e.ease_finished=false
     e.move_t=0
     e.start_y=e.y
     e.y_change=128
    end
    if (e.lifespan==-1) del(enemies,e)
	  end
		end
	 --collision
 	for b in all(bullets) do
 		if collision(e,b) then
 		 e.life-=b.damage
 		 for i=1,3 do
     add_new_dust(b.x+4,b.y,rnd(2)-1,rnd(1.5)-2,15,rnd(3)+1,0.1,dust_col,true)
 			end
 			del(bullets,b)
 			sfx(1)
			end
		end
		--mort
		if e.life<=0 then
		 money+=e.money
		 for i=1,(e.w+e.h)/2 do
		  add_new_dust(e.x+e.x1+rnd(e.w),e.y+e.y1+rnd(e.h),rnd(2)-1,rnd(2)-2.1,rnd(10)+((e.w+e.h)/2)*2.2,rnd(6)+2,0.05,dust_col)
   end
  del(enemies,e)
		end
		--tir
		if e.x>=0 and e.y>=0
		and e.x<=120 and e.y<=120 then
		 for emt in all(e.emitters) do
	  	local em=emitter[emt[1]]
			 if	emt.shoot_t==em.frequency then
			  for i=1,em.repeats do
			   local a=em.angle(i,emt,e)
			   if (a) enemy_shoot(e.x+emt[2],e.y+emt[3],a,em)
			  end
			  emt.shoot_t=0
			 else
			  emt.shoot_t+=1
			 end
			end
		end
		--particles
		if e.reactors then
		 for r in all(e.reactors) do
		  add_new_dust(e.x+r[1],e.y+r[2],rnd(0.3)-0.15,rnd(2)-1.5,7,rnd(2)+1,0.1,dust_col)
		 end
		else
		 add_new_dust(e.x+e.x1+e.w/2,e.y+e.y1,rnd(0.3)-0.15,rnd(2)-1.5,7,rnd(2)+1,0.1,dust_col)
  end
 end
end

function enemy_shoot(x,y,a,em)
	local b=bullet[em.bullet]
	add(e_bullets,{
	 x=x,y=y,
	 x1=b.x1,y1=b.y1,
	 w=b.w,h=b.h,
	 dx=cos(a),
  dy=-sin(a),
  speed=em.speed,
  anim=b.anim
	})
end
-->8
--scene map

function init_map()
	blink_t=0
	map_index=1
	trans_t=-30
end

function update_map()
	if btnp⬆️ then
	 map_index=max(1,map_index-1)
	 blink_t=0
	end
	if btnp⬇️ then
		map_index=min(#cur_threats,map_index+1)
	 blink_t=0
	end
	if btnp❎ then
	 stage=cur_threats[map_index]
	 _upd=update_shop
  _drw=draw_shop
  init_shop()
	end
	
	blink_t+=0.05
	
	if first_time_map and trans_t>110 then
	 local t={"ah c'est elle la nouvelle ?","bon, ben.","salut l'artiste !","bienvenue dans la brigade de surveillance de new miami.","alors comme ca on aime bien dezinguer des aliens ?","...","oui. bon. alors. la mission.","ca c'est l'ecran de controle de la zone a-1."}
	 for i in all(t) do
	 	dtb_disp(i)
  end
  dtb_disp("c'est nous. on s'occupe des trois tours de surveillance.",function() add(cur_threats,1) end)
	 local t={"les points rouges, c'est les aliens.","s'ils s'approchent, c'est chiant.","ca tire partout, y a du sang, faut refaire la peinture.","donc quand tu vois des points rouges","si tu pouvais aller tirer sur tout le monde","ce serait nickel.","eh ben, je crois qu'on a fait le tour.","bonne continuation."}
	 for i in all(t) do
	 	dtb_disp(i)
  end
  first_time_map=false
 end
 
 if trans_t==110 and not first_time_map then
  dtb_disp("une menace a ete supprimee, bien joue.",next_turn())
 end
 
 trans_t+=1
end

function next_turn()
 dtb_disp("ajouter qqch ici.")
end

function draw_map()
 if trans_t<0 then
  cls(11)
 else
	 cls(3)
	end
	if trans_t>30 and trans_t<40 then
	 circfill(120,120,64,11)
	end
	if trans_t>39 and trans_t<50 then
	 circfill(120,120,100,11)
	 circfill(120,120,64,3)
	end
	if trans_t>49 and trans_t<60 then
	 cls(11)
	 circfill(120,120,100,3)
	end
	if trans_t>39 then
		circ(120,120,64,11)
		circ(120,120,100)
		line(50,50,120,120)
		line(80,30,120,120)
		line(30,80,120,120)
	end
	
	--watchtowers
	if (trans_t>60) spr(48,58,90)
	if (trans_t>64) spr(48,72,70)
	if (trans_t>68) spr(48,90,57)
	
	if (trans_t>80 and trans_t<84) or trans_t>86 then
		local t="watchtowers"
		print(t,13,98,5)
		print(t,12,98,5)
		print(t,12,97,6)
	end
	
	if (trans_t>5 and trans_t<9) or trans_t>12 then
		--miami station
		local t="new miami\n  station"
		spr(192,89,89,4,4)
		print(t,53,108,5)
		print(t,52,108,5)
		print(t,52,107,6)
	end
	
	if trans_t>110 then
		local i=1
		for cur_t in all(cur_threats) do
		 --red circle
			local position={
			 --tower1
			 {{30,80},{43,85},{55,91}},
			 --tower2
			 {{50,50},{60,60},{70,70}},
			 --tower3
			 {{80,30},{86,43},{91,55}}
			}
			local t=threats[cur_t]
			local x=position[t[3]][t[4]][1]
			local y=position[t[3]][t[4]][2]
			circfill(x,y,2,8)
			
			--menus
			rectfill(11,3+8*i,40,8+8*i,0)
			
			if map_index==cur_t then
			 rectfill(11,3+8*i,40,8+8*i,5)
			 if flr(blink_t)%2==0 then
			  circfill(x,y,2,9)
			 end
			 local x=88
			 local y=11
				rectfill(x,y,x+28,y+23,0)
				print("danger:\n"..t[2].."\ntarget:\ntower"..t[3],x+1,y+1,11)
			end
			
			print("threat"..i,12,4+8*i,11)
			
			i+=1
		end
		--danger
		print(threats[1][2],50,1,6)

 end
 if trans_t>0 and trans_t<30 then
  glitch(0,0,128,128)
 end
 
 frame_borders()
end

function frame_borders()
	--frame corners
 spr(49,0,0)
 spr(49,120,0,1,1,true)
 spr(49,0,120,1,1,false,true)
 spr(49,120,120,1,1,true,true)
 --frame borders
 sspr(16,24,8,8,8,0,112,8)
 sspr(16,24,8,8,8,120,112,8,false,true)
 sspr(24,24,8,8,0,8,8,112)
 sspr(24,24,8,8,120,8,8,112,true)
end
-->8
--tools

function animate(ani)
 return ani[flr(t/8)%#ani+1]
 --8 : vitesse
end

function angle_to(x1,y1,x2,y2)
 return atan2(y2-y1,x2-x1)+0.25
end

function screen_shake()
 local fade = 0.95
 local offset_x=16-rnd(32)
 local offset_y=16-rnd(32)
 offset_x*=offset
 offset_y*=offset
 
 camera(offset_x,offset_y)
 offset*=fade
 if offset<0.05 then
  offset=0
 end
end

function collision(a,b)
 local ax,ay,bx,by=a.x+a.x1,a.y+a.y1,b.x+b.x1,b.y+b.y1
 return not (ax>bx+b.w
          or ay>by+b.h
          or ax+a.w<bx
          or ay+a.h<by)
end

function draw_notif(text,timer)
 local buffer=20
 local height=4
 local tmax=160
 if timer<22+buffer then
  d=timer-buffer
 else
  d=tmax-timer-buffer
 end
 if d>0 then
  h=min(height,(d-16)*0.75)
  if d<16 then
   line(0,64,d*4,64,8)
   line(127,64,127-d*4,64,8)
  else
   rectfill(0,64-h,127,64+h,8)
   rect(-1,64-h-2,128,64+h+2,7)
  end
  if h>=2 then
   x1=100-(timer*0.5)
   print(text,x1,62,7)
  end
 end
end

function elastic_in_out(t,b,c,d)
 t/=d
 local ts = t * t
 local tc = ts*t
 if t<0.3 then
  return b+c*(56*tc*ts + -105*ts*ts + 60*tc + -10*ts + 0*t)
 elseif t>0.7 then
  return b+c*(56*tc*ts + -175*ts*ts + 200*tc + -100*ts + 20*t)
 else
  lt=(t-0.3)/0.4   
  lc=0.98884*c       
  lb=b+lc*(0.00558)
  return lc * lt + lb
 end
end

--dialogue text box
function dtb_init()
 dtb_y=140
	dtb_queu={}
	dtb_queuf={}
	dtb_numlines=2
	_dtb_clean()
end

function dtb_disp(txt,callback)
	local lines,currline,curword,curchar={},"","",""
	local upt=function()
		if #curword+#currline>31 then
			add(lines,currline)
			currline=""
		end
		currline=currline..curword
		curword=""
	end
	for i=1,#txt do
		curchar=sub(txt,i,i)
		curword=curword..curchar
		if curchar==" " then
			upt()
		end
	end
	upt()
	if currline~="" then
		add(lines,currline)
	end
	add(dtb_queu,lines)
	if callback==nil then
		callback=0
	end
	add(dtb_queuf,callback)
end

function _dtb_clean()
	dtb_dislines={}
	for i=1,dtb_numlines do
		add(dtb_dislines,"")
	end
	dtb_curline=0
	dtb_ltime=0
end

function _dtb_nextline()
	dtb_curline+=1
	for i=1,#dtb_dislines-1 do
		dtb_dislines[i]=dtb_dislines[i+1]
	end
	dtb_dislines[#dtb_dislines]=""
end

function _dtb_nexttext()
	if dtb_queuf[1]~=0 then
		dtb_queuf[1]()
	end
	del(dtb_queuf,dtb_queuf[1])
	del(dtb_queu,dtb_queu[1])
	_dtb_clean()
	--sfx(2)
end

function dtb_update()
	if #dtb_queu>0 then
	 text_mode=true
	 dtb_y=max(121,dtb_y-2)
		if dtb_curline==0 then
			dtb_curline=1
		end
		local dislineslength=#dtb_dislines
		local curlines=dtb_queu[1]
		local curlinelength=#dtb_dislines[dislineslength]
		local complete=curlinelength>=#curlines[dtb_curline]
		if complete and dtb_curline>=#curlines then
			if (btnp(4) and 🅾️_released) or (btnp(5) and ❎_released) then
				_dtb_nexttext()
				return
			end
		elseif dtb_curline>0 then
			dtb_ltime-=1
			if not complete then
				if dtb_ltime<=0 then
					local curchari=curlinelength+1
					local curchar=sub(curlines[dtb_curline],curchari,curchari)
					dtb_ltime=1
					if curchar~=" " then
						sfx(0)
					end
					if curchar=="." then
						dtb_ltime=6
					end
					dtb_dislines[dislineslength]=dtb_dislines[dislineslength]..curchar
				end
			else
				_dtb_nextline()
			end
		end
	else
	 text_mode=false
	 dtb_y=min(140,dtb_y+2)
	end
end

function dtb_draw()
 rectfill(dtb_y*2-139,dtb_y-44,128,128,2)
 spr(77,dtb_y*2-138,dtb_y-43,3,4)
 rectfill(0,dtb_y-11,127,128,2)
 rectfill(0,dtb_y-10,127,128,0)
	if #dtb_queu>0 then
		local dislineslength=#dtb_dislines
		local offset=0
		if dtb_curline<dislineslength then
			offset=dislineslength-dtb_curline
		end
		for i=1,dislineslength do
			print(dtb_dislines[i],2,i*8+dtb_y-(dislineslength+offset)*8,7)
		end
	end
	glitch(dtb_y*2-138,dtb_y-43,24,32)
end

--glitch effect

function glitch(x,y,w,h)
 if g_on == true then -- on boolean is mangaged by the timer
  local t={6,11,3} -- three colors
  local c=flr(rnd(3))+1
  for i=0, 5, 4 do -- the outer loop generates the vertical glitch dots
   local height = rnd(h)
   for h=0, 100, 2 do -- the inner loop creates longer horizontal lines
    pset(x+rnd(w),y+height, t[c])
   end
  end
 end
 
 -- animation timeline that turns the static on and off
 if glit.t>30 and glit.t < 50 then
  g_on=true
 elseif glit.t>70 and glit.t < 80 then
  g_on=true
 elseif glit.t>120 then
  glit.t = 0
 else 
  g_on=false
 end
 glit.t+=1
end

--particle system
function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_f,front)
	local newd={
		fade=_f,
 	x=_x,
 	y=_y,
 	dx=_dx,
 	dy=_dy,
 	life=_l,
 	orig_life=_l,
 	rad=_s,
		col=0, --set to color
 	grav=_g,
 	draw=function(self)
 		--clear the palette
 		pal()
 		palt()
 		--draw the particle
 		circfill(self.x,self.y,self.rad,self.col)
 	end,
 	update=function(self)

 		self.x+=self.dx
 		self.y+=self.dy
 		self.dy+=self.grav
 		
 		--reduce the radius
 		--this is set to 90%, but
 		--could be altered
 		self.rad*=0.9
 		
 		self.life-=1
 		
 		if type(self.fade)=="table" then
		 	self.col=self.fade[flr(#self.fade*(self.life/self.orig_life))+1]
			else
				--just use a fixed color
				self.col=self.fade		 	
		 end
		 
	 	if self.life<0 then
			 del(dust,self)
			 del(dust_front,self)
 		end
 	end
 }
	if front then
	 add(dust_front, newd)
	else
	 add(dust, newd)
	end
end
__gfx__
000000000020020000e00e00000ee00000eeee0000eeee000000000000000000000000000000000000000000888888008e7777e800eeee000000000000000000
00000000028228200e2ee2e000e88e000e2222e00e2222e00000000000000000000000000000000000000000eeeeeee08e7777e80e7777e00008800000000000
0070070028888882e222222e0e8888e0e222222ee222222e0000000000000000000000000000000000000000777777778e7777e8e777777e0087780000088000
0007700028856882e225622e00e8658ee22222256222222e000eee0000eee000000eeee00eeee00000000000777777778e7777e8e777777e0877778000877800
00077000028558200e2552e000e8558e0ee2222552222ee000eeeee00eeeee0000e222e00e222e0000000000777777778e7777e8e777777e0877778000877800
007007000028820000e22e000e8888e000eee222222eee000e22222ee22222e00e22222ee22222e000000000777777778e7777e8e777777e0087780000088000
0000000000022000000ee00000e88e0000ee0eeeeee0ee00e22222222222222ee22222222222222e00000000eeeeeee00e7777e00e7777e00008800000000000
000000000000000000000000000ee0000000000000000000e22222222222222ee22222222222222e00000000888888000077770000eeee000000000000000000
000000011000000000000000000000000000000000eeeee0e22222256222222ee22222256222222e000000000000000000000000000cc0000000000000000000
00000015d1000000000000000000000000eeee000e22222ee22222255222222ee22222255222222e00000000000000000000000000c77c0000ccc00000000000
000000155100000000000000000000000e2222eee2222222e22222222222222ee22222222222222e0000000000000000000000000c7777c00c777c00000cc000
00000151151000000777000770007770e2222222222222220e222222222222e0e2e2222ee2222e2e0000000000000000000000000c7777c0c77777c000c77c00
00000116711000007666507665076665eeee22222222222200e2222ee2222e00ee0e22e00e22e0ee0000000000000000000000000cc77cc0c7ccc7c000c77c00
005001667710050076665766665766650000ee222222222200e222e00e222e00e00e22e00e22e00e00000000000000000000000000cccc00ccccccc0000cc000
00100167771001007666566116676665000000e22222222200e222e00e222e00000e22e00e22e00000000000000000000000000000cccc00cc000cc000000000
00101661177101007666561c716766650000000e256222220e222e0000e222e0000e22e00e22e000000000000000000000000000000cc000c00000c000000000
05117611117611507666561cc16766650000000e255222220e222e0000e222e0000e22e00e22e000000000000000000000000000008880000008800000000000
01177611116661107666561111676665000000e2222222220e22e000000e22e0000e22e00e22e000000000000000000000000000088988000089980000000000
017776111166661076665666666766650000ee22222222220e22e000000e22e0000e22e00e22e000000000000000000000000000889a9880008aa80000088000
16776611116776717777555555577776eeee2222222222220e22e000000e22e0000e22e00e22e00000000000000000000000000089aaa980008aa800008a9800
16776611117766617aaa55555557aaa5e2222222222222220e22e000000e22e0000e22e00e22e00000000000000000000000000089aaa98000899800008aa800
16766711117776617aaa50000007aaa50e2222eee22222220e22e000000e22e0000e22e00e22e00000000000000000000000000089aaa9800089980000888000
0111111111111110655550000006555500eeee000e22222e00e2e000000e2e000000e2e00e2e0000000000000000000000000000089a98000088880000080000
000000000000000000000000000000000000000000eeeee0000ee000000ee00000000ee00ee00000000000000000000000000000008880000008800000000000
000770006666666666666666666675d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007666006666666666666666666675d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007636006666666666666666666675d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
057636506666666666666666666675d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
507666056666666777777777666675d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
055555506666667555555555666675d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007636006666675ddddddddd666675d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000666675d000000000666675d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc0000007c000000770000008700000088000000880000007800000077000000c700000000000000ccccccccccccccccccccccccbbbbb3333333333333333333
cc000000cc0000007c00000077000000870000008800000088000000780000007700000000000000cccccccccccccc1111ccccccbbbb33333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc1111111cccccccccbbb333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1111cccccccccccccccbbb3333333bb333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1ccccccccccccccccccbbb33333bbbbb33333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1ccccccccccccccccccbb333bbbbbbbbb3333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1ccccccccccccccccccbb33bbbbbbbbbbb333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1ccccccccccccccccccbb3bbbbbbbbbbbbb33333333
01111110000000000000000000000000000000000000000000000000000000000000000000000000ccccc11cccccccccccccccccbb3bbb33333bbbb333333333
16677661000000000000000000000000000000000000000000000000000000000000000000000000cccccc111cccccccc11cccccbb3bb33bbb3bb33bb3333333
16677761000000000000000000000000000000000000000000000000000000000000000000000000ccccc111111111111111ccccbb3bb3bbbb3b33bbbb333333
17667771000000000000000000000000000000000000000000000000000000000000000000000000ccccc111111111111111c11cbb3bb3bbbb3b3bbbbb333333
17777671000000000000000000000000000000000000000000000000000000000000000000000000ccccc111111111111111c11cbb33bb3bbb3b33bbbb333333
01776610000000000000000000000000000000000000000000000000000000000000000000000000ccccc111111111111111cc1cbb33bb33333bb33b33333333
00166100000000000000000000000000000000000000000000000000000000000000000000000000ccccc111111111111111cc1cbb33bbb333bbb33333b33333
00011000000000000000000000000000000000000000000000000000000000000000000000000000ccccc11111111111111ccc1cbb33bbbbbbbbbbb33bb33333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1ccccc1cccccccccc1cbb33bbbb333333bbbbb33333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1cccc1ccccccccccc1cbb33bbbb3333b33bbbb33333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1cccc1ccccccccc111cbb333bbb33bbbb3bbbb33333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1cccc1ccccccccc1cccbb3b3bbb333bb33bbbb33333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1cccc111cccccccccccbb3b3bb33b3b3bbbbbb33333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1ccccccccccccccccccbb3333b3bbb33bbbbbb33333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1ccccccccccccccccccb33333b333bb3bbbbbb33333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc1ccccc1111ccccc1ccc33333333bb3b3bbbbb333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc1cc111cccccccc1ccc333333333bb33bbbbb333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc1cccccccccccc11ccc333333333333bbbbb3333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc11cccccccccc111ccc33333333bbb3bbbb33333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccc11cccccccc11c1ccc333333333b33bbbb33333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc11111111cccc1ccc3333333bbb3bbb3333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccc1cccccccc1ccc333333333b33b33333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccc11ccccccccc1cc33333333bbb3b33333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccc1ccccccccccccc3333333333b3333333333333
05566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665555555566666666666666666666666
00566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666556666666556666666666666666666665
00056666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665566666666656666666666666666666665
00056666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665666666666655666666666666666666665
00005666666666666666666666666666666665555666666666666666666666666666666666666666666666666666665666555556665666666666666666666665
00000566666666666666666666666666666555555556666666666666666666666666666666666666666666666666665665555556665666666666666666666650
00000566666666666666666666666666666555565556666666666666666666666666666666666666666666666666665665555556665566666666666666666650
00000056666666666666666666666666666555555556666666666666666666666666666666666666666666666666665665556556666566666666666666666500
00000056666666666666666666666666666555555556666666666666666666666666666555555666666666666666665666555556666566666666666666666500
00000055666666666666666666666666666565555556666666666666666666666666666555565566666666666666665566555556665566666666666666666500
00000000566666666666666666666666666555555566666666666666666666666666666555556566666666666666666556655566665666666666666666666500
00000000566666666666666666666666666665555666666666666666666666666666665555556566666666666666666655666666665666666666666666665000
00000000056666666666666666666666666665555666666666666666666666666666665555556566666666666666666665556666555666666666666666665000
00000000056666666666666666666666666665555666666666666666666666666666665555555566666666666666666666655555566666666666666666665000
00000000005666666666666666666666666665555666666666666666666666666666665555555666666666666666666666666666666666666666666666650000
00000000000566666666666666666666666665555666666666666666666666666666666555555666666666666666666666666666666666666666666666500000
00000000000566666666666666666666666665555666666666666666666666666666666665555666666666666666666666666666666666666666666666500000
00000000000055666666666666666666666665555666666666666666666666666666666665656666666666666666666666666666666666666666666665000000
00000000000005566666666666666666666665555666666666666666666666666666666665556666666666666666666666666666666666666666666650000000
00000000000000556666666666666666666666666666666666666666666666666666666665556666666666666666666666666666666666666666666550000000
00000000000000055666666666666666666666666666666666666666666666666666666665556666666666666666666666666666666666666666665500000000
00000000000000005566666666666666666666666666666666666666666666666666666665556666666666666666666666666666666666666666655000000000
00000000000000000055666666666666666666666666666666666666666666666666666665556666666666666666666666666666666666666665500000000000
00000000000000000005555666666666666666666666666666655555556666666666666665556666666666665555555666666666666666666655000000000000
00000000000000000000000555666666666666666666666666555555566666666666666666666666666666665555555666666666666666665550000000000000
00000000000000000000000005555666666666666666666666656555566666666666666666666666666666665555555666666666666655555000000000000000
00000000000000000000000000000555666666666666666666655555566666666666666666666666666666665555555666666665655550000000000000000000
00000000000000000000000000000000555666666666666666665555666666666666666666666666666666665555555555555555550000000000000000000000
00000000000000000000000000000000000555555555555555555555555566665555555555555555555555555555550000000000000000000000000000000000
00000000000000000000000000000000000000000000000000005555000055550000000000000000000000000555550000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000550000000000000000000000000000000000555550000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000550000000000000000000000000000000000555550000000000000000000000000000000000
00000000000000000000000000777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000007777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007777777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000777777777766666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000777777777766666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000077777777766666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000777777776666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777777666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777776666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777776666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077777766666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077777666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777776666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777776666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777766666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007777766666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777776666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777776666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777766666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777766666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777766666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77776666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77776666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77776666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77766666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000325302d5302853025520205201e520165101051007510215002750032500075000550004500035000350003500075000e500135000050000500005000050000500005000050000500005000050000500
000300002a620276201c62014620106100f6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000020734200351c7341c0351973419535157343952520734200351c7341c0351953219035147341503121734210351c7341c0261973419035237341703521734395251c7341c03519734195351773717035
011400000c043090552072409055246151972315555090550c053090651972309565207242461509065155650c053060652072406065246151672306065125650c05306065167230656520724246150606515555
011400000c053021651e7240206524615197450e7650c05302165020651e7341e7350256524615020650e56501165010651e7240c05324615167230b0450d0650c05301165197440b56520724246150106515555
0114000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242a74228742287451c7341e7421e7421e735237241702521724395251c7341c03519734195351773617035
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
010d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
010c00200c0530c235004303a324004453c3253c3240c0533c6150c0530044000440002353e5253e5250c1530c0530f244034451b323034453702437522370253c6153e5250334003440032351b3230c0531b323
010d00002072420710000002070000000200000000000000000001e00010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 02034344
00 02044344
01 06424344
00 07424344
00 08424344
00 06424344
00 06094344
00 07094344
00 080a4344
02 060b4344
00 0c424344

