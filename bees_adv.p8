pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function _init()
	init_bee()
	init_flower()
	init_seed()
	init_polen()
	
	x = 20
	y = 120
	generate_seed(1, 10, 120)
	generate_seed(3, 92, 120)
	generate_seed(5, 48, 120)
	generate_seed(1, 112, 120)
	
	flag = true
		
end

function _update60()

 update_swarm()

	update_bee()
	update_seed()
	update_flower()
	update_polen()

end

function update_swarm()
 if n_flying > n_bees - 5 and active_flowers > 0 then
  if rnd() < 0.01 then
	  b = select_bee()
	  f = select_flower()
	  assign_bee_flower(b,f)
  end
 end
end

function select_bee()
 for i=1,n_bees do
  b = bees[i]
  if b.state == 0 then
		 return b  	
 	end
 end
end

function select_flower()
 local actives = {}
 for i=1,n_flowers do
  f = flowers[i]
  if f.active then
   //index = i
   //return flowers[index]
   add(actives, i)
  end
 end
 index = flr(rnd(#actives))+1
 return flowers[actives[index]]
 //return -1
end

function assign_bee_flower(b, f)
	b.state = 1
	r_x = flr(rnd(6))-3
	r_y = flr(rnd(6))-3
	b.target_id = f.id
	b.target_x = f.x + 8 + r_x
	b.target_y = f.y - 2 + r_y
		 
	n_flying -= 1
end


function _draw()
 cls(1)
 draw_ground()
	draw_flower()
	draw_polen()
	draw_seed()
	draw_bee()
	print("bees in the swarm: "..n_flying, 0,0, 15)
	if flag then print("active_flowers: "..active_flowers,0,8, 15) end
end


-->8
function init_bee()
 n_bees = 15
 n_flying = n_bees
 bees = {}
 
 for i = 1,n_bees do
  add(bees, set_bee())
	end
	
	b_timers = {}
	
end

function set_bee()
 bee = {}
		
	bee.x = 0
	bee.y = 0
	bee.spr = 0
		
	bee.cen_x = 64//flr(rnd(8))+ 60
	bee.cen_y = 64//flr(rnd(8))+ 60
		
	bee.x_r = flr(rnd(12))+12
 bee.y_r = flr(rnd(12))+12
  
 bee.x_angle = 0
 bee.y_angle = 0
  
 bee.x_s = rnd()/100 + 0.002
 bee.y_s = rnd()/100 + 0.002
 
 bee.state = 0
 return bee
end

function update_bee()

	for i=1,n_bees do
	 b = bees[i]
	 
	 // just flying 
	 if b.state == 0 then
	  fly_around(i)
	  
	 // heading towards flower
	 // then stopping
	 elseif b.state==1 then
	  
	  dist_x = b.target_x - b.x
			dist_y = b.target_y - b.y
			cond_1 = abs(dist_x) > 2
			cond_2 = abs(dist_y) > 2
			
			if cond_1 then
			 b.x = b.x + (dist_x/abs(dist_x))/2
			end
			if cond_2 then
			 b.y = b.y + (dist_y/abs(dist_y))/2
			end
			
			if not cond_1 and not cond_2 then
			 timer = {}
			 timer.time = time()
			 timer.id = i
			 add(b_timers, timer)
			 b.state = 2
			end
			
		// waiting at the flower
		elseif b.state==2 then
		
	 
	 // heading back to air
	 // then reseting to state 0
	 elseif b.state==3 then
	  
	  dist_x = b.target_x - b.x
			dist_y = b.target_y - b.y
			cond_1 = abs(dist_x) > 2
			cond_2 = abs(dist_y) > 2
			
			if rnd() < 0.04 then
			 dir_x = dist_x/abs(dist_x)
			 generate_polen(b.polen, b.x, b.y, dist_x)
			end
			
			if cond_1 then
			 b.x = b.x + (dist_x/abs(dist_x))/2
			end
			if cond_2 then
			 b.y = b.y + (dist_y/abs(dist_y))/2
			end
			
			if not cond_1 and not cond_2 then
			 b.state = 0
			 n_flying += 1
			 
			end
	  
	 end
	end
	
	for i=1,#b_timers do
	 t = b_timers[i]
	 if time() - t.time > 2 then
	  reset_bee(t.id)
	  b = bees[t.id]
	  b.polen = flowers[b.target_id].type
	  del_life(b.target_id)
			b.target_id = 0
	  del(b_timers, t)
	  break
	 end
	end
	
end

function reset_bee(id)
		b = bees[id]
		b.state = 3
		 		 
		b.target_x = b.cen_x + b.x_r * cos(b.x_angle)
	 b.target_y = b.cen_y + b.y_r * sin(b.y_angle)
end

function unasign_bees(target_id)
 for i=1,n_bees do
		b = bees[i]
		if b.target_id == target_id then
		 reset_bee(i)
		end
	end
	for i=#b_timers,1,-1 do
	 t = b_timers[i]
	 if bees[t.id].target_id == target_id then
	  reset_bee(t.id)
	  del(b_timers, t)
	 end
	end
end

function fly_around(id)
 b = bees[id]
 
 x_before = b.x
 
 b.x = b.cen_x + b.x_r * cos(b.x_angle)
	b.y = b.cen_y + b.y_r * sin(b.y_angle)
		
	if b.x > x_before then b.spr = 0 else b.spr = 16 end	
		
	b.x_angle = b.x_s + b.x_angle
	b.y_angle = b.y_s + b.y_angle
end

function draw_bee()

	for i=1,n_bees do
		b = bees[i]
		//print(".",b.x,b.y,10)
		spr(b.spr,b.x,b.y)
	end
	
end


-->8
function draw_ground()
 line(0, 124, 127, 124, 11)
 line(0, 125, 127, 125, 3)
 line(0, 126, 127, 126, 4)
	line(0, 127, 127, 127, 4)
end
-->8
function init_flower()
	n_flowers = 5
	active_flowers = 0
	flowers = {}
	
	for i=1,n_flowers do
		flower = {}
		flower.active = false
		add(flowers,flower)
	end
	
	f_timers = {}
	fl_id = 1
end

function generate_flower(seed)
 flower_id = -1
 for i=1,n_flowers do
		if flowers[i].active == false then
		 flower_id = i
		 break
		end
	end
	if flower_id == -1 then 
	 return 
	end

	flower = {}
	flower.size = 16
	flower.lives = 3
	flower.type = seed.id
	flower.birth = time()
	flower.death = time()+10
	flower.active = true
	flower.id = flower_id
	
	if seed.id == 1 then
		flower.x = seed.x - 8
		flower.y = seed.y - 12
  flower.spr = 1
 elseif seed.id == 3 then
		flower.x = seed.x - 8
		flower.y = seed.y - 12
  flower.spr = 3
	else
		flower.x = 64
		flower.y = 124-16
  flower.spr = 1
	end
	
	flowers[flower_id] = flower
	active_flowers += 1
	
end

function del_life(id)
 flowers[id].lives -= 1
 if flowers[id].lives == 0 then
		flowers[id].active = false
		active_flowers -= 1
		unasign_bees(id)
 end
end

function update_flower()
 //if #f_timers > 0 then
 // t = f_timers[1]
 // if time() - t.time > 5 then
 //  f = del(flowers, flowers[1])
 //  del(f_timers, t)
 //  reset_bee(f.id)
 //  if #f_timers > 0 then
 //   t = f_timers[1]
 //   t.time = time()
 //  end
 // end
 //end

 //for i=1,#f_timers do
 // t = f_timers[i]
 // if time() - t.time > 5 then
 //  f = del(flowers, flowers[i])
 //  del(f_timers, f_timers[i])
 //  reset_bee(f.id)
 //  break
 // end
 //end
end

function draw_flower()
 for i=1,#flowers do
  f = flowers[i]
  if f.active then
   f = flowers[i] 
   spr(f.spr, f.x, f.y, 2, 2)
  end
 end
	//spr(3, flower.x, flower.y, flower.size, 16)
end
-->8
function init_seed()
 seeds = {}
 s_timers = {}
 spawn_range = 8
 rot_timer = time()
end

function generate_seed(id, x,y)
 
 timer = {}
 timer.time = time() 
 add(s_timers,timer)

 seed = {}
 seed.x = x
 seed.y = y
 seed.id = id
 add(seeds, seed)
 
end

function update_seed()

	
 if #s_timers > 0 then
  t = s_timers[1]
  if time() - t.time > 3 then
   seed = del(seeds, seeds[1])
   del(s_timers, t)
   
   collides = false
   for i=1,n_flowers do
    f = flowers[i]
    if f.active then
     if abs(f.x - seed.x) < spawn_range then
      collides = true
     end
    end
   end
   
   if collides == false then
		  generate_flower(seed)
		 end
		 
		 if #s_timers > 0 then
	   t = s_timers[1]
	   t.time = time()
	  end
	  
  end
 end
 
 if #seeds > 5 then
  del(seeds, seeds[#seeds])
  del(s_timers, s_timers[#seeds])
 end
 
end

function draw_seed()
  for i=1,#seeds do
   s = seeds[i]
   print(".",s.x,s.y,5)
  end
end
-->8
function init_polen()
	polens = {}
end

function generate_polen(id, x, y, dir_x)
 polen = {}
 polen.id = id
 polen.x = x
 polen.y = y
 polen.x_speed = dir_x * rnd()/100
 polen.ready = false
 add(polens, polen)
end

function update_polen()
 for i=1,#polens do
  p = polens[i]
  if p.y < 120 then
  	p.y += 0.2
  	p.x += p.x_speed
  else
   p.ready = true
   generate_seed(p.id, p.x,p.y)
   del(polens, p)
   break
  end 
 end
end

function draw_polen()
 for i=1,#polens do
  p = polens[i]
  print(".",p.x,p.y,7)
 end
end
__gfx__
0000000000000008800800000000000ee00e00000000cc00cc000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000888888800000000eeeeeeee0000000cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000008998988000000000e99aeeee00000ccfffffc00000000000000000000000000000000000000000000000000000000000000000000000000000
0000a000000008889a98000000000eea9a9e000000cccff9ffc00000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000000088aa99800000000eea9999e00000000cf99ffcc0000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000884988800000000ea9a9ee0000000ccfffffcc0000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000880bb08800000000eeaaee00000000cccbffcc00000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000003b000000000000e333eee0000000cccb33c000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000b000000000000004330e000000000003400000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000b0000000000000003400000000000003300000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000043300000000000000b000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000000000003b4000000000000b400000000000000340000000000000000000000000000000000000000000000000000000000000000000000000000000
0000a000000000000b00000000000043000000000000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004b000000000000b0000000000000004b00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000300000000000330000000000000000330000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000300000000000300000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000
