require 'rails_helper'

RSpec.describe Board, type: :model do
  describe 'creating a board' do

    params = {
      game_id: 1,
      turn: "white",
      status_str: "Ready to test"
    }

    it 'creates a board with expected fields' do

      g = Game.create()
      params[:game_id] = g.id
      # TODO: remove null false and fk restraint on game/board
      b = Board.create(params)

      expect(b).to_not eq(nil)
      expect(b.game_id).to eq(params[:game_id])
      expect(b.turn).to eq(params[:turn])
      expect(b.status_str).to eq(params[:status_str])
    end

    it 'init_vars called after creation' do

      g = Game.create()
      params[:game_id] = g.id
      b = Board.create(params)

      # TODO: test actual method call
      # expect(b.pieces).to_not eq(nil)
      expect(b.move_count).to eq(1)
      # expect(b.legal_moves).to_not eq(nil)

    end

    it 'generate_legal_moves called after creation' do

    end

  end
end
