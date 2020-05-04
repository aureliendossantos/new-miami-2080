pico-8 cartridge // http://www.pico-8.com
version 22
__lua__
function _init()
 refresh()
end

function refresh()
	--delai btnp
 poke(0x5f5c, 4)
 --state
 _upd=update_shmup
 _drw=draw_shmup
 
 ❎_released=false
 t=0
 
 bullets={}
 e_bullets={}
 enemies={}
 explosions={}
 init_player()
end

function update_gameover()
 if not btn(❎) then
  ❎_released = true
 end
 if ❎_released and btn(❎) then
 	_init()
 end
end

function update_shmup()
 t+=1
	update_player()
	update_enemies()
	update_bullets()
	update_explosions()
	
	if #enemies==0 then
	 spawn_enemies(3+flr(rnd(3)))
	end
end

function _update60()
 _upd()
end

function draw_gameover()
 cls()
 print("game over",20,40,8)
 print("press ❎ to continue",20,50,9)
end

function draw_shmup()
	cls()
	draw_player()
	for e in all(enemies) do
		spr(3,e.x,e.y)
	end
	for b in all(bullets) do
		spr(2,b.x,b.y)
	end
	for e in all(explosions) do
		circ(e.x,e.y,e.t/2,8+e.t%3)
	end
	for b in all(e_bullets) do
		spr(4,b.x,b.y)
	end
	for i=1,p.life do
		--spr(5,i*8,1)
	end
	
	print(a,1,1)
	print(p.x,1,8)
	print(p.y,1,16)
end

function _draw()
 _drw()
end

function update_bullets()
	for b in all(bullets) do
		b.y-=b.speed
	end
	for b in all(e_bullets) do
		b.y+=b.dy
		b.x+=b.dx
	end
end

function collision(a,b)
 return not (a.x>b.x+8 
          or a.y>b.y+8 
          or a.x+8<b.x 
          or a.y+8<b.y)
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
--enemies

function spawn_enemies(n)
 gap=(98-n*8)/(n-1)
 for i=1,n do
 	add(enemies,{
	  x=15+8*(i-1)+gap*(i-1),
	  y=-8,
	  speed=0.5,
	  life=4,
	  move_t=0,
	  shoot_t=0
	 })
 end
end

function update_enemies()
 for e in all(enemies) do
  --avance
 	--if (e.y<30) e.y+=e.speed
 	if (e.move_t<60) e.move_t+=1
 	e.y=elastic_in_out(e.move_t,-10,30,60)
 	--collision
 	for b in all(bullets) do
 		if collision(e,b) then
 		 e.life-=1
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
		if e.shoot_t==60 then
		 enemy_shoot(e.x,e.y)
		 e.shoot_t=0
		else
		 e.shoot_t+=1
		end
 end
end

function enemy_shoot(x,y)
	local duree=60
	a=angle_to(x,y,p.x,p.y)
 
	add(e_bullets,{
	 x=x,
	 y=y,
	 dx=cos(a),
  dy=-sin(a)
	})
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
-->8
--player

function init_player()
	p={x=60,
  y=80,
  speed=1,
  life=3,
  t=0,
  invincible=false,
  anim={16,17,18}
 }
end

function update_player()
 if (btn(⬅️)) p.x-=p.speed
	if (btn(➡️)) p.x+=p.speed
	if (btn(⬆️)) p.y-=p.speed
	if (btn(⬇️)) p.y+=p.speed
	if (btnp(❎)) shoot()
	for b in all(e_bullets) do
		if collision(b,p) and
		 not p.invincible then
			p.life-=1
			p.invincible=true
			explode(b.x+4,b.y+8)
			del(e_bullets,b)
			sfx(1)
		end
	end
	if p.life<=0 then
	 _upd=update_gameover
  _drw=draw_gameover
	end
	if p.invincible and p.t<60 then
	 p.t+=1
	else
	 p.t=0
	 p.invincible=false
	end
end

function draw_player()
 if p.t%3==0 then
 	spr(animate(p.anim),p.x,p.y)
 end
end

function shoot()
 add(bullets,{
  x=p.x,
  y=p.y,
  speed=4
 })
 sfx(0)
end
__gfx__
00000000006006000000000000000000000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000060060000900900000bbb0000ecce000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700006006000090090000bbbbb00ecddce00080800000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700006dc7d60009009000bb0b0bbecddddce0888880000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700006dccd60009009000bbbbbbbecddddce0888880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700d66dd66d000000000bbbbbbb0ecddce00088800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d666666d0000000000b0b0b000ecce000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000050dd0500000000000000000000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600006006000060060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600006006000060060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600006006000060060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06dc7d6006dc7d6006dc7d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06dccd6006dccd6006dccd6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d66dd66dd66dd66dd66dd66d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d666666dd666866dd666686d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050dd050050dd050050dd05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000325302d5302853025520205201e520165101051007510215002750032500075000550004500035000350003500075000e500135000050000500005000050000500005000050000500005000050000500
000300002a620276201c62014620106100f6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
