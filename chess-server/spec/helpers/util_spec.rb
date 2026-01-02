require 'rails_helper'

RSpec.describe UtilHelper, type: :helper do

  describe 'switch' do

    params = {
      white_name: "Whitey",
      black_name: "Blacky"
    }

    it 'switches white to black' do
      expect(switch("white")).to eq("black")
    end

    it 'switches black to white' do
      expect(switch("black")).to eq("white")
    end

  end

  # TODO: 
  # switch
  # file
  # rank
  # build_empty_board
  # outside
  # file_idx
  # rank_idx
  # keep_in_bounds
  # get_quote_html
  # get_quote
  # justify_str
  # uppercase
  # promotion_map

end
