require 'swagger_helper'

RSpec.describe 'Boards API', type: :request do

  pgn_test = <<-PGN_TEST
  [Event "URS-ch46"]
  [Site "Tbilisi"]
  [Date "1978.??.??"]
  [Round "?"]
  [White "Kasparov, Gary"]
  [Black "Bagirov, Vladimir"]
  [Result "1/2-1/2"]
  [WhiteElo ""]
  [BlackElo "2505"]
  [ECO "B17"]

  1.e4 c6 2.d4 d5 3.Nc3 dxe4 4.Nxe4 Nd7 5.Bc4 Ngf6 6.Ng5 e6 7.Qe2 Nb6 8.Bd3 h6
  9.N5f3 c5 10.dxc5 Nbd7 11.b4 b6 12.Nd4 Nxc5 13.Bb5+ Ncd7 14.a3 Bb7 15.Ngf3 a6
  16.Bd3 Be7 17.Bb2 O-O 18.O-O Re8 19.Bc4 Bf8 20.Rad1 Qc7 21.Bb3 b5 22.c4 bxc4
  23.Qxc4 Qxc4 24.Bxc4 Bd5 25.Bxd5 Nxd5 26.Nb3 Be7 27.g3 Rec8 28.Rc1 Kf8 29.Na5 Bf6
  30.Bxf6 gxf6  1/2-1/2
  PGN_TEST

  path '/api/boards/{id}' do

    get('Show board by id') do
      produces 'application/json'

      parameter name: :id, in: :path, type: :string

      response(200, 'successful') do
        let(:board) { '1' }
        run_test!
      end
    end

  end

  path '/api/boards' do

    post('Creates a board from pgn text') do
      produces 'application/json'
      consumes 'application/json'

      parameter name: :pgn_text, in: :body, type: :string

      response(200, 'successful') do
        let(:board) { { pgn_text: pgn_test } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:board) { { asdf: 'bad_input' } }
        run_test!
      end
    end

  end

end
