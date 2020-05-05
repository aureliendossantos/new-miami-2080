pico-8 cartridge // http://www.pico-8.com
version 24
__lua__
--miami 2080
--nev / foxfiesta

function _init()
 --state
 _upd=update_shop
 _drw=draw_shop
 
 init_database()
 
 ❎_released=false
 offset=0
 t=0
 menu_index=1
 choice=1
 
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
 _upd()
end

function _draw()
 _drw()
end

-->8
--scene shop
function update_shop()
 if btnp(⬆️) then
  menu_index=max(1,menu_index-1)
 end
 if btnp(⬇️) then
  menu_index=min(4,menu_index+1)
 end
 for i=1,3 do
  if menu_index==i then
   if btnp(⬅️) then
    choice = max(1,choice-1)
   end
   if btnp(➡️) then
    choice = min(2,choice+1)
   end
  end
 end
 if btnp(❎) then
  for i=1,3 do
   if menu_index==i then
    eqp[i]=choice
    sfx(1)
   end
  end
  if menu_index==4 then
	  init_shmup()
	  _upd=update_shmup
	  _drw=draw_shmup
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
 --ships
 draw_items(ship,1,36)
 draw_items(weapon,2,54)
 draw_items(secondary,3,72)
end

function draw_items(array,eqp_slot,y)
 for i,c in pairs(array) do
  local x=19+14*(i-1)
  draw_item(x,y,3)
  if menu_index==eqp_slot and 
  choice==i then
   draw_item(x,y,11)
  end
  if eqp[eqp_slot]==i then
   draw_item(x,y,9)
  end
  if menu_index==eqp_slot and 
  choice==i and
  eqp[eqp_slot]==i then
   draw_item(x,y,10)
  end
  spr(c.anim[1],x+2,y+2)
 end
end

function draw_item(x,y,col)
 rectfill(x,y,x+12,y+15,col)
end

-->8
--scene shmup
function init_shmup()
 music(3)
 bullets={}
 e_bullets={}
 enemies={}
 explosions={}
 wave=1
 init_player()
end

function update_shmup()
 t+=1
 screen_shake()
	update_player()
	update_enemies()
	update_bullets()
	update_explosions()
	if #enemies==0 then
	 --spawn_enemies(3+flr(rnd(3)),enemy[flr(rnd(2))+1])
	 --spawn_enemies(2,enemy[2])
	 spawn_enemies(stage_1[wave][1],enemy[stage_1[wave][2]])
	 wave=min(#stage_1,wave+1)
	end
end

function draw_shmup()
	cls()
	draw_player()
	for e in all(enemies) do
		spr(animate(e.anim),e.x,e.y)
	end
	for b in all(bullets) do
		spr(animate(b.anim),b.x,b.y)
	end
	for e in all(explosions) do
		circ(e.x,e.y,e.t/2,8+e.t%3)
	end
	for b in all(e_bullets) do
		spr(4,b.x,b.y)
	end
	for i=1,p.life do
		spr(5,i*8,1)
	end
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
	  speed=1,
   life=3,
   anim={16,18,20}
  },
  {
   speed=1.5,
   life=4,
   price=2000,
   anim={32}
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
   speed=6,
   frequency=12,
   duration=15,
   damage=160,
   sfx=2,
   anim={5},
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
   anim={7},
   x1=1,y1=2,
   w=4,h=4
  },
  {
   speed=3,
   frequency=6,
   duration=15,
   damage=300,
   sfx=2,
   anim={7},
   x1=1,y1=2,
   w=4,h=4
  }
 }
 --enemies
 enemy={
  {
   --little guy
	  life=400,
	  frequency=40,
   anim={3},
   movement=function (e)
    if (e.move_t<60) e.move_t+=1
 	  e.y=elastic_in_out(e.move_t,-10,30,60)
   end,
   
   pattern=function (e)
    local a = angle_to(e.x,e.y,p.x+p.x1-2,p.y+p.y1-2)
    enemy_shoot(e.x,e.y,a,1.6)
   end
  },
  {
   --medium guy
	  life=800,
	  frequency=4,
   anim={6},
   movement=function (e)
    if (e.move_t<60) e.move_t+=1
 	  e.y=elastic_in_out(e.move_t,-10,30,60)
   end,
   
   base=0.25,
   
   pattern=function (e)
    e.pattern_t+=0.1
    --e.base+=0.001
    if flr(e.pattern_t)%3~=0 then
     local var=0.06+sin(e.pattern_t)/50
     enemy_shoot(e.x,e.y,e.base+var,1.5)
     enemy_shoot(e.x,e.y,e.base-var,1.5)
    end
   end
  }
 }
 --stages
 stage_1={
   {3,1},
   {1,2},
   {4,1},
   {3,2}
 }
end
-->8
--player

