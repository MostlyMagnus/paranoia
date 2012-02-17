-- class to handle all the visual resources for the app
-- it does no drawing, only keeps the needed files in memory.

-- 32 lines of goodness - OO
assert(require('lib/32log'))

-- behaviour
--  update manifest
--   should load all the assets in the manifest availible on the server.
--   if they're not on disc, download and store them. This doesn't keep anything
--	 in memory, only makes sure the client has everything store locally. 
--   Should keep a table of the manifest during runtime for reference when add is called.

-- manifest should be formatted roughly as:
--  logo:static
--  pawn_idle:animation

-- add (asset_name, permanent = false)
--  adds an asset to the list of currently active assets, and loads the correct file
--  into memeroy. Return the asset_id number in the table/vector. This should be stored
--  in whatever object that uses it in the main loop. Permanent flag tells the asset not
--  to be unloaded in case of a purge.

-- get (asset_id)
--	returns the sprite that correlates to the provided asset_id. 

-- purge
--	unloads all the currently loaded assets from memory

-- update(dt)
-- 	called every frame by love.update to update animations.

-- self.loaded		asset
--				permanent:bool
-- self.animations  asset
-- 				
class "GraphicsHandler" {	
	manifest = {};
	loaded = {};
	animations = {};
}

function GraphicsHandler:__init() 	
	table.insert(self.manifest, {"background", "static"})

	table.insert(self.manifest, {"open", "static"})

	table.insert(self.manifest, {"logo_big", "static"})
	table.insert(self.manifest, {"logo_small", "static"})

	table.insert(self.manifest, {"tick_frame", "static"})	

	table.insert(self.manifest, {"tick" ,"static"})
	table.insert(self.manifest, {"tick_hovering" ,"static"})

	table.insert(self.manifest, {"fog", "static"})

	table.insert(self.manifest, {"b1", "static"})
	table.insert(self.manifest, {"c1", "static"})
	table.insert(self.manifest, {"e1", "static"})
	table.insert(self.manifest, {"g1", "static"})
	table.insert(self.manifest, {"q1", "static"})
	table.insert(self.manifest, {"s1", "static"})
	table.insert(self.manifest, {"w1", "static"})
	table.insert(self.manifest, {"cr1", "static"})
	table.insert(self.manifest, {"r1", "static"})
	table.insert(self.manifest, {"r2", "static"})
	table.insert(self.manifest, {"r3", "static"})
	
	table.insert(self.manifest, {"r_air", "static"})
	
	table.insert(self.manifest, {"na", "static"})
	
	table.insert(self.manifest, {"n_gen1", "animation", {64,64,0.06,0}})	
	table.insert(self.manifest, {"n_wat1", "animation", {64,64,0.06,0}})	
	table.insert(self.manifest, {"n_eng1", "animation", {64,64,0.06,0}})	
	table.insert(self.manifest, {"n_air1", "animation", {64,64,0.06,0}})	
	
	table.insert(self.manifest, {"player", "animation", {64,64,0.1,0}})	
end

function GraphicsHandler:updateManifest() 
end

function GraphicsHandler:add(assetName, permanent) 
	-- locate asset in manifest

	for _key, _value in pairs(self.manifest) do
		if _value[1] == assetName then
			-- lets see if its already loaded
			for loaded_key, loaded_value in pairs(self.loaded) do
				if loaded_value[4] == assetName then
					return loaded_key
				end
			end
			
			-- it wasn't loaded, add a new one
			if _value[2] == "static" then 
				table.insert(self.loaded, { love.graphics.newImage( "assets/static/"..assetName..".png" ), permanent, nil, assetName })
			
				-- Return the id
				return # self.loaded
			elseif _value[2] == "animation" then 
				-- Store the sprite sheet in the self.loaded table.
				table.insert(self.loaded, { love.graphics.newImage( "assets/animation/"..assetName..".png" ), permanent, # self.animations+1, assetName})
				
				-- Setup the animation. 
				table.insert(self.animations, newAnimation(self.loaded[#self.loaded][1], _value[3][1], _value[3][2], _value[3][3], _value[3][4]) )		
				
				-- Return the id
				return # self.loaded
			end		
			-- the above statements should catch everything
		end
	end
	-- return a nil value, asset is invalid
	return nil
	
end

function GraphicsHandler:draw(asset_id, x, y, rotation, scale)
	-- We should make a point to always draw from the center of the sprite, to deal with 
	-- the fact that we can scale and rotate things. However, right now calling getWidth
	-- for an AnAl animation object returns an error.
	if self.loaded[asset_id][3] then
		-- it has the animation_id flag, so lets assume it's an animation
		self.animations[self.loaded[asset_id][3]]:draw(x,y, rotation, scale, scale, self.animations[self.loaded[asset_id][3]]:getWidth()/2, self.animations[self.loaded[asset_id][3]]:getHeight()/2)
	else
		love.graphics.draw(self.loaded[asset_id][1], x, y, rotation, scale, scale, self.loaded[asset_id][1]:getWidth()/2, self.loaded[asset_id][1]:getHeight()/2)
		--love.graphics.draw(self.loaded[asset_id][1], x, y, rotation, scale, scale, self.loaded[asset_id][1]:getWidth()/2, self.loaded[asset_id][1]:getHeight()/2)
	end
end

function GraphicsHandler:purge() 
end

function GraphicsHandler:update(dt) 
	for _key, _value in pairs(self.animations) do
		_value:update(dt)
	end
end

function GraphicsHandler:getWidth(assetID)
	if self.loaded[assetID][3] then
		-- it has the animation_id flag, so lets assume it's an animation
		--return self.animations[self.loaded[asset_id][3]]:getWidth()
		return 64
	else
		--love.graphics.draw(self.loaded[asset_id][1], x, y, rotation, scale, scale)
		--love.graphics.draw(self.loaded[asset_id][1], x, y, rotation, scale, scale, self.loaded[asset_id][1]:getWidth()/2, self.loaded[asset_id][1]:getHeight()/2)
		return self.loaded[assetID][1]:getWidth()
	end
end

function GraphicsHandler:getHeight(assetID)
	if self.loaded[assetID][3] then
		-- it has the animation_id flag, so lets assume it's an animation
		--return self.animations[self.loaded[asset_id][3]]:getHeight()
		return 64
	else
		--love.graphics.draw(self.loaded[asset_id][1], x, y, rotation, scale, scale)
		--love.graphics.draw(self.loaded[asset_id][1], x, y, rotation, scale, scale, self.loaded[asset_id][1]:getWidth()/2, self.loaded[asset_id][1]:getHeight()/2)
		return self.loaded[assetID][1]:getHeight()
	end
end
