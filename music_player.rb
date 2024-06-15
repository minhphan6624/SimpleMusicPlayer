require 'rubygems'
require 'gosu'

SCR_W = 1600
SCR_H = 900

BUTTON_RATIO = 0.15625

LEFT_ARTWORK_CONT = 150
TOP_ARTWORK_CONT = 10
LENGTH_ARTWORK_CONT = 1300 
HEIGH_ARTWORK_CONT = 340

LEFT_MAIN_CONT = 150
TOP_MAIN_CONT = 390
LENGTH_MAIN_CONT = 925
HEIGHT_MAIN_CONT = 340

LEFT_TRACKS_CONT = 1125
TOP_TRACKS_CONT = 390
LENGTH_TRACKS_CONT = 325
HEIGH_TRACKS_CONT = 340

LEFT_VOLUME = 1200
TOP_VOLUME = SCR_H - 120 + 35 + 5
LENGTH_VOLUME = 200
HEIGHT_VOLUME = 40

LEFT_FOOTER = 0 
HEIGHT_FOOTER = 120


module ZOrder
  BACKGROUND, CONTAINER, UI = *0..2
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class ArtWork
	attr_accessor :bmp, :dim
	
	def initialize(file, left, top)
		@bmp = Gosu::Image.new(file)
        @dim = Dimension.new(left, left+@bmp.width(), top, top+@bmp.height())
	end
end

class Album
	attr_accessor :title, :artist, :year,  :artwork, :tracks
	
	def initialize (title, artist, year, artwork, tracks)
		@title = title
		@artist = artist
		@year = year
		@artwork = artwork
		@tracks = tracks
	end
end

class Track
	attr_accessor :name, :location, :dim, :like 

	def initialize(name, location, dim,like)
		@name = name
		@location = location
		@dim = dim
		@like = like
	end
end

class Dimension
	attr_accessor :left, :right, :top, :bot
	
	def initialize(left, right, top, bot)
		@left = left
		@right = right
		@top = top
		@bot = bot
	end
end

