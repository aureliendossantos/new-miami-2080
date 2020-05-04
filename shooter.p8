pico-8 cartridge // http://www.pico-8.com
version 22
__lua__
function _init()
 --delai btnp
 poke(0x5f5c, 4)
 --state
 _upd=update_shmup
 
 bullets={}
 e_bullets={}
 enemies={}
 explosions={}
 init_player()
 spawn_enemies(5)
end

function update_shmup()
	update_player()
	update_enemies()
	update_bullets()
	update_explosions()
end

function _update60()
 _upd()
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
		spr(5,i*8,1)
	end
end

function _draw()
 drw()
end

function update_bullets()
	for b in all(bullets) do
		b.y-=b.speed
	end
	for b in all(e_bullets) do
		b.y+=b.speed
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
	add(e_bullets,{
	 x=x,
	 y=y,
	 speed=2})
end
-->8
--tools

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
  invincible=false}
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
	if p.invincible and p.t<60 then
	 p.t+=1
	else
	 p.t=0
	 p.invincible=false
	end
end

function draw_player()
 if p.t%3==0 then
 	spr(1,p.x,p.y)
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
__sfx__
00020000325302d5302853025520205201e520165101051007510215002750032500075000550004500035000350003500075000e500135000050000500005000050000500005000050000500005000050000500
000300002a620276201c62014620106100f6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
