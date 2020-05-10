pico-8 cartridge // http://www.pico-8.com
version 26
__lua__
--new miami 2080
--surveillance brigade operations

function _init()
 first_time_map=true
 cur_threats={}
 stage=0
 turn=0
 --particles
 dust,dust_front={},{}
 dust_col={5,9,9,10}
 --glitch effect
 glit = {}
 glit.t=0
 
 init_database()
 dtb_init()
 
 title_t=0
 dep_mes_i=1
 max_shield_fill=30
 multiplier=0
 calc_multiplier=0
 offset=0
 t=0
 money=0
 money_printed=0
 
 --temp angle
 a=0
 
 --state
 init_shmup()
 _upd=update_shmup
 _drw=draw_shmup
end

--scene gameover
function update_gameover()
 if ❎_released and btn(❎) then
 	init_map()
  _upd=update_map
  _drw=draw_map
 end
end

function draw_gameover()
 cls(3)
 print("game over",20,50,11)
 print("press ❎ to continue",20,60,6)
 frame_borders()
end

--core functions
function _update60()
 update_input()
 dtb_update()
 _upd()
 update_bubble()
 --this must be at the end
 update_released()
end

function _draw()
 _drw()
 draw_bubble()
 dtb_draw()
end

function draw_money()
 if money_printed<money-15 then
  money_printed+=15
	 print_money(7)
 elseif money_printed<money then
  money_printed+=1
	 print_money(7)
 elseif money_printed>money+55 then
  money_printed-=55
	 print_money(8)
 elseif money_printed>money then
  money_printed-=1
	 print_money(8)
 else
  print_money(12)
 end
end

