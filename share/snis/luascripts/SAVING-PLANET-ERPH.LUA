
--
-- SAVING PLANET ERPH
--

-- First, clear the board
clear_all();

startx = 1000;
starty = -6000;

zarkon = 3;
disruptor = 12;
erph_hit_count = 0;

maxcities = 6
cityname = { "NUU BWORT", "SHIXOGI", "AOX ANDUZ", "HUXPUN", "ZOW PHOLLO", "ROKK ROX"  }
city = 1

-- find the player and move him where we want him to start.
player_ids = get_player_ship_ids();
player_name = "Unknown Player"
if (player_ids[1]) then
    move_object(player_ids[1], startx, starty, 0);
    player_name = get_object_name(player_ids[1]);
end

x = 2900;
y = 12000;
z = 290000;

zarkx = 250000;
zarky = -12000;
zarkz = 52000 

erphx = x;
erphy = y - 15000;
erphz = z - 12000;

nowwhat = add_planet("NOWWHAT", 3000, 3000, 2000, 5000);
nowwhat_starbase = add_starbase(8500, 5500, 2200, 1);

erph = add_planet("ERPH", erphx, erphy, erphz, 3000);
erph_starbase = add_starbase(erphx + 500, erphy + 4500, erphz - 1000, 2);

zark = add_planet("ZARK", zarkx, zarky, zarkz, 0); 
zark_starbase = add_starbase(zarkx + 900, zarky - 1200, zarkz + 1700, 3);

n1 = add_nebula("INSANITY-MAJORIS", x + 5000, y - 100, z - 1500, 5000);
n2 = add_nebula("INSANITY-MINORIS", x + 500, y - 200, z - 3000, 3000);
n3 = add_nebula("INSANITY", x + 8000, y - 700, z - 2500, 2000);

shipname = { "KARK", "TROZZMA", "JYRNNY", "BORT", "REJJI" }
baddy = { -1, -1, -1, -1, -1 }
alive = { 0, 0, 0, 0, 0 }

function add_some_asteroids()
	for i = 1, 200 do
		dx = math.random(15000) - 7500 + 15000;
		dy = math.random(15000) - 7500;
		dz = math.random(15000) - 7500 + 15000;
		add_asteroid(erphx + dx, erphy + dy, erphz + dz);
	end
end

add_some_asteroids();

function add_bad_guys(cookie)

	for i = 1, 5 do
		print("Adding " .. shipname[i]);
		baddy[i] = add_ship(shipname[i], x, y, z, disruptor, zarkon, 0);
		alive[i] = 1;
		ai_push_attack(baddy[i], erph);
		y = y + 250;
	end

	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, " A FLEET OF ZARKON DISRUPTORS HAS WARPED");
	comms_transmission(erph_starbase, " INTO THE AREA.  THEIR INTENTIONS ARE UNKNOWN");
	comms_transmission(erph_starbase, " BUT THEY ARE HEADING DIRECTLY TOWARDS ERPH");
	comms_transmission(erph_starbase, " REINFORCEMENTS WOULD BE APPRECIATED");
end

function first_hit_message()
	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, " WE ARE UNDER ATTACK BY A FLEET");
	comms_transmission(erph_starbase, " OF ZARKON DISRUPTORS");
	comms_transmission(erph_starbase, " PLEASE SEND REINFORCEMENTS");
	comms_transmission(erph_starbase, "");
end

function complain_about_hits()
	comms_transmission(erph_starbase, "");
	comms_transmission(erph_starbase, " ERPH IS TAKING HEAVY FIRE FROM ZARKON");
	comms_transmission(erph_starbase, " DISRUPTORS. PLEASE SEND HELP");
	if city <= maxcities then
		comms_transmission(erph_starbase, " THE CITY OF " .. cityname[city] .. " HAS BEEN DESTROYED!");
		city = city + 1;
        end
	comms_transmission(erph_starbase, "");
end

function object_hit_callback(target_oid, attacker_oid)
	if target_oid == erph then
		erph_hit_count = erph_hit_count + 1;
		if erph_hit_count == 1 then
			first_hit_message();
		end
		if (erph_hit_count % 40) == 0 then
                        complain_about_hits();
                end
		print("hits = ", erph_hit_count);
	end
end

function final_score()
	
	comms_transmission(erph_starbase, "ALL THE ZARKON INVADERS HAVE BEEN DESTROYED");
	if erph_hit_count < 100 then
		comms_transmission(erph_starbase, "ERPH CASUALTIES ARE LIGHT");
	else
		if erph_hit_count < 200 then
			comms_transmission(erph_starbase, "ERPH CASUALTIES ARE SIGNIFICANT");
		else
			if erph_hit_count < 300 then
				comms_transmission(erph_starbase, "ERPH CASUALTIES WERE HEAVY");
			else
				comms_transmission(erph_starbase, "ERPH CASUALTIES WERE VERY HEAVY");
			end
		end
	end
	comms_transmission(erph_starbase, player_name .. ", THANK YOU FOR YOUR ASSISTANCE");
	comms_transmission(erph_starbase, "IN REPELLING THE ZARKON INVADERS");
	comms_transmission(erph_starbase, "");
end

function object_death_callback(oid)
	dead_count = 0;
	alive_count = 0;
	for i in 1, 5 do
		if oid == baddy[i] then
			alive[i] = 0;
			dead_count = dead_count + 1
		end
		if alive[i] > 0 then
			alive_count = alive_count + 1
		end
	end
	if dead_count > 0 then
		comms_transmission(erph_starbase, "");
		comms_transmission(erph_starbase, player_name .. ", ANOTHER ONE BITES THE DUST");
		if alive_count > 0 then
			comms_transmission(erph_starbase, "ONLY " .. alive_count .. " MORE TO GO");
		else
			final_score();
		end
	end
end

register_timer_callback("add_bad_guys", 100, 0);
register_callback("object-hit-event", "object_hit_callback");
register_callback("object-death-event", "object_death_callback");

