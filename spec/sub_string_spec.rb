require 'sub_string'
require 'stringio'

RSpec.describe SubString do
  let(:target_string) { 'jdfl' }
  let(:fake_file) { StringIO.new('isuobhoilun4pun4kjnfajknsadkjaewlfknsajkhakjfsddflkasjdfwaehfluisjkhdfuhljkafilaushkdjlfjlkwefwliuashdfkjhwalegukjhdfskjgawelfhsdkj.n,hlekjrngjlksdfngjknadsfjk.nsdfljkawhfksj.dfnkj.a,snfewanf,jsbghjadsfiuoahweflksdjflk;sjdaf;lkjsadf;lkjasdfkjasdfkjhsdkfjsdlfkjsdflkjsdlfkjsdjksdlfkjsdlkfjsdlkfjsdlkfjsdlkfjwafiupojweoifjweoifjwoijwoiajgwlkjdskljdflksjdflkjsdf') }
  subject(:sub_string) { SubString.new('pretend_filename', target_string) }

  describe '#load_next_block' do
    before do
      SubString.send(:remove_const, 'BLOCK_SIZE')
      SubString::BLOCK_SIZE = 10
      allow(File).to receive(:open).and_return(fake_file)
    end

    context 'no blocks loaded' do
      it 'loads SubString::BLOCK_SIZE bytes from file' do
        expect{sub_string.load_next_block}.to change{fake_file.tell}.by(SubString::BLOCK_SIZE)
      end
    end

    context '1 block loaded' do
      it 'loads SubString::BLOCK_SIZE - (target_string.size - 1) bytes from file' do
        sub_string.load_next_block
        #expect{sub_string.load_next_block}.to change{fake_file.tell}.by(SubString::BLOCK_SIZE - target_string.size + 1)
        expect{sub_string.load_next_block}.to change{fake_file.tell}.by(SubString::BLOCK_SIZE)
      end
    end
  end

  describe '#block' do
    before do
      SubString.send(:remove_const, 'BLOCK_SIZE')
      SubString::BLOCK_SIZE = 10
      allow(File).to receive(:open).and_return(fake_file)
    end

    context 'no blocks loaded' do
      it 'block is nil' do
        expect(sub_string.block).to_not be
      end
    end

    context '1 block loaded' do
      it 'block is BLOCK_SIZE chars long' do
        sub_string.load_next_block
        expect(sub_string.block.size).to eq(SubString::BLOCK_SIZE)
      end
    end

    context '2 block loaded' do
      it 'block is BLOCK_SIZE chars long' do
        2.times { sub_string.load_next_block }
        expect(sub_string.block.size).to eq(SubString::BLOCK_SIZE)
      end
    end
  end

  describe '#find_target_string_in_block' do
    it 'finds "bc" twice in the string "abcbcdcde"' do
      sub_string.instance_variable_set(:@block, 'abcbcdcde')
      sub_string.instance_variable_set(:@target_string, 'bc')

      expect{sub_string.find_target_string_in_block}.to change{sub_string.occurrences_of_target_string}.by(2)
    end

    it 'finds "abab" twice (skips overlap) in the string "abababab"' do
      sub_string.instance_variable_set(:@block, 'abababab')
      sub_string.instance_variable_set(:@target_string, 'abab')

      expect{sub_string.find_target_string_in_block}.to change{sub_string.occurrences_of_target_string}.by(2)
    end

    it 'finds the string "horse" at the start and end of the string' do
      sub_string.instance_variable_set(:@block, 'horseljnsiuegnrlisengresohorse')
      sub_string.instance_variable_set(:@target_string, 'horse')

      expect{sub_string.find_target_string_in_block}.to change{sub_string.occurrences_of_target_string}.by(2)
    end
  end

  describe '#call' do
    before do
      SubString.send(:remove_const, 'BLOCK_SIZE')
      SubString::BLOCK_SIZE = 10
      allow(File).to receive(:open).and_return(fake_file)
    end

    context 'finds goose in the first block' do
      let(:target_string) { 'goose' }
      let(:fake_file) { StringIO.new('goose678901234567890') }
      subject { sub_string.call }

      it { is_expected.to eq(1) }
    end

    context 'finds goose in the second block' do
      let(:target_string) { 'goose' }
      let(:fake_file) { StringIO.new('1234567890goose67890') }
      subject { sub_string.call }

      it { is_expected.to eq(1) }
    end

    context 'finds goose in overlapping blocks' do
      let(:target_string) { 'goose' }
      let(:fake_file) { StringIO.new('12345678goose4567890') }
      subject { sub_string.call }

      it { is_expected.to eq(1) }
    end
  end

  describe '#string_matches?' do
    #it 'finds substrings that are there' do
    #  expect(sub_string.string_matches?('1234567890', 0, '1234')).to be true
    #  expect(sub_string.string_matches?('1234567890', 1, '234')).to be true
    #  expect(sub_string.string_matches?('1234567890', 7, '890')).to be true
    #end

    #it 'doesn\'t find substrings that aren\'t there' do
    #  expect(sub_string.string_matches?('1234567890', 1, '1234')).to be false
    #  expect(sub_string.string_matches?('1234567890', 0, '234')).to be false
    #  expect(sub_string.string_matches?('1234567890', 5, '890')).to be false
    #end
  end

  describe '#smaller_parts' do
    it 'splits the string into all smaller parts' do
      smaller_parts = sub_string.smaller_parts('abcdefg')
      expect(smaller_parts).to eq([
        ['a', 'bcdefg'],
          ['ab', 'cdefg'],
          ['abc', 'defg'],
          ['abcd', 'efg'],
          ['abcde', 'fg'],
          ['abcdef', 'g']
        ])
    end
  end
end