function init_player()
	p={x=60,
  y=80,
  x1=7,y1=9,
  w=1,h=2,
  speed=ship[eqp[1]].speed,
  life=ship[eqp[1]].life,
  invincible=false,
  inv_t=0,
  wep1_t=0,
  wep1_t_max=weapon[eqp[2]].frequency,
  wep2_t=0,
  wep2_t_max=secondary[eqp[3]].frequency,  
  anim=ship[eqp[1]].anim
 }
end

function update_player()
 --movement
 local ix,iy=0,0
 if (btn(⬅️)) ix-=1
	if (btn(➡️)) ix+=1
	if (btn(⬆️)) iy-=1
	if (btn(⬇️)) iy+=1
	if ix~=0 and iy~=0 then
	 ix*=0.9
	 iy*=0.9
	else
	 p.x,p.y=flr(p.x),flr(p.y)
	end
	--avance sans bords de l'ecran
	p.x=mid(-6,p.x+ix*p.speed,118)
	p.y=mid(-8,p.y+iy*p.speed,115)
	--weapon1
	p.wep1_t+=1
	if btn(❎) and p.wep1_t>=p.wep1_t_max then
	 shoot(weapon[eqp[2]],-2,2)
	 shoot(weapon[eqp[2]],10,2)
	 p.wep1_t=0
	end
	--weapon2
	p.wep2_t+=1
	if btn(🅾️) and p.wep2_t>=p.wep2_t_max then
	 shoot(secondary[eqp[3]],4,-2)
	 p.wep2_t=0
	end
	--collision
	for b in all(e_bullets) do
		if collision(b,p) and
		 not p.invincible then
			p.life-=1
			p.invincible=true
			explode(b.x+4,b.y+8)
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
end

function draw_player()
 if p.inv_t%3==0 then
 	spr(animate(p.anim),p.x,p.y,2,3)
 end
end
-->8
--enemies

function spawn_enemies(n,type)
 gap=(98-n*8)/(n-1)
 for i=1,n do
 	add(enemies,{
	  x=15+8*(i-1)+gap*(i-1),
	  y=-8,
	  x1=0,y1=0,
	  w=7,h=7,
	  life=type.life,
	  move_t=0,
	  shoot_t=0,
	  shoot_t_max=type.frequency,
	  a=type.a,
	  anim=type.anim,
	  movement=type.movement,
	  pattern=type.pattern,
	  pattern_t=0,
	  base=type.base
	 })
 end
end

function update_enemies()
 for e in all(enemies) do
  --avance
 	e.movement(e)
	 --collision
 	for b in all(bullets) do
 		if collision(e,b) then
 		 e.life-=b.damage
 		 explode(b.x+4,b.y)
 			del(bullets,b)
 			sfx(1)
			end
		end
		--mort
		if e.life<=0 then
			del(enemies,e)
		end
		--tir
		if e.shoot_t==e.shoot_t_max then
		 e.pattern(e)
		 e.shoot_t=0
		else
		 e.shoot_t+=1
		end
 end
end

function enemy_shoot(x,y,a,spd)
	add(e_bullets,{
	 x=x,
	 y=y,
	 dx=cos(a),
  dy=-sin(a),
  speed=spd,
  x1=3,
  y1=3,
  w=2,
  h=2
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
__gfx__
00000000006006000000000000200200000000000111111000e00e00000000000000000000000000000000000000000000000000000000000000000000000000
0000000000600600000000000282282000000000166776610e2ee2e0000000000000000000000000000000000000000000000000000000000000000000000000
0070070000600600000cc000288888820008800016677761e222222e000880000000000000000000000000000000000000000000000000000000000000000000
0007700006dc7d6000c77c00288568820087780017667771e225622e008a98000000000000000000000000000000000000000000000000000000000000000000
0007700006dccd6000c77c000285582000877800177776710e2552e0008aa8000000000000000000000000000000000000000000000000000000000000000000
00700700d66dd66d000cc00000288200000880000177661000e22e00008880000000000000000000000000000000000000000000000000000000000000000000
00000000d666666d00000000000220000000000000166100000ee000000800000000000000000000000000000000000000000000000000000000000000000000
00000000050dd0500000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001100000000000000110000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000015d100000000000015d100000000000015d100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000015510000000000001551000000000000155100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000151151000000000015115100000000001511510000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000116711000000000011671100000000001167110000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00500166771005000050016677100500005001667710050000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100167771001000010016777100100001001677710010000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101661177101000010166117710100001016611771010000000000000000000000000000000000000000000000000000000000000000000000000000000000
05117611117611500511761111761150051176111176115000000000000000000000000000000000000000000000000000000000000000000000000000000000
0117761cc16661100117761cc1666110011776188166611000000000000000000000000000000000000000000000000000000000000000000000000000000000
01777618816666100177761cc16666100177761cc166661000000000000000000000000000000000000000000000000000000000000000000000000000000000
1677661cc167767116776618816776711677661cc167767100000000000000000000000000000000000000000000000000000000000000000000000000000000
16776611117766611677661111776661167766111177666100000000000000000000000000000000000000000000000000000000000000000000000000000000
16766711117776611676671111777661167667111177766100000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111100111111111111110011111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

