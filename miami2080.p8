pico-8 cartridge // http://www.pico-8.com
version 24
__lua__
--miami 2080
--nev / foxfiesta

function _init()
 --particles
 dust,dust_front={},{}
 dust_col={5,9,9,10}
 --glitch effect
 glit = {}
 glit.height=32
 glit.width=24
 glit.t=0

 --state
 _upd=update_shop
 _drw=draw_shop
 
 init_database()
 dtb_init()
 
 offset=0
 t=0
 menu_index=1
 choice=1
 money=10000
 money_printed=10000
 
 --temp angle
 a=0
end

--scene gameover
function update_gameover()
 if not btn(❎) then
  ❎_released = true
 end
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
 end
end

-->8
--scene shop
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
    choice = min(2,choice+1)
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
 if btnp❎ then
  if menu_index<=3 then
	  item=item[menu_index][choice]
   if item.price and not item.bought then
    if item.price<=money then
     money-=item.price
     item.bought=true
     eqp[menu_index]=choice
     sfx(2)
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
end

function draw_shop()
 cls(1)
 --big square
 rectfill(10,18,118,110,9)
 rectfill(11,19,117,109,1)
 --deploy
 rectfill(44,90,83,104,9)
 if menu_index==4 then
  print("deploy",52,95,1)
 else
  rectfill(45,91,82,103,2)
  print("deploy",52,95,9)
 end
 --items
 draw_items(ship,1,36)
 draw_items(weapon,2,54)
 draw_items(secondary,3,72)
 --money
 print("🅾️ info",86,23,2)
 draw_money()
end

function draw_items(array,eqp_slot,y)
 for i,c in pairs(array) do
  local x=18+17*(i-1)
  draw_item(x,y,13,3)
  if menu_index==eqp_slot and 
  choice==i then
   draw_item(x,y,9,11)
  end
  if eqp[eqp_slot]==i then
   draw_item(x,y,13,9)
  end
  if menu_index==eqp_slot and 
  choice==i and
  eqp[eqp_slot]==i then
   draw_item(x,y,9,10)
  end
  if eqp_slot==1 then
   spr(c.anim[1],x,y,2,2)
  else
   spr(c.anim[1],x+4,y+3)
  end
  if c.price and not c.bought then
   print(c.price,x+1,y+11,1)
   print(c.price,x+2,y+11,1)
   print(c.price,x+1,y+10,6)
  end
 end
end

function draw_item(x,y,col1,col2)
 rectfill(x,y,x+15,y+16,col1)
 rectfill(x+1,y+1,x+14,y+15,col2)
end

