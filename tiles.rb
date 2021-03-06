
require '.\item'
require '.\enemy'
require '.\actions'
require '.\world'

class MapTile
  def initialize(x, y)
  	@x = x
  	@y = y
  end
  
  def modify_player(plyaer)
  end

  def intro_text
  end

  def adjacent_moves
  	moves = []
  	if World.tile_exists?(@x + 1, @y)
  	  moves << MoveEast.new
  	end
  	if World.tile_exists?(@x + -1, @y)
  	  moves << MoveWest.new
  	end
  	if World.tile_exists?(@x, @y + 1)
  	  moves << MoveSouth.new
  	end
  	if World.tile_exists?(@x, @y - 1)
  	  moves << MoveNorth.new
  	end	
  	moves
  end

  def available_actions
  	moves = adjacent_moves
  	moves << ViewInventory.new

  	moves
  end
end

class StartingRoom < MapTile
  def intro_text
  	puts "You find yourself in a cave with a flickering torch on the wall.
    \rYou can make out four paths, each equally as dark and foreboding."
  end
end

class LootRoom < MapTile
  def initialize(x, y, item)
  	@item = item
    @item_count = 1
  	super(x, y)
  end

  def add_loot(player)
  	player.inventory << @item
    @item_count = 0
  end

  def modify_player(player)
  	add_loot(player) if @item_count > 0
  end
end

class EnemyRoom < MapTile
  attr_accessor :enemy
  def initialize(x, y, enemy)
  	@enemy = enemy
  	super(x, y)
  end
  def modify_player(the_player)
  	if @enemy.is_alive?
  		the_player.hp = the_player.hp - @enemy.damage
  		puts("Enemy does %d damage. You have %d HP remaining." %[@enemy.damage, the_player.hp])
  	end
  end

  def available_actions
  	if enemy.is_alive?
  	  [Flee.new(self), Attack.new(enemy)]
  	else
  	  adjacent_moves
  	end
  end	
end

class EmptyCavePath < MapTile
  def intro_text
    puts "Another unremarkable part of the cave. You must forge onwards."
  end
end

class GiantSpiderRoom < EnemyRoom
  def initialize(x, y)
  	super(x, y, GiantSpider.new)
  end

  def intro_text
  	if @enemy.is_alive?
  	  puts "A giant spider jumps down from its web in front of you!"
    else
      puts "The corpse of a dead spider rots on the ground."
    end
  end
end

class FindDaggerRoom < LootRoom
  def initialize(x, y)
  	super(x, y, Dagger.new)
  end
  def intro_text
  	if @item_count > 0
      puts "You notive something shiny in the corner.
  	  \rIt's a dagger! You pick it up." 
    else
      puts "There is nothing else in this room."
    end
  end
end

class Find5GoldRoom < LootRoom
	def initialize(x, y)
		super(x, y, Gold.new(5))
	end

	def intro_text
		if @item_count > 0
      puts "You see a shiny coin half buried.
		  \rYou are now 5 coins richer."
    else
      puts "That was the only coin..."
    end
	end
end

class LeaveCaveRoom < MapTile
  def intro_text
  	puts "You see a bright light in the distance...
  	\r... it grows as you get closer! It's sunlight!

  	\rVictory is yours!"
  end

  def modify_player(player)
  	player.not_won = false
    system "pause"
  end
end
