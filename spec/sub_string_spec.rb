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

    it 'finds "he" 7 times in the string "hehehehehehehe"' do
      sub_string.instance_variable_set(:@block, 'hehehehehehehe')
      sub_string.instance_variable_set(:@target_string, 'he')

      expect{sub_string.find_target_string_in_block}.to change{sub_string.occurrences_of_target_string}.by(7)
    end

    it 'finds "hehe" 3 times in the string "hehehehehehehe"' do
      sub_string.instance_variable_set(:@block, 'hehehehehehehe')
      sub_string.instance_variable_set(:@target_string, 'hehe')

      expect{sub_string.find_target_string_in_block}.to change{sub_string.occurrences_of_target_string}.by(3)
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

    context 'finds horse in the first block' do
      let(:target_string) { 'horse' }
      let(:fake_file) { StringIO.new('horse678901234567890') }
      subject { sub_string.call }

      it { is_expected.to eq(1) }
    end

    context 'finds horse in the second block' do
      let(:target_string) { 'horse' }
      let(:fake_file) { StringIO.new('1234567890horse67890') }
      subject { sub_string.call }

      it { is_expected.to eq(1) }
    end

    context 'finds horse at the end of the second block' do
      let(:target_string) { 'horse' }
      let(:fake_file) { StringIO.new('123456789012345horse') }
      subject { sub_string.call }

      it { is_expected.to eq(1) }
    end

    context 'finds horse in a short final block' do
      let(:target_string) { 'horse' }
      let(:fake_file) { StringIO.new('123horse9012345678901horse') }
      subject { sub_string.call }

      it { is_expected.to eq(2) }
    end

    context 'finds horse in a short final overlapping block' do
      let(:target_string) { 'horse' }
      let(:fake_file) { StringIO.new('1234567890123456horse') }
      subject { sub_string.call }

      it { is_expected.to eq(1) }
    end

    context 'finds horse in overlapping blocks' do
      let(:target_string) { 'horse' }
      let(:fake_file) { StringIO.new('12345678horse4567890') }
      subject { sub_string.call }

      it { is_expected.to eq(1) }
    end
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
