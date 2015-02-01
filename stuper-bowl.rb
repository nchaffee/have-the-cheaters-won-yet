require 'sinatra'
require 'haml'
require 'net/http'

get '/' do
  score = Net::HTTP.get(URI('http://sports.espn.go.com/nfl/bottomline.scores'))

  if /preview/.match(score)
    @bastards_won = 'NO'
    @during_game = false
  else
    match = /England%20(\d+).*Seattle%20(\d+)/.match(score)
    new_england, seattle = match[1], match[2]
    @bastards_won = new_england > seattle ? 'YES' : 'NO'
    @during_game = /FINAL/.match(score) ? false : true
  end
  haml :index
end

get '/*' do
  redirect '/'
end

__END__
@@ layout
%html
  %head
    %title Have the cheaters won the Stuper Bowl yet?
  %body
    %div(align='center')
      =yield

@@ index
%p(style="font-size:6em;font-weight:bold#{@during_game ? ';color:red' : ''}")
  = @bastards_won