class MusicPlayerMain < Gosu::Window

	def initialize
	    super SCR_W, SCR_H
	    self.caption = "Music Player"

		@track_font = Gosu::Font.new(25)
		@track_header = Gosu::Font.new(40)

	    @albums = read_albums()
	    
		@liked_tracks = []
		@liked_artwork = ArtWork.new("images/artwork/liked.png", LEFT_ARTWORK_CONT + 20 + 320 * (@albums.length()%4), TOP_ARTWORK_CONT + 20)
		@liked = Album.new("Liked Tracks", "Various Artists", "--", @liked_artwork, @liked_tracks) 
		@albums << @liked
		
		@album_playing = -1
	    @track_playing = -1	

		@curr_page = 0
		@max_page = @albums.length()/4 + 1
		
		@pause = false
		@stop = false
		
		@shuffle = false

		@change_volume = false

		@sort = false
	end

	#--------------------------------------- Reading the information ---------------------------------------
	# Read in an album
	def read_album(a_file, index)   
		title = a_file.gets.chomp()
		artist = a_file.gets.chomp()
		year = a_file.gets.chomp()
		
		# Positioning and Dimension of an album's artwork
		left = LEFT_ARTWORK_CONT + 20 + 320 * (index%4)
		top = TOP_ARTWORK_CONT + 20
		#-------------

		artwork = ArtWork.new(a_file.gets.chomp, left, top)
		
		tracks = read_tracks(a_file)

		album = Album.new(title, artist, year, artwork, tracks)

		return album
	end

    #Read in multiple albums
    def read_albums()
        a_file = File.new("albums.txt", "r")
        count = a_file.gets.chomp.to_i
        albums = []

        for i in 0..(count-1)
            album = read_album(a_file, i)
            albums << album
        end

        a_file.close()
        return albums
    end

	#Read in the tracks of an album
	def read_tracks(a_file)
		tracks = []
		count = a_file.gets.chomp.to_i

		for i in 0..count-1
			track = read_track(a_file, i)
			tracks << track
		end
		
		return tracks
	end

	#Read in a single track
	def read_track(a_file, index)
		name = a_file.gets.chomp
		location = a_file.gets.chomp

        # Positioning the location of the track's
		left = LEFT_TRACKS_CONT + 50
		top = TOP_TRACKS_CONT + 50 + 55 * index
		right = left + @track_font.text_width(name)
		bot = top + @track_font.height

		dim = Dimension.new(left, right, top, bot)

		like = false

		track = Track.new(name, location, dim, like)

		return track
	end	

	#--------------------------------------- End of reading the information ---------------------------------------

	#--------------------------------------- Drawing general elements and buttons---------------------------------------

	# Draw the background
	def draw_background()
		draw_rect(0, 0, SCR_W, SCR_H, Gosu::Color::BLACK, ZOrder::BACKGROUND)
	end	

	def draw_artwork_containter()
		draw_rect(LEFT_ARTWORK_CONT, TOP_ARTWORK_CONT , LENGTH_ARTWORK_CONT, HEIGH_ARTWORK_CONT, Gosu::Color::GRAY, ZOrder::CONTAINER)
	end

	def draw_main_containter()
		draw_rect(LEFT_MAIN_CONT, TOP_MAIN_CONT , LENGTH_MAIN_CONT, HEIGHT_MAIN_CONT, Gosu::Color::GRAY, ZOrder::CONTAINER)
	end

	def draw_tracks_containter()
		draw_rect(LEFT_TRACKS_CONT, TOP_TRACKS_CONT, LENGTH_TRACKS_CONT, HEIGH_TRACKS_CONT, Gosu::Color::GRAY, ZOrder::CONTAINER)
	end

	def draw_footer()
		draw_rect(LEFT_FOOTER, SCR_H  - 120 , SCR_W, HEIGHT_FOOTER, Gosu::Color::GRAY, ZOrder::CONTAINER)
	end

	 def draw_shuffle()
        @bmp = Gosu::Image.new("images/shuffle.png")
        @bmp.draw(510, 800 , 2, BUTTON_RATIO, BUTTON_RATIO)
    end

    def draw_repeat()
        @bmp = Gosu::Image.new("images/repeat.png")
        @bmp.draw(510, 800 , 2, BUTTON_RATIO, BUTTON_RATIO)
    end

	# draw main buttons
	def draw_button()
		@bmp = Gosu::Image.new("images/previous.png") 
		@bmp.draw(610, 800 , 2, BUTTON_RATIO, BUTTON_RATIO)

		@bmp = Gosu::Image.new("images/stop.png")
		@bmp.draw(710, 800 , 2, BUTTON_RATIO, BUTTON_RATIO)

		if (@pause==false)
			@bmp = Gosu::Image.new("images/pausebutton.png")
			@bmp.draw(810, 800 , 2, BUTTON_RATIO, BUTTON_RATIO)
		else	
			@bmp = Gosu::Image.new("images/playbutton.png")
			@bmp.draw(810, 800, 2, BUTTON_RATIO, BUTTON_RATIO)
		end

		@bmp = Gosu::Image.new("images/next.png")
        @bmp.draw(910, 800 , 2, BUTTON_RATIO, BUTTON_RATIO)
	end
	
	#Draw the next and previous page button
	def draw_change_page()
		@bmp = Gosu::Image.new("images/pre_page.png")
		@bmp.draw(50, 150, 2, 0.2,0.2)

		@bmp = Gosu::Image.new("images/next_page.png")
		@bmp.draw(1500, 150, 2, 0.2, 0.2)
	end

	#Draw the sorting icons
	# def draw_sort()
	# 	if @sort == false
    #     	@bmp = Gosu::Image.new("images/AtoZ.png")
    #     	@bmp.draw(LEFT_TRACKS_CONT + 20, TOP_TRACKS_CONT + 10 , ZOrder::UI, 0.1, 0.1)
	# 	else
    #     	@bmp = Gosu::Image.new("images/ZtoA.png")
    #     	@bmp.draw(LEFT_TRACKS_CONT + 20, TOP_TRACKS_CONT + 10 , ZOrder::UI, 0.1, 0.1)
	# 	end
    # end

	def draw_volume()
		draw_rect(LEFT_VOLUME-5, TOP_VOLUME-5, LENGTH_VOLUME+10, HEIGHT_VOLUME+10, Gosu::Color::BLACK, 1)
		
		if @change_volume == true
			draw_rect(LEFT_VOLUME, TOP_VOLUME, @song.volume * 200, HEIGHT_VOLUME, Gosu::Color::AQUA, ZOrder::UI)
		else
			draw_rect(LEFT_VOLUME, TOP_VOLUME, LENGTH_VOLUME, HEIGHT_VOLUME, Gosu::Color::AQUA, 2)
		end

			if @song.volume >= 0.6
				@bmp = Gosu::Image.new("images/volume75.png")
				@bmp.draw(LEFT_VOLUME - 80, TOP_VOLUME - 10, ZOrder::UI, 0.2, 0.2)
			end
			if @song.volume >= 0.30 && @song.volume < 0.60
				@bmp = Gosu::Image.new("images/volume50.png")
				@bmp.draw(LEFT_VOLUME - 80, TOP_VOLUME - 10, ZOrder::UI, 0.2, 0.2)
			end
			if @song.volume > 0 && @song.volume < 0.30
				@bmp = Gosu::Image.new("images/volume25.png")
				@bmp.draw(LEFT_VOLUME - 80, TOP_VOLUME - 10, ZOrder::UI, 0.2, 0.2)
			end
			if @song.volume == 0
				@bmp = Gosu::Image.new("images/novolume.png")
				@bmp.draw(LEFT_VOLUME - 80, TOP_VOLUME - 10, ZOrder::UI, 0.2, 0.2)
			end
	end

	#--------------------------------------- End of drawing general elements and buttons---------------------------------------

	#--------------------------------------- Drawing the albums and tracks info---------------------------------------

	# Draw the artworks of the albums
	def draw_albums(albums, curr_page)
		for i in 0..albums.length()-1
			if (i/4 == curr_page)
            	albums[i].artwork.bmp.draw(albums[i].artwork.dim.left, albums[i].artwork.dim.top, 2)
			end
		end
  	end

	def draw_album_playing(album)
        album.artwork.bmp.draw(LEFT_MAIN_CONT + 20, TOP_MAIN_CONT+20, 2)
        @track_header.draw( "Album: " + album.title, 490, TOP_MAIN_CONT + 20 + 150 - 20 -60 ,ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE )
		@track_header.draw( "Artist: " + album.artist, 490, TOP_MAIN_CONT + 20 + 150 - 20, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE )
		@track_header.draw( "Year: " + album.year, 490, TOP_MAIN_CONT + 20 + 150 - 20 + 60, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE )

		album.artwork.bmp.draw(0, (SCR_H-120), 2, 0.4, 0.4) 
    end

    # Display the tracks' title of an album
    def draw_tracks(album)
		if album == @albums[@albums.length()-1]
			for i in 0..album.tracks.length()-1
				display_track_liked(album.tracks[i], i)
				draw_current_playing_liked(@track_playing, @albums[@albums.length()-1])
			end
		else
			album.tracks.each do |track|
				display_track(track)
			end
		end
    end

	# Display the track name
  	def display_track(track)

		if track.like == false
			@pic = Gosu::Image.new("images/heart.png")
			@pic.draw(track.dim.left - 35, track.dim.top, 2, 0.05, 0.05)
		else
			@pic = Gosu::Image.new("images/heart1.png")
			@pic.draw(track.dim.left - 35, track.dim.top, 2, 0.05, 0.05)
		end
		@track_font.draw(track.name, LEFT_TRACKS_CONT+50, track.dim.top, 2, 1.0, 1.0, Gosu::Color::WHITE)
	end

	#Draw the current playing indicator and the info in the footer
	def draw_current_playing(index, album)
		@pic = Gosu::Image.new("images/now_playing.png")
		@pic.draw(album.tracks[index].dim.right + 5, album.tracks[index].dim.top - 2 , 2, 0.1, 0.1)

		@track_font.draw(album.tracks[@track_playing].name, 140, SCR_H - 100 , ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK) 
		
		@track_font.draw(album.artist, 140, SCR_H - 50 , ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)   
	end
	 #--------------------------------------- End of drawing the albums and tracks info ---------------------------------------

	 #--------------------------------------- Drawing the albums and tracks info of Liked Tracks album ---------------------------------------

	 def display_track_liked(track,i)

		if track.like == false
			@pic = Gosu::Image.new("images/heart.png")
			@pic.draw(LEFT_TRACKS_CONT + 50 - 35, TOP_TRACKS_CONT + 50 + 55 * i, 2, 0.05, 0.05)
		else
			@pic = Gosu::Image.new("images/heart1.png")
			@pic.draw(LEFT_TRACKS_CONT + 50 - 35, TOP_TRACKS_CONT + 50 + 55 * i, 2, 0.05, 0.05)
		end
		@track_font.draw(track.name, LEFT_TRACKS_CONT+50, TOP_TRACKS_CONT + 50 + 55 * i, 2, 1.0, 1.0, Gosu::Color::WHITE)
	end

	def draw_current_playing_liked (index, album)
		@pic = Gosu::Image.new("images/now_playing.png")
		@pic.draw(LEFT_TRACKS_CONT + 50 + @track_font.text_width(album.tracks[index].name) + 5, TOP_TRACKS_CONT + 50 + 55 * index - 2 , 2, 0.1, 0.1)

		@track_font.draw(album.tracks[@track_playing].name, 140, SCR_H - 100 , ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK) 
		
		@track_font.draw(album.artist, 140, SCR_H - 50 , ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)   
	end

	 #--------------------------------------- End of drawing the albums and tracks info of Liked Tracks album ---------------------------------------

	 # Detects if a 'mouse sensitive' area has been clicked on
	def area_clicked(left, top, right, bot)
		if (mouse_x >= left && mouse_x <= right && mouse_y>=top &&mouse_y<=bot)
			return true
		end
		return false
 	end

	# Takes a track index and an Album and plays the Track from the Album
	def playTrack(track, album)
		@song = Gosu::Song.new(album.tracks[track].location)
		@song.play(false)
	end


	def update
		#Play the first song of the first album when opening the music player
		if @album_playing < 0
			@album_playing = 0
			@track_playing = 0
			playTrack(@track_playing, @albums[@album_playing])
		end

		#Check if there's any liked song in the currently playing album
		if @album_playing != @albums.length()-1 
			for i in 0..@albums[@album_playing].tracks.length()-1
				
				if @albums[@album_playing].tracks[i].like == true && (not @albums[@albums.length()-1].tracks.include?(@albums[@album_playing].tracks[i])) && @albums[@albums.length()-1].tracks.length() < 5 
					@albums[@albums.length()-1].tracks << @albums[@album_playing].tracks[i]
				end

				if (@albums[@album_playing].tracks[i].like == false) && (@albums[@albums.length()-1].tracks.include?(@albums[@album_playing].tracks[i]))
					@albums[@albums.length()-1].tracks.delete(@albums[@album_playing].tracks[i])
				end
			end
		end

		#Remove the track from the liked track album when "unliked"
		

		# If a new album has just been seleted, and no album was selected before -> start the first song of that album
		if @album_playing >= 0 && @song == nil && @albums[@album_playing].tracks.length() > 0
			@track_playing = 0
			playTrack(@track_playing, @albums[@album_playing])
		end

		# If an album has been selected, play all songs in turn
		if @album_playing >= 0 && @song != nil && (not @song.playing?) && @pause == false && @stop == false && @albums[@album_playing].tracks.length() > 0
			if @shuffle == false
				if @track_playing == @albums[@album_playing].tracks.length - 1
					@track_playing = 0 
					playTrack(@track_playing, @albums[@album_playing])
				else
					@track_playing += 1
					playTrack(@track_playing, @albums[@album_playing])
				end
			else
				@track_playing = rand(0..@albums[@album_playing].tracks.length - 1)
				playTrack(@track_playing, @albums[@album_playing])
			end
		end

		#If a song finishes playing, play the next song
		if  @album_playing >=0 && @song != nil && (not @song.playing?) && @stop == false && @pause == false
			if @shuffle == false
				if @track_playing == @albums[@album_playing].tracks.length - 1
					@track_playing = 0 
					playTrack(@track_playing, @albums[@album_playing])
				else
					@track_playing += 1
					playTrack(@track_playing, @albums[@album_playing])
				end
			else
				@track_playing = rand(0..@albums[@album_playing].tracks.length - 1)
				playTrack(@track_playing, @albums[@album_playing])
			end
        end

	end

	def draw
		draw_background()
		draw_artwork_containter()
		draw_main_containter()
		draw_tracks_containter()
		draw_footer()

		draw_albums(@albums, @curr_page)
		
		draw_volume()
		# draw_mouse()
		# draw_sort()
		draw_button()
		if @shuffle == true
            draw_shuffle()
        else
            draw_repeat()
        end
		draw_change_page()

		# If an album is selected => display its tracks
		if @album_playing >= 0 
			draw_album_playing(@albums[@album_playing])
			if @albums[@album_playing].tracks.length() > 0
				if @album_playing == @albums.length()-1
					draw_tracks(@albums[@albums.length()-1])
				else
					draw_tracks(@albums[@album_playing])
					draw_current_playing(@track_playing, @albums[@album_playing])
				end
			end
			
		end
		
	end

 	def needs_cursor?; 
		true; 
	end

	def button_down(id)
		case id
	    when Gosu::MsLeft

			# --- Check which album was clicked on ---
			for i in 0..@albums.length() - 1
				if area_clicked(@albums[i].artwork.dim.left, @albums[i].artwork.dim.top, @albums[i].artwork.dim.right, @albums[i].artwork.dim.bot)
					@pause=false
					@album_playing = i + @curr_page*4
					@song = nil
					break
				end
			end

			# If an album has been selected check which track was clicked on 
	    	if @album_playing >= 0 
				if @album_playing == @albums.length()-1 #For Liked Tracks album
					for i in 0..@albums[@album_playing].tracks.length() - 1
						if area_clicked(LEFT_TRACKS_CONT + 50, TOP_TRACKS_CONT + 50 + 55 * i, LEFT_TRACKS_CONT + 50 + @track_font.text_width(@albums[@album_playing].tracks[i]), TOP_TRACKS_CONT + 50 + 55 * i + @track_font.height)
							playTrack(i, @albums[@albums.length()-1])
							@pause=false
							@track_playing = i
							break
						end
					end
				else
					for i in 0..@albums[@album_playing].tracks.length() - 1
						if area_clicked(@albums[@album_playing].tracks[i].dim.left, @albums[@album_playing].tracks[i].dim.top, @albums[@album_playing].tracks[i].dim.right, @albums[@album_playing].tracks[i].dim.bot)
							playTrack(i, @albums[@album_playing])
							@pause=false
							@track_playing = i
							break
						end
					end
				end
			end

			#Check which track is liked
				for j in 0..@albums[@album_playing].tracks.length() - 1
					if area_clicked(@albums[@album_playing].tracks[j].dim.left - 35, @albums[@album_playing].tracks[j].dim.top, @albums[@album_playing].tracks[j].dim.left - 35 + 0.05*512 , @albums[@album_playing].tracks[j].dim.top + 0.05*512)
						if @albums[@album_playing].tracks[j].like == true
							@albums[@album_playing].tracks[j].like = false
						else
							@albums[@album_playing].tracks[j].like = true
						end
					end
				end

			#if stop button is clicked
			if area_clicked(710, 800, 790, 880)
				@stop = true
				@pause = true
				@song.stop
			end

			#If pause/play button is clicked
			if @pause == false
				if area_clicked(810, 800, 890 , 880)
					@pause = true
					@song.pause
					#to turn stop button to false back
				end
			else
				if area_clicked(810, 800, 890 , 880)
					@song.play
					@stop = false
					@pause = false
				end
			end

			#Change volume when clicked
            if area_clicked(LEFT_VOLUME, TOP_VOLUME,  LEFT_VOLUME + LENGTH_VOLUME, TOP_VOLUME + HEIGHT_VOLUME) 
                @song.volume = (mouse_x - LEFT_VOLUME)/200
                @change_volume = true
            end

			 #Change mode from shuffle to repeat when clicked
			 if area_clicked(510, 800, 590, 880)
                if @shuffle == true      
                    @shuffle = false
                else
                   @shuffle = true
                end
            end

			#Previous button
			if area_clicked(610, 800, 690, 880)
				@stop = false
				@pause = false

				if @shuffle == false
					if @track_playing == 0
						@track_playing = 0
						playTrack(@track_playing, @albums[@album_playing])
					else
						@track_playing -= 1
						playTrack(@track_playing, @albums[@album_playing])
					end
				else
					@track_playing = rand(0..@albums[@album_playing].tracks.length - 1)
					playTrack(@track_playing, @albums[@album_playing])
				end
			end

			#Next button
			if area_clicked(910, 800, 990, 880)
				@stop = false
				@pause = false

				if @shuffle == false
					if @track_playing == @albums[@album_playing].tracks.length - 1
						@track_playing = 0 
						playTrack(@track_playing, @albums[@album_playing])
					else
						@track_playing += 1
						playTrack(@track_playing, @albums[@album_playing])
					end
				else
					@track_playing = rand(0..@albums[@album_playing].tracks.length - 1)
					playTrack(@track_playing, @albums[@album_playing])
				end
			end

			if @sort == false
				if area_clicked(LEFT_TRACKS_CONT + 20, TOP_TRACKS_CONT + 10, LEFT_TRACKS_CONT + 20 + 30,  TOP_TRACKS_CONT + 10 + 30)
					@sort = true
				end
			else
				if area_clicked(LEFT_TRACKS_CONT + 20, TOP_TRACKS_CONT + 10, LEFT_TRACKS_CONT + 20 + 30,  TOP_TRACKS_CONT + 10 + 30)
					@sort = false
				end
			end

			#If the user wants to change page
			#previous page
			if area_clicked(50, 150, 110, 210) 
				if @curr_page == 0 
					@curr_page = @max_page-1
				else 
					@curr_page -=1
				end
			end
			#next page
			if area_clicked(1500, 150, 1560, 210) 
				if @curr_page == @max_page-1 
					@curr_page = 0
				else 
					@curr_page +=1
				end
			end

	    end
	end

end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0

