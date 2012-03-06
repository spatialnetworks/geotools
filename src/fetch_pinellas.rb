# fetches imagery from http://data.labins.org/imf3/LABINS2B/labins.jsp
#
# usage:
# ruby fetch_pinellas.rb ~/some/output/path

output_path = File.join(ARGV[0] || '.', "") 

start_tile     = 67575 #min tile
end_tile       = 76875 #max tile
grid_columns   = 20    #number of colums to fetch for each row
grid_row_step  = 300   #number between the last tile of a row and the beginning of next row
current_column = 0     
current_count  = 0
current_start  = start_tile
current_tile   = start_tile

while current_start + current_column <= end_tile + grid_columns
  current_tile   = current_start + current_column
  current_count += 1

  current_column += 1
  current_start   = current_start + grid_row_step if current_column >= grid_columns
  current_column  = 0 if current_column >= grid_columns 
  
  sid_path = "http://bsm07.freac.fsu.edu/Hi-Res-Imagery/deliverfiles.cfm?thefile=OP2011_NC_0#{current_tile}_24.sid&thefullpath=S:\\Delivery\\2011\\Pinellas\\sid\\OP2011_NC_0#{current_tile}_24.sid"

  puts "Downloading tile #{current_count.to_s} (Grid ##{current_tile})"
  system "curl \"#{sid_path}\" -o #{File.join(output_path, current_tile.to_s)}.sid"
end