function print_money(col)
	print("$"..money_printed,101,4,col)
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
	colonel=false
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
   --messages et depart
   colonel=true
   local mes=deploy_messages[dep_mes_i]
   local nb_mes=#mes
   local i=1
   if nb_mes>1 then
    for j=1,nb_mes-1 do
     dtb_disp(mes[i])
     i+=1
    end
   end
   dtb_disp(mes[i],function()
	   dep_mes_i+=1
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
  palt(11, true)
  palt(0, false)
  draw_items(ship,1,38)
  palt()
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
	 print("threat"..map_index,12,12,11)
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
 if stage>0 then
  if stage==1 or stage==3 then
   music(0)
  else
   music(7)
  end
 end
 bullets={}
 e_bullets={}
 enemies={}
 explosions={}
 create_stars()
 blink_t=0
 wave=0
 notif_text=""
 notif_t=0
 init_player()
 money_printed=money
end

function update_shmup()
 t+=1
 blink_t+=0.5
 screen_shake()
 update_player()
	update_enemies()
	update_bullets()
	update_explosions()
	update_stars()
	wave_manager()
	for d in all(dust) do
  d:update()
 end
 for d in all(dust_front) do
  d:update()
 end
end

function wave_manager()
	if stage==0 then
	 update_title()
	elseif wave==0 then
	 update_stage_start()
	elseif wave>#stages[stage]+1 then
		notif_t+=1
		if notif_t==100 then
			init_bubble()
		end
	elseif (not text_mode
	and wave==#stages[stage]+1
	and #enemies==0)
	or p.life==-120 then
		wave+=1
		notif_t=0
	 notif_text="mission complete"
	elseif wave<=#stages[stage] then
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
		 wave+=1
		end
	end
end

function update_stage_start()
	notif_t+=1
	notif_text="mission start"
	if p.y==80 then
	 wave=1
	else
		p.y=max(80,p.y-0.5)
	end
end

function update_title()
 if btnp(❎) then
 	stage=1
 	sfx(1)
 	music(0)
 end
 title_t+=0.15
end

function draw_title()
 local col=7
 if (flr(title_t)%7>3) col=6
 if (flr(title_t)%7==5) col=13
	spr(196,15,30,12,4)
	print("surveillance brigade operations",3,65,13)
 print("press ❎ to start",30,80,col)
end

function draw_shmup()
	cls(1)
	draw_stars()
	for d in all(dust) do
  d:draw()
 end
	draw_player()
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
	end
	if stage==0 then
	 draw_title()
	elseif stage>1 and p.life>0 then
  
  
	--shield
	local max_shield=ship[eqp[1]].shield
	local point_length=14
	if max_shield==3 then
		point_length=9
	elseif max_shield==5 then
		point_length=5
	end
	local i=1
	for j=1,p.shield do
		local x=3+(point_length+1)*(i-1)
		rectfill(x,5,x+point_length-1,7,12)
		i+=1
	end
	local col=12
	if flr(blink_t)%2==0 then
		col=7
	end
	if shield_fill>0 then
		local x=3+(point_length+1)*(i-1)
		rectfill(x,5,x+(point_length*shield_fill/max_shield_fill),7,col)
	end
	--multiplier
	if not graze then
		--force not blinking
		col=12
	end
	print("x"..multiplier,3,10,col)
  
  --hide top of experience rect
  
  line(3,5,29,5,1)
  
  --life
  
	 local max_life=ship[eqp[1]].life
	 local point_length=13
	 if max_life==3 then
	 	point_length=8
	 elseif max_life==4 then
	 	point_length=6
  end
  --grey back line
  for i=1,max_life do
   local x=4+(point_length+1)*(i-1)
   line(x,5,x+point_length-1,5,5)
	 end
	 --white bars
	 for i=1,p.life do
	  local x=4+(point_length+1)*(i-1)
	  line(x,5,x+point_length-1,5,6)
	  line(x+1,4,x+point_length,4,6)
	 end
	 --sprite
	 palt(11, true)
	 palt(0, false)
	 spr(82,1,0,4,2)
	 palt()
	 --money
	 draw_money()
	end
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
		{3,"low",1,1},
		{4,"medium",3,1},
		{5,"medium",2,1}
	}
	deploy_messages={
	 {"oh, avant que j'oublie, petit conseil.","seul le gyrophare de votre vaisseau est vulnerable.","en fait,","ca pourrait meme vous aider de froler les balles avec le reste du vaisseau.","vous verrez.","allez, bonne chasse."},
  {"et c'est parti."},
  {"vous savez, y a un truc special chez vous.","vous etes peut-etre un peu maladroite des fois","mais vous y mettez du coeur.","on voit pas ca chez tout le monde.","alors, quoi qu'il arrive, vous allez vous en sortir dans la vie.","si vous y croyez pas, j'y croirai pour vous.","bon vent, ma petite."},
  {"mettez-leur une raclee."},
  {"vous commencez a etre a l'aise ?","pas trop hein","c'est le metier qui rentre.","bientot on croira que vous avez fait ca toute votre vie.","oubliez pas d'attacher votre ceinture."},
  {"jeune fille.","vous alliez partir sans me prevenir ?","vous savez, je vous regarde toujours dans le radar.","faudrait pas qu'il vous arrive quelque chose.","alors passez me voir, la prochaine fois."},
  {"tiens donc, ma recrue preferee.","heu, le dites pas aux autres.","vous savez, je voulais pas etre affecte ici","ma famille est a fortune iii","alors les journees sont longues","mais vous","...","ah, je sais pas.","faites comme si j'avais rien dit, va.","bonne route, soldat.","vous allez les degommer."},
  {"c'est parti."}
 }
 --equipment chosen
 --ship, weapon, secondary
 eqp={1,1,1}
	--ships
	ship={
	 {
	  speed=1.2,
   life=3,
   shield=2,
   anim={16},
   x1=7,y1=9,
   w=1,h=2,
   text={"si tu veux mon avis,","c'est pas avec ce rafiot que t'iras bien loin.","mais bon, quand y a pas de thune,","y a pas de thune."}
  },
  {
   speed=1.2,
   life=4,
   shield=3,
   price=1700,
   anim={16},
   x1=7,y1=7,
   w=1,h=1,
   text={"un peu plus robuste, celui-la.","vu ton allure au combat,","ce serait pas du luxe."}
  },
  {
	  speed=1.2,
   life=2,
   shield=5,
   price=9930,
   anim={16},
   x1=7,y1=9,
   w=1,h=2,
   text={"ah, ca c'est un bolide de vrai pilote.","la coque est tres fragile","mais le bouclier est une merveille.","enfin, faut savoir booster la recharge,","sinon ca sert a rien.","dis-moi la petite jeune, tu sais booster la recharge ?","faut froler les balles.","ca pimente les virees."}
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
   w=3,h=3,
   text={"hm ?","ah, ce truc ?","bah, ca fait des petites bouboules colorees.","c'est mignon.","et je pense que c'est tout ce que j'ai a dire dessus."}
  },
  {
   price=800,
   speed=3,
   frequency=8,
   duration=25,
   damage=12,
   sfx=13,
   anim={30},
   x1=0,y1=1,
   w=6,h=6,
   text={"voila une arme qui a un peu plus de gueule deja.","avec ca, tu vas un peu moins tirer a cote des mechants.","c'est pratique."}
  },
  {
   price=5990,
   speed=3,
   frequency=8,
   duration=25,
   damage=15,
   sfx=13,
   anim={29},
   x1=1,y1=0,
   w=5,h=7,
   text={"tres costaud ce truc.","moins marrant que le lance-flammes quand meme.","mais plus versatile."}
  }
 }
 --secondary
 secondary={
  {
   speed=3.5,
   frequency=12,
   duration=16,
   damage=10,
   sfx=13,
   anim={47},
   x1=2,y1=2,
   w=3,h=3,
   text={"eh, la petite jeune.","on s'interesse aux armes a chaleur ?","j'aime bien ces trucs.","par contre ca utilise un peu de puissance de propulsion.","faut pas s'en servir n'importe comment.","celle-la a une courte portee, mais bon","elle fait quand meme mal tu sais.","c'est pratique pour les tirs de precision rapproches.","...","ouais, je sais.","on fait pas tous les jours des tirs de precision rapproches."}
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
   w=3,h=7,
   text={"boom. boom. boom.","cette arme, elle chante la mort.","boom. boom.","boom."}
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
   w=6,h=7,
   text={"la specialite de la maison.","le gros lance-flammes.","putain c'que ca me donne envie de bruler des trucs.","tu sais, quand on a une vie comme la mienne","on se demande un peu","si on fait une vraie difference dans ce monde de tares.","mais ce lance-flammes.","putain de merde.","putain de merde ce lance-flammes !","quel plaisir."}
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
    {2,4,0}
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
   anim={52},
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
    emt.pattern_t+=0.05
    if flr(emt.pattern_t)%4~=2 then
	    return 0.25+0.04+sin(emt.pattern_t+0.25)/50
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
    emt.pattern_t+=0.05
    if flr(emt.pattern_t)%4~=2 then
	    return 0.25-(0.04+sin(emt.pattern_t+0.25)/50)
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
  },
  {
	--little follow
	bullet=1,
	frequency=40,
	speed=1.6,
	repeats=1,
	angle=function (rpt,emt,e)
	 return angle_to(e.x+emt[2],e.y+emt[3],p.x+p.x1-2,p.y+p.y1-2)
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
   {"pas mal.","enfin, y a pas de quoi etre fiere non plus,","mais c'est pas mal.","y en a d'autres qui arrivent.","plein de petits points rouges."},
   {2,1,60,2},
   {3,1,100,3},
   {2,1,80,1},
   {1,1,8,1,20},
   {"ah ben, je vois deja plus personne.","c'etait du bon travail.","alors euh, bienvenue dans la brigade.","tu peux rentrer, il faut que tu dises bonjour au colonel."}
  },
  {
	--2-level-1
	{function()
		colonel=false
	end},
	{"eh, petite.","tu vois ce chiffre dans le coin ?","c'est ton multiplicateur d'argent et de bouclier.","grosse technologie.","frole les balles pour aspirer leur energie et faire monter le chiffre.","tu me remercieras."},
	{2,1,60,1},
	{3,1,80,1},
	{2,1,40,1},
	{3,1,90,6,10},
	{1,2,50,1},
	{1,2,-40,1,120},
	{1,2,30,1},
	{1,1,98,2,1},
	{1,1,-40,3,20},
	{3,1,90,7},
	{2,1,70,1,180},
	{1,1,8,8,10},
	{2,1,80,6},
	{1,2,8,1,100},
	{2,1,60,9,60},
	{1,2,8,1}
  },
  {
	  --3-level-2
   {1,1,80,2},
   {1,1,-80,3,1},
   {1,2,10,1},
   {1,1,85,2,1},
   {1,1,-85,3,20},
   {1,2,-30,2},
   {3,1,60,3},
   {2,1,90,8,100},
   {2,1,40,6,80},
   {1,2,70,2},
   {1,2,-70,1,80},
   {1,1,-85,3,60},
   {1,1,20,1,70},
   {3,1,70,1},
   {1,1,-50,7,120},
   {1,1,50,6,80},
   {1,1,-25,7,60},
   {1,1,25,6,60},
   {1,2,0,1,80},
   {1,2,-40,1},
   {1,2,-50,7},
   {1,2,45,8,60},
   {2,1,30,3,120},
   {2,1,20,6,100}
  },
  {
	  --tests
	  {"ce niveau est juste un test. il compte pas vraiment!"},
	{1,4,-40,4},
	{1,1,80,2,1},
	{1,1,-80,3,1},
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
	--exemple de swarm de petits ennemis
   {4,1,90,2},
   {2,1,60,7,60},
   {2,1,40,2},
   {3,1,60,7,120},
   {3,1,90,8,80},
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
 shield_fill=0
end

function update_player()
 graze=false
 --movement
 local ix,iy,speed=0,0,1
 if (btn⬅️) ix-=1
	if (btn➡️) ix+=1
	if (btn⬆️) iy-=1
	if (btn⬇️) iy+=1
	if ix~=0 and iy~=0 then
	 ix*=0.8
	 iy*=0.8
	end
	if btn🅾️ then
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
	--transition de sortie
	if (bubble_mode and p.life>0) p.y-=bubble_t*3
	--weapons
	p.wep1_t+=1
	p.wep2_t+=1
	if wave~=0 and p.life>0 then
		if btn🅾️ and p.wep2_t>=p.wep2_t_max then
		 shoot(secondary[eqp[3]],4,-2)
		 p.wep2_t=0
		elseif btn❎ and p.wep1_t>=p.wep1_t_max then
		 shoot(weapon[eqp[2]],-2,2)
		 shoot(weapon[eqp[2]],10,2)
		 p.wep1_t=0
		end
	end
	--collision
	for e in all(enemies) do
		if collision(e,p) and
		not p.invincible and
		p.life>0 and
		not text_mode then
		 if p.shield>0 then
			 p.shield-=1
			else
			 p.life-=1
			end
			p.invincible=true
			offset=0.15
			sfx(1)
		end
	end
	for b in all(e_bullets) do
		if collision(b,p) and
		not p.invincible and
		p.life>0 and
		not text_mode then
			if stage~=1 then
				if p.shield>0 then
				 p.shield-=1
				else
				 p.life-=1
				end
			end
			p.invincible=true
			for i=1,3 do
			 add_new_dust(b.x+4,b.y,rnd(2)-1,-(rnd(1.5)-2),15,rnd(3)+2,0.1,dust_col,true)
			end
			del(e_bullets,b)
			offset=0.15
			sfx(1)
		elseif not (b.x+b.x1>p.x+16 or
          b.y+b.y1>p.y+16 or
          b.x+b.x1+b.w<p.x or
          b.y+b.y1+b.h<p.y) then
		 graze=true
		end
	end
	if p.life==0 then
	 for i=1,30 do
		 add_new_dust(p.x+rnd(16),p.y+rnd(16),rnd(2)-1,rnd(2)-2.1,rnd(10)+16*2.2,rnd(6)+2,0.05,dust_col)
  end
  p.life-=1
	end
	if (p.life<0) p.life-=1
	if p.invincible and p.inv_t<60 then
	 p.inv_t+=1
	else
	 p.inv_t=0
	 p.invincible=false
	end
	if graze then
	 calc_multiplier=min(3.5,calc_multiplier+0.01)
	else
	 calc_multiplier=max(1,calc_multiplier-0.002)
	end
	multiplier=min(3,flr(10*calc_multiplier)/10)
	if p.shield>=ship[eqp[1]].shield then
	 shield_fill=0
	end
	if shield_fill>=max_shield_fill then
	 p.shield+=1
	 shield_fill=0
	end
 player_dust(8,14)
end

function player_dust(x,y)
	if p.life>0 then
	 add_new_dust(p.x+x,p.y+y,rnd(0.3)-0.15,-(rnd(1)-1),7,3,0.1,dust_col)
 end
end


function draw_player()
 if p.inv_t%3==0 and p.life>0 then
  palt(11, true)
  palt(0, false)
 	spr(animate(p.anim),p.x,p.y,2,2)
  palt()
 end
 if p.life>0 then
  spr(animate({64,65,66,67,68,69,70,71,72}),p.x+7,p.y+8)
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
	  e.x=-80-10*amount+i*20
	  e.x_change=flr((128-width)/2)+8*(i-1)+gap*(i-1)-e.x
	  e.y=10
	  e.y_change=20
	  e.move_duration=150+rnd(40)
	 elseif behaviour==3 then
	  --coming from the right
	  e.x=140+i*40
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
	 elseif behaviour==6 then
	  --coming from the left down
	  e.x=-80-10*amount+i*20
	  e.x_change=flr((128-width)/2)+8*(i-1)+gap*(i-1)-e.x
	  e.y=25
	  e.y_change=20
	  e.move_duration=150+rnd(40)
	 elseif behaviour==7 then
	  --coming from the right down
	  e.x=140+i*40
	  e.x_change=flr((128-width)/2)+8*(i-1)+gap*(i-1)-e.x
	  e.y=25
	  e.y_change=20
	  e.move_duration=150+rnd(40)
	 elseif behaviour==8 then
	  --coming from the left up
	  e.x=-80-10*amount+i*20
	  e.x_change=flr((128-width)/2)+8*(i-1)+gap*(i-1)-e.x
	  e.y=-5
	  e.y_change=20
	  e.move_duration=150+rnd(40)
	 elseif behaviour==9 then
	  --coming from the right up
	  e.x=140+i*40
	  e.x_change=flr((128-width)/2)+8*(i-1)+gap*(i-1)-e.x
	  e.y=-5
	  e.y_change=20
	  e.move_duration=150+rnd(40)
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
		 money+=flr(e.money*multiplier)
		 for i=1,(e.w+e.h)/2 do
		  add_new_dust(e.x+e.x1+rnd(e.w),e.y+e.y1+rnd(e.h),rnd(2)-1,rnd(2)-2.1,rnd(10)+((e.w+e.h)/2)*2.2,rnd(6)+2,0.05,dust_col)
   end
   del(enemies,e)
   if p.shield<ship[eqp[1]].shield then
	   shield_fill+=1*multiplier
	  end
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
 music(15)
	blink_t=0
	map_index=1
	trans_t=-30
	processed=1--tout sauf 0
	colonel=true
end

function update_map()
 if trans_t>160 then
		if btnp⬆️ then
		 map_index=max(1,map_index-1)
		 blink_t=0
		end
		if btnp⬇️ then
			map_index=min(#cur_threats,map_index+1)
		 blink_t=0
		end
		if btnp❎ then
		 stage=threats[cur_threats[map_index]][1]
		 _upd=update_shop
	  _drw=draw_shop
	  init_shop()
		end
	end
	
	blink_t+=0.05
	
	if first_time_map and trans_t==140 then
	 local t={"ah c'est elle la nouvelle ?","bon, ben.","salut l'artiste !","bienvenue dans la brigade de surveillance de new miami.","alors comme ca on aime bien dezinguer des aliens ?","...","oui. bon. alors. la mission.","ca c'est l'ecran de controle de la zone a-1."}
	 for i in all(t) do
	 	dtb_disp(i)
  end
  dtb_disp("c'est nous. on s'occupe des trois tours de surveillance.",function() add(cur_threats,1) end)
	 local t={"les points rouges, c'est les aliens.","s'ils s'approchent, c'est chiant.","ca tire partout, y a du sang, faut refaire la peinture.","donc quand tu vois des points rouges","si tu pouvais aller tirer sur tout le monde","ce serait nickel.","eh ben, je crois qu'on a fait le tour."}
	 for i in all(t) do
		 dtb_disp(i)
  end
  dtb_disp("bonne continuation.",function() first_time_map=false end)
 end
 
 if trans_t==160 and not first_time_map then
  if not got_game_over then
   next_turn()
  end
 end
 
 if processed==0 and not first_time_map then
 	create_threats()
 	processed=false
 end
 
 trans_t+=1
end

function next_turn()
 processed=#cur_threats
 for i in all(cur_threats) do
 	if stage==threats[i][1] then
   del(cur_threats,i)
 		dtb_disp("une menace a ete eradiquee, beau travail.",function() processed-=1 end)
		else
		 threat_progress(i)
		end
 end
end

function threat_progress(i)
	threats[i][4]=min(3,threats[i][4]+1)
 if threats[i][4]==3 then
 	dtb_disp("la tour "..threats[i][3].."est attaquee !",function() processed-=1 end)
 else
  dtb_disp("hmm, les aliens progressent vers la tour"..threats[i][3].."...",function() processed-=1 end)
 end
end

function create_threats()
 turn+=1
	if turn==1 then
		add(cur_threats,2)
		add(cur_threats,3)
		local text={"ah, y a d'autres missions pour vous.","vous savez, j'ai foi en vous.","je vais vous regarder faire d'ici."}
		for t in all(text) do
			dtb_disp(t)
		end
	elseif turn==3 then
	 add(cur_threats,4)
	 local text={"la tour 3 a detecte quelque chose !","faites attention, ca a l'air d'etre du serieux.","revenez-nous en bon etat !"}
		for t in all(text) do
			dtb_disp(t)
		end
	end
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
	
	if trans_t>120 then
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
			
			if map_index==i then
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
   --line(0,64,d*4,64,2)
   --line(127,64,127-d*4,64,2)
  else
   rectfill(0,64-h,127,64+h,0)
   rect(-1,64-h-1,128,64+h+1,13)
  end
  if h>=2 then
   x1=82-(timer*0.5)
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
 local id=77
 if colonel==true then
  id=74
 end
 spr(id,dtb_y*2-138,dtb_y-43,3,4)
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
  local t={6,11,3}
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

--stars

function create_stars()
 stars={}
 --slow, dark stars
 for i=1,20 do
  add(stars,{
   color = 13,
   x = rnd(128),
   y = rnd(128),
   length=0,
   speed = rnd(1)+0.4
  })
 end
 --fast, bright stars
 for i=1,6 do
  add(stars,{
   color = 6,
   x = rnd(128),
   y = rnd(128),
   length = 1,
   speed = rnd(2)+2
  })
 end
end

function update_stars()
 for star in all(stars) do
  star.y += star.speed
  if star.y >= 128 then
   star.y = rnd(64)-64
   star.x = rnd(128)
  end
 end
end

function draw_stars()
 for star in all(stars) do
  line(star.x,star.y,star.x,star.y+star.length,star.color)
 end
end

--bubble transition

function init_bubble()
	bubble_t=0
 bubble_mode=true
end

function update_bubble()
 if bubble_mode then
  if bubble_t>2.45 and bubble_t<2.55 then
   bubble_t+=0.001
  else
   bubble_t+=0.05
  end
  if bubble_t>=5.1 then
   bubble_mode=false
  elseif bubble_t>2.55 then
   if p.life<0 then
	   _upd=update_gameover
	   _drw=draw_gameover
   else
	   init_map()
		  _upd=update_map
		  _drw=draw_map
	  end
  end
 end
end

function draw_bubble()
 if bubble_mode then
	 for i=0,8 do
			for j=0,8 do
	   local x = i*16
	   local osc = sin(bubble_t/4+j*0.03)
	   local y = j*16 + bubble_t
	   circfill(x, y, osc*15, 0)
	  end
	 end
 end
end
__gfx__
0000000000e00e0000e00e00000ee00000eeee0000eeee000000000000000000000000000000000000000000888888008e7777e800eeee000000000000000000
000000000e8ee8e00e2ee2e000e88e000e2222e00e2222e00000000000000000000000000000000000000000eeeeeee08e7777e80e7777e00008800000000000
00700700e888888ee222222e0e8888e0e222222ee222222e0000000000000000000000000000000000000000777777778e7777e8e777777e0087780000088000
00077000e885688ee225622e00e8658ee22222256222222e000eee0000eee000000eeee00eeee00000000000777777778e7777e8e777777e0877778000877800
000770000e8558e00e2552e000e8558e0ee2222552222ee000eeeee00eeeee0000e222e00e222e0000000000777777778e7777e8e777777e0877778000877800
0070070000e88e0000e22e000e8888e000eee222222eee000e22222ee22222e00e22222ee22222e000000000777777778e7777e8e777777e0087780000088000
00000000000ee000000ee00000e88e0000ee0eeeeee0ee00e22222222222222ee22222222222222e00000000eeeeeee00e7777e00e7777e00008800000000000
000000000000000000000000000ee0000000000000000000e22222222222222ee22222222222222e00000000888888000077770000eeee000000000000000000
bbbbbbb00bbbbbbb00000000000000000000000000eeeee0e22222256222222ee22222256222222e000000011000000000000000000cc0000000000000000000
bbbbbb05d0bbbbbb000000000000000000eeee000e22222ee22222255222222ee22222255222222e00000015d10000000000000000c77c0000ccc00000000000
bbbbbb0550bbbbbb00000000000000000e2222eee2222222e22222222222222ee22222222222222e0000001551000000000000000c7777c00c777c00000cc000
bbbbb051150bbbbb0777000770007770e2222222222222220e222222222222e0e2e2222ee2222e2e0000015115100000000000000c7777c0c77777c000c77c00
bbbbb016710bbbbb7666507665076665eeee22222222222200e2222ee2222e00ee0e22e00e22e0ee0000011671100000000000000cc77cc0c7ccc7c000c77c00
bbdbb066770bbdbb76665766665766650000ee222222222200e222e00e222e00e00e22e00e22e00e00500166771005000000000000cccc00ccccccc0000cc000
bb0bb067770bb0bb7666566116676665000000e22222222200e222e00e222e00000e22e00e22e00000100167771001000000000000cccc00cc000cc000000000
bb0b06611770b0bb7666561c716766650000000e256222220e222e0000e222e0000e22e00e22e000001016611771010000000000000cc000c00000c000000000
bd007611117600db7666561cc16766650000000e255222220e222e0000e222e0000e22e00e22e000051176111176115000000000008880000008800000000000
b00776111166600b7666561111676665000000e2222222220e22e000000e22e0000e22e00e22e000011776111166611000000000088988000089980000000000
b07776111166660b76665666666766650000ee22222222220e22e000000e22e0000e22e00e22e000017776111166661000000000889a9880008aa80000088000
06776611116776707777555555577776eeee2222222222220e22e000000e22e0000e22e00e22e00016776611116776710000000089aaa980008aa800008a9800
06776611117766607aaa55555557aaa5e2222222222222220e22e000000e22e0000e22e00e22e00016776611117766610000000089aaa98000899800008aa800
06766711117776607aaa50000007aaa50e2222eee22222220e22e000000e22e0000e22e00e22e00016766711117776610000000089aaa9800089980000888000
b00000000000000b655550000006555500eeee000e22222e00e2e000000e2e000000e2e00e2e0000011111111111111000000000089a98000088880000080000
bbbbbbbbbbbbbbbb00000000000000000000000000eeeee0000ee000000ee00000000ee00ee00000000000000000000000000000008880000008800000000000
000770006666666666666666666675d000eeee0000eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000
007666006666666666666666666675d00e8888e00e8888e000000000000000000000000000000000000000000000000000000000000000000000000000000000
007636006666666666666666666675d0e888888ee888888e00000000000000000000000000000000000000000000000000000000000000000000000000000000
057636506666666666666666666675d0e88888856888888e00000000000000000000000000000000000000000000000000000000000000000000000000000000
507666056666666777777777666675d00ee8888558888ee000000000000000000000000000000000000000000000000000000000000000000000000000000000
055555506666667555555555666675d000eee888888eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000
007636006666675ddddddddd666675d000ee0eeeeee0ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000666675d000000000666675d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc0000007c000000770000008700000088000000880000007800000077000000c700000000000000bbbb33bbbbbb333333333333bbbbb3333333333333333333
cc000000cc0000007c00000077000000870000008800000088000000780000007700000000000000bbb33bbbbbbbbb3333333333bbbb33333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000bb33bbbbbbbbbbb333333333bbb333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000bb3333bbbbbbbbb333333333bbb3333333bb333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000b33bbbbbbbbbbb3333b33333bbb33333bbbbb33333333333
0000000000000000000000000000000000000000000000000000000000000000000000000000000033bbbbbbbbbb33bbbbb33333bb333bbbbbbbbb3333333333
000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbbbbbb33333bbbbb33333bb33bbbbbbbbbbb333333333
000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbbb33333333bbbbb33333bb3bbbbbbbbbbbbb33333333
b000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000003333333b33333bbbbbb33333bb3bbb33333bbbb333333333
06677660bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000bbb333333333bbbbbbbb3333bb3bb33bbb3bb33bb3333333
06677760bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000bbb3333bbbbbbbbbbbbb3333bb3bb3bbbb3b33bbbb333333
07667770bbbbbbbbbbbb11111111111111111111111111bb00000000000000000000000000000000bbb333bbbbbbbbbbbbbb3333bb3bb3bbbb3b3bbbbb333333
07777670bbbbbbbbbbb1bbbbbbbbbbbbbbbbbbbbbbbbbb1b00000000000000000000000000000000bbbb33bbbbbbbbbbbbbb3333bb33bb3bbb3b33bbbb333333
b077660bbbbbbbbbbb1bbbbbbbbbbbbbbbbbbbbbbbbbb1b100000000000000000000000000000000bbbb33bbbbbbbbbbbbbb3333bb33bb33333bb33b33333333
bb0660bbbbbbbbbbbb111111111111111111111111111b1b00000000000000000000000000000000bbbb3bbbbbb33333bbbb3333bb33bbb333bbb33333b33333
bbb00bbbbbbbbbbbb1bbbbbbbbbbbbbbbbbbbbbbbbbbb11b00000000000000000000000000000000bbbbb3bb333333333bbb3333bb33bbbbbbbbbbb33bb33333
bbbbbbbbbbbbbbbbbb111111111111111111111111111bbb00000000000000000000000000000000bbbbbb33333333333bbb3333bb33bbbb333333bbbbb33333
bcccccccbcccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000bbbbbbbbb3333333bbbb3333bb33bbbb3333b33bbbb33333
bcccccccbcccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000bbbbbbbbbb33333bbbb33333bb333bbb33bbbb3bbbb33333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000bbbbbbbbb3bbbbbbbb33bb33bb3b3bbb333bb33bbbb33333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000bbbbbbbb3bbbbbbb33bbb333bb3b3bb33b3b3bbbbbb33333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000bbbbbbb3bbbbb333bbbbbb33bb3333b3bbb33bbbbbb33333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000bbbbbbb3bb333bbbbbbb3333b33333b333bb3bbbbbb33333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000bbbbbbbb33bb3bbbbbbb333333333333bb3b3bbbbb333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb33bbb3333333333333333bb33bbbbb333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbb33bbbbb33333333333333333bbbbb3333333
000000000000000000000000000000000000000000000000000000000000000000000000000000003bb333333bb333bbbbb3333333333333bbb3bbbb33333333
0000000000000000000000000000000000000000000000000000000000000000000000000000000033333bb3333333bbbbbb3333333333333b33bbbb33333333
000000000000000000000000000000000000000000000000000000000000000000000000000000003bb333333bb33bbb333333333333333bbb3bbb3333333333
0000000000000000000000000000000000000000000000000000000000000000000000000000000033333bb33333bbbbbbbbb333333333333b33b33333333333
0000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333bbbbbbb33333333333333bbb3b33333333333
0000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333bbbbb333333333333333333b3333333333333
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
00000000000000000007777777777766000770000000000000000000000000000000000000000000000000000000000000000000000000000000007700000000
000000000000000007777777777666660007700000007700000000000000000000000000077000dd000770000000000000000000000000000000077700000000
00000000000000777777777766666666000777000000770077000000000000000000000007700d00d00770007700007700000000000000000000077700007700
00000000000077777777766666666666000777000000770077777777777000000000000007700000d00770007770007700000770000000000000777700007700
0000000000077777777666666666666600077770000077007777777777770000000000000770000d000770007770007700000770000000077000777700007700
000000000077777776666666666666660007777000007700770000000077000000000000077000d0000770007777007700000770000000077000777700007700
00000000077777776666666666666666000777700000770077000000007700000000000007700dddd00777007777007700000777000000077007777700007700
00000000777777666666666666666666000777770000770077000000007700000000000007700000000777007777007700000777000000077007707700007700
000000077777766666666666666666660007707700007700770000000077000000000000077000dd000777007777007700000777700000077007707700007700
00000077777766666666666666666666000770770000770077000000007770000000000007700d00d00777707777007700000777700000077707707700007770
00000077777666666666666666666666000770770000770077000000000770000000000007700d00d00777707777707700000777700000077707707700000770
00000777776666666666666666666666000770777000770077000000000770000000000007700d00d00777707707707770000777700000077777707700000770
00000777776666666666666666666666000770077000770077000000000770000000000007700d00d00777707707700770000777700000077777707770000770
000077777666666666666666666666660007700770007700770000770007770000077000077000dd000777777707770770000777770000077777700770000770
00007777766666666666666666666666000770077700770077777777000077000007700007700000000770777700770770000770770000077077700770000770
000777776666666666666666666666660007700077007700777777700000777000777000077000dd000770777700770777000770770000077077700770000770
00077777666666666666666666666666000770007770770077000000000007700077700007700d00d00770777700770077000770777000077007700777000770
000777776666666666666666666666660007700007707700770000000000077700777000077000dd000770077700777077000770077770077007700077000770
00777776666666666666666666666666000770000770770077000000000000770777770077700d00d00770077700077077000777777770077007700077000770
00777776666666666666666666666666000770000777770077000000000000770770770077000d00d00770007700077777707777777700077000000077000770
077777666666666666666666666666660007700000777700770000000000007777707700770000dd000770000000007707707770007700077000000077700770
07777766666666666666666666666666000770000077770077700000000000777700777077000000000770000000007707770770007770077000000007700770
077777666666666666666666666666660007700000077700077000000000000777000770770000dd000770000000007770770770000770077000000007700000
07777666666666666666666666666666000770000007770007770000007770077700077777000d00d00770000000000770770000000770077000000007700000
77777666666666666666666666666666000000000007770000777777777770077700007777000d00d00770000000000770777000000777077000000007770000
77777666666666666666666666666666000000000007770000777777777000077000007777000d00d00770000000000777777000000077000000000000770000
77776666666666666666666666666666000000000000000000000000000000000000007777000d00d00770000000000077000000000077000000000000777000
777766666666666666666666666666660000000000000000000000000000000000000007700000dd000000000000000077000000000077700000000000077000
77776666666666666666666666666666000000000000000000000000000000000000000770000000000000000000000077000000000007700000000000077700
77766666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000077000000000007700000000000007700
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111d11111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111611111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111116111111111111111111111111111111111111111111111111111111111
111111111111111111111d1111111111111111111111111111111111111111111111116111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111177111111111111111111111111111111111111111111111111111111111111111111111111111111111771111111111111111111111111
1111111111111111117711111117711111111111111111111111111177111dd11177111111111111111111111111111111117771111111111111111111111111
111111111111111111777111111771177111111111111111111111117711d11d1177111771111771111111111111111111117771111771111111111111111111
111111111111111111777111111771177777777777111111111111117711111d1177111777111771111177111111111111177771111771111111111111111111
11111111111111111177771111177117777777777771111111111111771111d11177111777111771111177111111117711177771111771111111111111111111
1111111111111111117777111117711771111111177111111111111177111d111177111777711771111177111111117711177771111771111111111111111111
111111111111111111777711111771177111111117711111111111117711dddd1177711777711771111177711111117711777771111771111111111111111111
11111111111111111177777111177117711111111771111111111111771111111177711777711771111177711111117711771771111771111111111111111111
11111111111111111177177111177117711111111771111111111111771d1dd11177711777711771111177771111117711771771111771111111111111111111
111111111111111111771771111771177111111117771111111111117711d11d1177771777711771111177771111117771771771111777111111111111111111
111111111111111111771771111771177111111111771111111111117711d11d1177771777771771111177771111117771771771111177111111111111111111
111111111111111111771777111771177111111111771111111111117711d11d1177771771771777111177771111117777771771111177111111111111111111
111111111111111111771177111771177111111111771111111111117711d11d1177771771771177111177771111117777771777111177111111111111111111
1111111111111111117711771117711771111771117771111177111177111dd11177777771777177111177777111117777771177111177111111111111111111
11111111111111111177117771177117777777711117711111771111771111111177177771177177111177177111117717771177111177111111111111111111
1111111111111111117711177117711777777711111777111777111177111dd11177177771177177711177177111117717771177111177111111111111111111
111111111111111111771117771771177111111111117711177711117711d11d1177177771177117711177177711117711771177711177111111111111111111
1111111111111111117711117717711771111111111177711777111177111dd11177117771177717711177117777117711771117711177111111111111111111
111111111111111111771111771771177111111111111771777771177711d11d1177117771117717711177777777117711771117711177111111111111111111
1111111111111111117711d1777771177111111111111771771771177111d11d1177111771117777771777777771117711111117711177111111111111111111
1111111111111111117711111777711771111111111117777717711771111dd11177111111111771771777111771117711161117771177111111111111111111
d1111111111111111177111117777117771111111111177771177717711111111177111111111771777177111777117711161111771177111111111111111111
1111111111111111117711111177711177111111111111777111771771111dd11177111111111777177177111177117711111111771111111111111111111111
111111111111111111771111117771117771111117771177711177777111d11d1177111111111177177111111177117711111111771111111111111111111111
111111111111111111111111117771111777777777771177711117777111d11d1177111111111177177711111177717711111111777111111111111111111111
111111111111111111111111117771111777777777111177111117777111d11d1177111111111177777711111117711111111111177111111111111111111111
111111111111111111111111111111111111111111111111111117777111d11d1177111111111117711111111117711111111111177711111111111111111111
1111111111111111111111111111111111111111111111111111117711111dd11111111111111117711111111117771111111111117711111111111111111111
11111111111111111111111111111111111111111111111111111177111111111111111111111117711111111111771111111111117771111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111117711111111111771111111111111771111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111d11111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111dd1d1d1ddd1d1d1ddd1ddd1d111d111ddd1dd111dd1ddd11111ddd1ddd1ddd11dd1ddd1dd11ddd111111dd1ddd1ddd1ddd1ddd1ddd1ddd11dd1dd111dd11
111d111d1d1d1d1d1d1d1111d11d111d111d1d1d1d1d111d1111111d1d1d1d11d11d111d1d1d1d1d1111111d1d1d1d1d111d1d1d1d11d111d11d1d1d1d1d1111
111ddd1d1d1dd11d1d1dd111d11d111d111ddd1d1d1d111dd111111dd11dd111d11d111ddd1d1d1dd111111d1d1ddd1dd11dd11ddd11d111d11d1d1d1d1ddd11
11111d1d1d1d1d1ddd1d1111d11d111d111d1d1d1d1d111d1111111d1d1d1d11d11d1d1d1d1d1d1d1111111d1d1d111d111d1d1d1d11d111d11d1d1d1d111d11
111dd111dd1d1d11d11ddd1ddd1ddd1ddd1d1d1d1d11dd1ddd11111ddd1d1d1ddd1ddd1d1d1ddd1ddd11111dd11d111ddd1d1d1d1d11d11ddd1dd11d1d1dd111
11111111111111d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111177717771777117711771111117777711111177711771111117717771777177717771111111111111111111111111111111
11111111111111111111111111111171717171711171117111111177171771111117117171111171111711717171711711111111111111111111111111111111
11111111111111111111111111111177717711771177717771111177717771111117117171111177711711777177111711111111111111111111111111111111
11111111111111111111111111111171117171711111711171111177171771111117117171111111711711717171711711111111111111111111111111111111
11111111111111111111111111111171117171777177117711111117777711111117117711111177111711717171711711111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111d1111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111d111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111d1111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111d11111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111d1111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__sfx__
00020000325302d5302853025520205201e520165101051007510215002750032500075000550004500035000350003500075000e500135000050000500005000050000500005000050000500005000050000500
000300002a620276201c62014620106100f6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000005455054553f52511435111250f4350c43511125034550345511125182551b255182551d2551112501455014552025511125111252025511125202550345520255224552325522455202461d4551b255
010e00000c0530c4451112518455306251425511255054450c0530a4353f52513435306251343518435054450c053111251b4353f525306251b4353f5251b4350c0331b4451d2451e445306251d2451844516245
010e00000145520255224552325522445202551d45503455034050345503455182551b455182551d455111250045520255224552325522455202461d4551b255014550145511125182551b455182551d45511125
010e00000c0531b4451d2451e445306251d245184450c05317200131253f52513435306251343518435014450c0431b4451d2451e445306251d245184451624511125111253f5251343530625134351843500455
010e0000004550045520455111251d125204551d1252912501455014552c455111251d1252c4551d12529125034552c2552e4552f2552e4552c2552945503455044552c2552e4552f2552e4552c246294551b221
010e00000c0530c0531b4551b225306251b4551b2250f4250c0530c05327455272253062527455272251b4250c0531b4451d2451e445306251d245184450c0530c0531b4451d2451e445306251d2451844500455
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
010d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
011100000c3430035500345003353c6150a3300a4320a3320c3430335503345033353c6151333013432133320c3430735507345073353c6151633016432163320c3430335503345033353c6151b3301b4321b332
01110000162251b425222253751227425375122b5112e2251b4352b2402944027240224471f440244422443224422244253a512222253a523274252e2253a425162351b4352e4302e23222431222302243222232
011100000c3430535505345053353c6150f3301f4260f3320c3430335503345033353c6151332616325133320c3430735507345073353c6151633026426163320c3430335503345033353c6150f3261b3150f322
011100000f22522425272253f51227425375122b5112e2252724027232272222444024430244222b511224422b4422b23220241202322023220420204153a425162351b4351f4401f4321f2201d4401d4321d222
011100001d22522425272253f51227425375122b5112e225322403323133222304403043030422375112e44237442372322c2412c2322c2222c4202c4153a425162351b4352b4402b4322b220224402243222222
011100001f2401f4301f2201f21527425375122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
01110000182251f511242233c5122b425335122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
010700000c5370f0370c5270f0270f537120370f527120271e537230371e527230272f537260372f52726027165371903716527190271c537190371c527210271c53621036245262102624536330362452633026
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
__music__
01 02034344
00 02034344
00 02034344
00 02034344
00 04054344
00 04054344
02 06074344
01 08424344
00 09424344
00 0a424344
00 08424344
00 080b4344
00 090b4344
00 0a0c4344
02 080d4344
00 0e424344
00 0e424344
01 0e0f4344
00 0e0f4344
00 10114344
00 10124344
00 0e134344
02 0e144344
00 15424344
01 16174344
00 16174344
02 18194344