-->8
--scene shmup
function init_shmup()
 music(3)
 bullets={}
 e_bullets={}
 enemies={}
 explosions={}
 stage=2
 wave=1
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
	for d in all(dust) do
  d:update()
 end
 for d in all(dust_front) do
  d:update()
 end
	
	local info=stages[stage][wave]
	if (info[5]) info[5]-=1
	if info[5]==0 or #enemies==0 then
	 spawn_enemies(info[1],enemy[info[2]],info[3],info[4])
	 wave=min(#stages[stage],wave+1)
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
		spr(animate(e.anim),e.x,e.y,e.spr_w,e.spr_h)
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
		spr(5,i*8,1)
	end
	draw_money()
end
-->8
--database

function init_database()
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
   price=2000,
   anim={22},
   x1=7,y1=7,
   w=1,h=1
  }
 }
 --weapons
 weapon={
  {
   speed=4,
   frequency=8,
   duration=35,
   damage=100,
   sfx=0,
   anim={2},
   x1=2,y1=0,
   w=3,h=4
  },
  {
   price=800,
   speed=6,
   frequency=12,
   duration=15,
   damage=160,
   sfx=2,
   anim={2},
   x1=1,y1=2,
   w=4,h=4
  }
 }
 --secondary
 secondary={
  {
   speed=4,
   frequency=8,
   duration=35,
   damage=200,
   sfx=0,
   anim={4},
   x1=1,y1=2,
   w=4,h=4
  },
  {
   speed=3,
   frequency=6,
   duration=15,
   damage=300,
   sfx=2,
   anim={4},
   x1=1,y1=2,
   w=4,h=4
  }
 }
 --enemies
 enemy={
  {
   --little guy
	  life=400,
	  money=20,
   anim={3},
   spr_w=1,spr_h=1,
   x1=0,y1=0,w=7,h=7,
   emitters={
    {1,0,0}
   }
  },
  {
   --tunnel guy
	  life=800,
	  money=120,
   anim={6},
   spr_w=1,spr_h=1,
   x1=0,y1=0,w=7,h=7,
   emitters={
    {3,-5,0},
    {4,5,0},
    {1,0,0}
   }
  },
  {
   --wheel guy
	  life=800,
	  money=120,
   anim={6},
   spr_w=1,spr_h=1,
   x1=0,y1=0,w=7,h=7,
   emitters={
    {5,0,0}
   }
  },
  {
   --laser guy
	  life=1500,
	  money=140,
   anim={6},
   spr_w=1,spr_h=1,
   x1=0,y1=0,w=7,h=7,
   emitters={
    {7,0,0}
   }
  },
  {
   --giga boss
	  life=10000,
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
  }
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
  }
 }
 --wave arguments:
 --enemy amount,enemy type,
 --wave width,behaviour,
 --time until this wave
 --(none=wait until 0 enemy)
 stages={
  {
   {1,4,40,1},
   {1,4,-40,1},
   {1,1,98,2,1},
   {1,1,-98,3,1},
   {1,3,40,1},
   {1,2,0,1},
   {1,2,30,1},
   {1,1,98,2,1},
   {1,1,-98,3,20},
   {1,2,-30,2},
   {4,1,60,2},
   {2,2,70,2},
   {3,2,98,2}
  },
  {
   {1,5,128,4}
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
	p.x,p.y=60,80
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
	if ix~=0 and iy~=0 and btn(🅾️) then
	 ix*=0.8
	 iy*=0.8
	 speed=p.speed*0.6
	elseif btn(🅾️) then
		speed=p.speed*0.6
	else
	 speed=p.speed
	 --p.x,p.y=flr(p.x),flr(p.y)
	end
	--avance sans bords de l'ecran
	p.x=mid(-6,p.x+ix*speed,118)
	p.y=mid(-8,p.y+iy*speed,115)
	--weapons
	p.wep1_t+=1
	p.wep2_t+=1
	if btn(🅾️) then
	 if p.wep2_t>=p.wep2_t_max then
	  shoot(secondary[eqp[3]],4,-2)
	  p.wep2_t=0
	 end
	elseif btn(❎) and p.wep1_t>=p.wep1_t_max then
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
	  e.x=0
	  e.x_change=0
	  e.y=-32
	  e.y_goal=0
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
  if e.move_duration then
 	 if (e.move_t<e.move_duration) e.move_t+=1
   e.y=elastic_in_out(e.move_t,e.start_y,e.y_change,e.move_duration)
	  e.x=elastic_in_out(e.move_t,e.start_x,e.x_change,e.move_duration)
	 else
	  e.y=min(e.y_goal,e.y+0.2)
	 end
	 --collision
 	for b in all(bullets) do
 		if collision(e,b) then
 		 e.life-=b.damage
 		 --explode(b.x+4,b.y)
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
		  add_new_dust(e.x+e.x1+rnd(e.w),e.y+e.y1+rnd(e.h),rnd(2)-1,rnd(2)-2.1,rnd(10)+20,rnd(6)+2,0.05,dust_col)
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
		add_new_dust(e.x+4,e.y,rnd(0.3)-0.15,rnd(2)-1.5,7,rnd(2)+1,0.1,dust_col)
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
		if (b.y>130) del(e_bullets,b)
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
	sfx(2)
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
			if btnp(4) or btnp(5) then
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
				if btnp(4) then
					dtb_dislines[dislineslength]=curlines[dtb_curline]
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
 rectfill(dtb_y*2-139,dtb_y-43,128,128,2)
 spr(77,dtb_y*2-138,dtb_y-42,3,4)
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
	glitch()
end

--glitch effect

function glitch()
 if g_on == true then -- on boolean is mangaged by the timer
  local t={6,11,3} -- three colors
  local c=flr(rnd(3))+1
  for i=0, 5, 4 do -- the outer loop generates the vertical glitch dots
   local gl_height = rnd(glit.height)
   for h=0, 100, 2 do -- the inner loop creates longer horizontal lines
    pset(dtb_y*2-138+rnd(glit.width),dtb_y-42+gl_height, t[c])
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
000000000020020000e00e00000ee00000000000000000000000000000000000000000000000000000000000000000008e7777e800eeee000000000000000000
00000000028228200e2ee2e000e88e0000000000000000000000000000000000000000000000000000000000000000008e7777e80e7777e00008800000000000
0070070028888882e222222e0e8888e000000000000000000000000000000000000000000000000000000000000000008e7777e8e777777e0087780000088000
0007700028856882e225622e00e8658e00000000000000000000000000000000000000000000000000000000000000008e7777e8e777777e0877778000877800
00077000028558200e2552e000e8558e00000000000000000000000000000000000000000000000000000000000000008e7777e8e777777e0877778000877800
007007000028820000e22e000e8888e000000000000000000000000000000000000000000000000000000000000000008e7777e8e777777e0087780000088000
0000000000022000000ee00000e88e0000000000000000000000000000000000000000000000000000000000000000000e7777e00e7777e00008800000000000
000000000000000000000000000ee00000000000000000000000000000000000000000000000000000000000000000000077770000eeee000000000000000000
00000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000015d10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc00000088000
000001511510000007770007700077700000000000000000000000000000000000000000000000000000000000000000000000000000000000c77c00008a9800
000001167110000076665076650766650000000000000000000000000000000000000000000000000000000000000000000000000000000000c77c00008aa800
0050016677100500766657666657666500000000000000000000000000000000000000000000000000000000000000000000000000000000000cc00000888000
00100167771001007666566116676665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000
00101661177101007666561c71676665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05117611117611507666561cc1676665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01177611116661107666561111676665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01777611116666107666566666676665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16776611116776717777555555577776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16776611117766617aaa55555557aaa5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
16766711117776617aaa50000007aaa5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111106555500000065555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

