require 'rubygems'
require 'minitest/autorun'
require 'rdoc/rdoc'
require 'rdoc/code_objects'
require 'rdoc/markup/to_html_crossref'
require File.expand_path '../xref_test_case', __FILE__

class TestRDocMarkupToHtmlCrossref < XrefTestCase

  def setup
    super

    @xref = RDoc::Markup::ToHtmlCrossref.new 'index.html', @c1, true
  end

  def assert_ref(path, ref)
    assert_equal "<p>\n<a href=\"#{path}\">#{ref}</a>\n</p>\n",
                 @xref.convert(ref)
  end

  def refute_ref(body, ref)
    assert_equal "<p>\n#{body}\n</p>\n", @xref.convert(ref)
  end

  def test_handle_special_CROSSREF_C2
    @xref = RDoc::Markup::ToHtmlCrossref.new 'classes/C2.html', @c2, true

    refute_ref '#m', '#m'

    assert_ref '../C2/C3.html', 'C2::C3'
    assert_ref '../C2/C3.html#M000002', 'C2::C3#m'
    assert_ref '../C2/C3/H1.html', 'C3::H1'
    assert_ref '../C4.html', 'C4'

    # TODO there is a C3::H2 in the top-level namespace and RDoc should follow
    # constant scoping rules
    refute_ref 'C3::H2', 'C3::H2'
    refute_ref 'H1', 'H1'
  end

  def test_handle_special_CROSSREF_C2_C3
    @xref = RDoc::Markup::ToHtmlCrossref.new 'classes/C2/C3.html', @c2_c3, true

    assert_ref '../../C2/C3.html#M000002', '#m'

    assert_ref '../../C2/C3.html', 'C3'
    assert_ref '../../C2/C3.html#M000002', 'C3#m'

    assert_ref '../../C2/C3/H1.html', 'H1'
    assert_ref '../../C2/C3/H1.html', 'C3::H1'

    assert_ref '../../C4.html', 'C4'

    refute_ref 'C3::H2', 'C3::H2'
  end

  def test_handle_special_CROSSREF_C3
    @xref = RDoc::Markup::ToHtmlCrossref.new 'classes/C3.html', @c3, true

    assert_ref '../C3.html', 'C3'

    refute_ref '#m',   '#m'
    refute_ref 'C3#m', 'C3#m'

    assert_ref '../C3/H1.html', 'H1'

    assert_ref '../C3/H1.html', 'C3::H1'
    assert_ref '../C3/H2.html', 'C3::H2'

    assert_ref '../C4.html', 'C4'
  end

  def test_handle_special_CROSSREF_C4
    @xref = RDoc::Markup::ToHtmlCrossref.new 'classes/C4.html', @c4, true

    # C4 ref inside a C4 containing a C4 should resolve to the contained class
    assert_ref '../C4/C4.html', 'C4'
  end

  def test_handle_special_CROSSREF_C4_C4
    @xref = RDoc::Markup::ToHtmlCrossref.new 'classes/C4/C4.html', @c4_c4, true

    # A C4 reference inside a C4 class contained within a C4 class should
    # resolve to the inner C4 class.
    assert_ref '../../C4/C4.html', 'C4'
  end

  def test_handle_special_CROSSREF_class
    assert_ref 'C1.html', 'C1'
    refute_ref 'H1', 'H1'

    assert_ref 'C2.html',       'C2'
    assert_ref 'C2/C3.html',    'C2::C3'
    assert_ref 'C2/C3/H1.html', 'C2::C3::H1'

    assert_ref 'C3.html',    '::C3'
    assert_ref 'C3/H1.html', '::C3::H1'

    assert_ref 'C4/C4.html', 'C4::C4'
  end

  def test_handle_special_CROSSREF_file
    assert_ref 'xref_data_rb.html', 'xref_data.rb'
  end

  def test_handle_special_CROSSREF_method
    refute_ref 'm', 'm'
    assert_ref 'C1.html#M000000', '#m'

    assert_ref 'C1.html#M000000', 'C1#m'
    assert_ref 'C1.html#M000000', 'C1#m()'
    assert_ref 'C1.html#M000000', 'C1#m(*)'

    assert_ref 'C1.html#M000000', 'C1.m'
    assert_ref 'C1.html#M000000', 'C1.m()'
    assert_ref 'C1.html#M000000', 'C1.m(*)'

    # HACK should this work
    #assert_ref 'classes/C1.html#M000001', 'C1::m'
    #assert_ref 'classes/C1.html#M000001', 'C1::m()'
    #assert_ref 'classes/C1.html#M000001', 'C1::m(*)'

    assert_ref 'C2/C3.html#M000002', 'C2::C3#m'

    assert_ref 'C2/C3.html#M000002', 'C2::C3.m'

    assert_ref 'C2/C3/H1.html#M000003', 'C2::C3::H1#m?'

    assert_ref 'C2/C3.html#M000002', '::C2::C3#m'
    assert_ref 'C2/C3.html#M000002', '::C2::C3#m()'
    assert_ref 'C2/C3.html#M000002', '::C2::C3#m(*)'
  end

  def test_handle_special_CROSSREF_no_ref
    assert_equal '', @xref.convert('')

    refute_ref 'bogus', 'bogus'
    refute_ref 'bogus', '\bogus'
    refute_ref '\bogus', '\\\bogus'

    refute_ref '#n',    '\#n'
    refute_ref '#n()',  '\#n()'
    refute_ref '#n(*)', '\#n(*)'

    refute_ref 'C1',   '\C1'
    refute_ref '::C3', '\::C3'

    refute_ref '::C3::H1#n',    '::C3::H1#n'
    refute_ref '::C3::H1#n(*)', '::C3::H1#n(*)'
    refute_ref '::C3::H1#n',    '\::C3::H1#n'
  end

  def test_handle_special_CROSSREF_special
    assert_equal "<p>\n<a href=\"C2/C3.html\">C2::C3</a>;method(*)\n</p>\n",
                 @xref.convert('C2::C3;method(*)')
  end

end

