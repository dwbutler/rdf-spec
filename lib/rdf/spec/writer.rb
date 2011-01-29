require 'rdf/spec'

share_as :RDF_Writer do
  include RDF::Spec::Matchers


  before(:each) do
    raise '+@writer+ must be defined in a before(:each) block' unless instance_variable_get('@writer')
    @writer_class = @writer.class
  end

  describe ".each" do
    it "yields each writer" do
      @writer_class.each do |r|
        r.superclass.should == RDF::Writer
      end
    end
  end
  
  describe ".buffer" do
    it "calls .new with buffer and other arguments" do
      @writer_class.should_receive(:new)
      @writer_class.buffer do |r|
        r.should be_a(@writer_class)
      end
    end
  end

  describe ".open" do
    before(:each) do
      RDF::Util::File.stub!(:open_file).and_yield(StringIO.new("foo"))
    end

    it "yields writer given file_name" do
      @writer_class.format.each do |f|
        f.file_extensions.each_pair do |sym, content_type|
          writer_mock = mock("writer")
          writer_mock.should_receive(:got_here)
          @writer_class.should_receive(:for).with(:file_name => "foo.#{sym}").and_return(@writer_class)
          @writer_class.open("foo.#{sym}") do |r|
            r.should be_a(RDF::Writer)
            writer_mock.got_here
          end
        end
      end
    end

    it "yields writer given symbol" do
      @writer_class.format.each do |f|
        sym = f.name.to_s.split('::')[-2].downcase.to_sym  # Like RDF::NTriples::Format => :ntriples
        writer_mock = mock("writer")
        writer_mock.should_receive(:got_here)
        @writer_class.should_receive(:for).with(sym).and_return(@writer_class)
        @writer_class.open("foo.#{sym}", :format => sym) do |r|
          r.should be_a(RDF::Writer)
          writer_mock.got_here
        end
      end
    end

    it "yields writer given {:file_name => file_name}" do
      @writer_class.format.each do |f|
        f.file_extensions.each_pair do |sym, content_type|
          writer_mock = mock("writer")
          writer_mock.should_receive(:got_here)
          @writer_class.should_receive(:for).with(:file_name => "foo.#{sym}").and_return(@writer_class)
          @writer_class.open("foo.#{sym}", :file_name => "foo.#{sym}") do |r|
            r.should be_a(RDF::Writer)
            writer_mock.got_here
          end
        end
      end
    end

    it "yields writer given {:content_type => 'a/b'}" do
      @writer_class.format.each do |f|
        f.content_types.each_pair do |content_type, formats|
          writer_mock = mock("writer")
          writer_mock.should_receive(:got_here)
          @writer_class.should_receive(:for).with(:content_type => content_type, :file_name => "foo").and_return(@writer_class)
          @writer_class.open("foo", :content_type => content_type) do |r|
            r.should be_a(RDF::Writer)
            writer_mock.got_here
          end
        end
      end
    end
  end

  describe ".new" do
    it "sets @output to $stdout by default" do
      writer_mock = mock("writer")
      writer_mock.should_receive(:got_here)
      @writer_class.new() do |r|
        writer_mock.got_here
        r.instance_variable_get(:@output).should == $stdout
      end
    end
    
    it "sets @input to input given something other than a string" do
      writer_mock = mock("writer")
      writer_mock.should_receive(:got_here)
      file = mock("file")
      @writer_class.new(file) do |r|
        writer_mock.got_here
        r.instance_variable_get(:@output).should == file
      end
    end
    
    it "sets prefixes given :prefixes => {}" do
      writer_mock = mock("writer")
      writer_mock.should_receive(:got_here)
      @writer_class.new("string", :prefixes => {:a => "b"}) do |r|
        writer_mock.got_here
        r.prefixes.should == {:a => "b"}
      end
    end
    
    it "calls #write_prologue" do
      pending("mock of any instance support") do
        #writer_mock = mock("writer")
        #writer_mock.should_receive(:got_here)
        @writer_class.any_instance.should_receive(:write_prologue)
        @writer_class.new() do |r|
          #writer_mock.got_here
        end
      end
    end
    
    it "calls #write_epilogue" do
      pending("mock of any instance support") do
        #writer_mock = mock("writer")
        #writer_mock.should_receive(:got_here)
        @writer_class.any_instance.should_receive(:write_epilogue)
        @writer_class.new() do |r|
          #writer_mock.got_here
        end
      end
    end
  end
  
  describe "#prefixes=" do
    it "sets prefixes from hash" do
      @writer.prefixes = {:a => "b"}
      @writer.prefixes.should == {:a => "b"}
    end
  end
  
  describe "#prefix" do
    {
      nil     => "nil",
      :a      => "b",
      "foo"   => "bar",
    }.each_pair do |pfx, uri|
      it "sets prefix(#{pfx}) to #{uri}" do
        @writer.prefix(pfx, uri).should == uri
        @writer.prefix(pfx).should == uri
      end
    end
  end
end
