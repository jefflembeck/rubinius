require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../fixtures/classes', __FILE__)
require File.expand_path('../shared/basic', __FILE__)
require File.expand_path('../shared/numeric_basic', __FILE__)
require File.expand_path('../shared/integer', __FILE__)

describe "Array#pack with format 'Q'" do
  it_behaves_like :array_pack_basic, 'Q'
  it_behaves_like :array_pack_numeric_basic, 'Q'
  it_behaves_like :array_pack_no_platform, 'Q'
end

describe "Array#pack with format 'q'" do
  it_behaves_like :array_pack_basic, 'q'
  it_behaves_like :array_pack_numeric_basic, 'q'
  it_behaves_like :array_pack_no_platform, 'q'
end

little_endian do
  describe "Array#pack with format 'Q'" do
    it_behaves_like :array_pack_64bit_le, 'Q'
  end

  describe "Array#pack with format 'q'" do
    it_behaves_like :array_pack_64bit_le, 'q'
  end
end

big_endian do
  describe "Array#pack with format 'Q'" do
    it_behaves_like :array_pack_64bit_be, 'Q'
  end

  describe "Array#pack with format 'q'" do
    it_behaves_like :array_pack_64bit_be, 'q'
  end
end
